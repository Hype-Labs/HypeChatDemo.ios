//
// MIT License
//
// Copyright (C) 2018 HypeLabs Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import "ContactViewController.h"
#import "ContactTableViewCell.h"
#import "ChatViewController.h"
#import "Store.h"

#import <Hype/Hype.h>

@interface ContactViewController () <HYPStateObserver, HYPNetworkObserver, HYPMessageObserver, UITableViewDelegate, UITableViewDataSource>

// The stores object keeps track of message storage associated with each instance (peer)
@property (strong, atomic, readonly) NSMutableDictionary * stores;

@end

@implementation ContactViewController

@synthesize announcement;
@synthesize hypeAnnouncementLabel;
@synthesize hypeInstancesTextField;
@synthesize tableView = _tableView;
@synthesize stores = _stores;

- (NSMutableDictionary *)stores
{
    @synchronized(self) {

        if (_stores == nil) {
            _stores = [NSMutableDictionary new];
        }

        return _stores;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setAnnouncement: [[UIDevice currentDevice] name]];
    
    NSString *labelText = [NSString stringWithFormat:@"Device: %@", [self announcement]];
    [self.hypeAnnouncementLabel setText:labelText];
    
    // If Hype starts successfully, the table should start displaying peers soon
    [self requestHypeToStart];
}

- (void)requestHypeToStart
{
    // Add self as an Hype observer
    [HYP addStateObserver:self];
    [HYP addNetworkObserver:self];
    [HYP addMessageObserver:self];

    NSData *announcementData = [self.announcement dataUsingEncoding:NSUTF8StringEncoding];
    [HYP setAnnouncement: announcementData];
    
    // Generate an app identifier in the HypeLabs dashboard (https://hypelabs.io/apps/),
    // by creating a new app. Copy the given identifier here.
    [HYP setAppIdentifier:@"{{app_identifier}}"];
    [HYP start];
    
    // Update the text label
    [self updateHypeInstancesLabel];
}

- (void)hypeDidStart
{
    NSLog(@"Hype started");
}

- (void)hypeDidStopWithError:(HYPError *)error
{
    NSLog(@"Hype stopped [%@]", [error description]);
}

- (void)hypeDidFailStartingWithError:(HYPError *)error
{
    NSLog(@"Hype failed starting [%@]", [error description]);
    
    NSString *errorMsg = [NSString stringWithFormat:@"Description: %@\nReason:%@\nSuggestion:%@", [error description], [error reason], [error suggestion]];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hype failed starting" message:errorMsg preferredStyle:UIAlertControllerStyleAlert];
  
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alertController addAction:defaultAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)hypeDidBecomeReady
{
    NSLog(@"Hype is ready");
    
    // Where're here due to a failed start request, try again
    [self requestHypeToStart];
}

- (void)hypeDidChangeState
{
    NSLog(@"Hype changed state to [%d] (Idle=0, Starting=1, Running=2, Stopping=3)", (int)[HYP state]);
}

- (BOOL)shouldResolveInstance:(HYPInstance *)instance
{
    // This method can be used to decide whether an instance is interesting
    return YES;
}

- (void)hypeDidFindInstance:(HYPInstance *)instance
{
    NSLog(@"Hype found instance: %@", instance.stringIdentifier);

    // Resolve instances that matter
    if ([self shouldResolveInstance:instance]) {
        [HYP resolveInstance:instance];
    }
}

- (void)hypeDidLoseInstance:(HYPInstance *)instance
                      error:(HYPError *)error
{
    NSLog(@"Hype lost instance: %@ [%@]", instance.stringIdentifier, error.description);

    // Clean up
    [self removeFromResolvedInstancesDict:instance];
}

- (void)hypeDidResolveInstance:(HYPInstance *)instance
{
    NSLog(@"Hype resolved instance: %@", instance.stringIdentifier);

    // This device is now capable of communicating
    [self addToResolvedInstancesDict:instance];
}

- (void)hypeDidFailResolvingInstance:(HYPInstance *)instance
                               error:(HYPError *)error
{
    NSLog(@"Hype failed resolving instance: %@ [%@]", instance.stringIdentifier, error.description);
}

- (void)hypeDidReceiveMessage:(HYPMessage *)message
                 fromInstance:(HYPInstance *)fromInstance
{
    NSLog(@"Hype got a message from: %@", fromInstance.stringIdentifier);
    
    Store * store = [self.stores objectForKey:fromInstance.stringIdentifier];
    
    // Storing the message triggers a reload update in the chat view controller
    [store addMessage:message isMessageReceived:YES];
    
    // The data is reloaded so the green circle indicator is shown for contacts that have new
    // messages. Reloading is probably an overkill, but the point is to maintain focus on how
    // the framework works.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });

}

- (void)hypeDidFailSendingMessage:(HYPMessageInfo *)messageInfo
                       toInstance:(HYPInstance *)toInstance
                            error:(HYPError *)error
{
    NSLog(@"Hype failed to send message: %lu [%@]", (unsigned long)messageInfo.identifier, error.description);
}

- (void)hypeDidSendMessage:(HYPMessageInfo *)messageInfo
                toInstance:(HYPInstance *)toInstance
                  progress:(float)progress
                  complete:(BOOL)complete
{
    NSLog(@"Hype is sending a message: %f", progress);
}

- (void)hypeDidDeliverMessage:(HYPMessageInfo *)messageInfo
                   toInstance:(HYPInstance *)toInstance
                     progress:(float)progress
                     complete:(BOOL)complete
{
    NSLog(@"Hype delivered a message: %f", progress);
}

- (NSString *)hypeDidRequestAccessTokenWithUserIdentifier:(NSUInteger)userIdentifier
{
    // Access the app settings (https://hypelabs.io/apps/) to find an access token to use here.
    return @"{{access_token}}";
}

- (void)addToResolvedInstancesDict:(HYPInstance*)instance
{
    [self.stores setObject:[Store storeWithInstance:instance]
                    forKey:instance.stringIdentifier];

    // Reloading the table reflects the change
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self updateHypeInstancesLabel];
    });
}

- (void)removeFromResolvedInstancesDict:(HYPInstance *)instance
{
    // Cleaning up is always a good idea. It's not possible to communicate with instances
    // that were previously lost.
    [self.stores removeObjectForKey:instance.stringIdentifier];

    // Reloading the table reflects the change
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self updateHypeInstancesLabel];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.stores count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactTableViewCell * aCell = [tableView dequeueReusableCellWithIdentifier:@"ContactTableViewCell"];

    // Assuming that order is not relevant
    Store * store = [self.stores.allValues objectAtIndex:indexPath.row];

    if (aCell == nil) {

        aCell = [ContactTableViewCell cellWithStore:store];
    }

    else {

        aCell.store = store;
    }

    // Configure the cell to display information from the found instance
    aCell.displayName.text = store.instance.stringIdentifier;
    aCell.details.text = [[NSString alloc] initWithData:store.instance.announcement encoding:NSUTF8StringEncoding];
    aCell.contentIndicator.hidden = !store.hasNewMessages;

    [aCell setNeedsLayout];

    return aCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ChatViewController * vc = [segue destinationViewController];

    // Pass the store along when the segue executes
    [vc setStore:((ContactTableViewCell *)sender).store];

    vc.instanceAnnouncement.text = [[NSString alloc] initWithData:vc.store.instance.announcement encoding:NSUTF8StringEncoding];
}

- (void)viewWillAppear:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)updateHypeInstancesLabel
{
    if (self.stores.count == 0){
        [hypeInstancesTextField setText:@"No Hype Devices Found"];
    }
    else {
        [hypeInstancesTextField setText:[NSString stringWithFormat:@"Hype Devices Found: %lu", (unsigned long) self.stores.count]];
    }
}

@end
