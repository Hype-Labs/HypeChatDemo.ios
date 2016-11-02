//
// The MIT License (MIT)
// Copyright (c) 2016 Hype Labs Ltd
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
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

@interface ContactViewController () <HYPStateObserver, HYPNetworkObserver, HYPMessageObserver, UITableViewDataSource>

// The stores object keeps track of message storage associated with each instance (peer)
@property (strong, atomic, readonly) NSMutableDictionary * stores;
@property (strong, atomic) IBOutlet UITableView *tableView;

@end

@implementation ContactViewController

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
    
    // Request Hype to start when the view loads. If this is successful the table
    // should start displaying other peers soon. Notice that it's OK to request the
    // framework to start if it's already running, so this method can be called
    // several times.
    [self requestHypeToStart];
}

- (void)requestHypeToStart
{
    // Adding itself as an Hype state observer makes sure that the application gets
    // notifications for lifecycle events being triggered by the Hype framework. These
    // events include starting and stopping, as well as some error handling.
    [[HYP instance] addStateObserver:self];
    
    // Network observer notifications include other devices entering and leaving the
    // network. When a device is found all observers get a -hype:didFindInstance:
    // notification, and when they leave -hype:didLoseInstance:error: is triggered instead.
    [[HYP instance] addNetworkObserver:self];
    
    // Message notifications indicate when messages are sent (not available yet) or fail
    // to be sent. Notice that a message being sent does not imply that it has been
    // delivered, only that it has left the device. If considering mesh networking,
    // in which devices will be forwarding content for each other, a message being
    // means that its contents have been flushed out of the output stream, but not
    // that they have reached their destination. This, in turn, is what acknowledgements
    // are used for, but those have not yet available.
    [[HYP instance] addMessageObserver:self];
    
    // Requesting Hype to start is equivalent to requesting the device to publish
    // itself on the network and start browsing for other devices in proximity. If
    // everything goes well, the -hypeDidStart: delegate method gets called, indicating
    // that the device is actively participating on the network. The 00000000 realm is
    // reserved for test apps, so it's not recommended that apps are shipped with it.
    // For generating a realm go to https://hypelabs.io, login, access the dashboard
    // under the Apps section and click "Create New App". The resulting app should
    // display a realm number. Copy and paste that here.
    [[HYP instance] startWithOptions:@{
                                       HYPOptionRealmKey:@"00000000"
                                       }];
}

- (void)hypeDidStart:(HYP *)hype
{
    // At this point, the device is actively participating on the network. Other devices
    // (instances) can be found at any time and the domestic (this) device can be found
    // by others. When that happens, the two devices should be ready to communicate.
    NSLog(@"Hype started!");
}

- (void)hypeDidStop:(HYP *)hype
              error:(NSError *)error
{
    // The framework has stopped working for some reason. If it was asked to do so (by
    // calling -stop) the error parameter is nil. If, on the other hand, it was forced
    // by some external means, the error parameter indicates the cause. Common causes
    // include the user turning the Bluetooth and/or Wi-Fi adapters off. When the later
    // happens, you shouldn't attempt to start the Hype services again. Instead, the
    // framework triggers a -hypeDidBecomeReady: delegate method if recovery from the
    // failure becomes possible.
    NSLog(@"Hype stoped [%@]", [error localizedDescription]);
}

- (void)hypeDidFailStarting:(HYP *)hype
                      error:(NSError *)error
{
    // Hype couldn't start its services. Usually this means that all adapters (Wi-Fi
    // and Bluetooth) are not on, and as such the device is incapable of participating
    // on the network. The error parameter indicates the cause for the failure. Attempting
    // to restart the services is futile at this point. Instead, the implementation should
    // wait for the framework to trigger a -hypeDidBecomeReady: notification, indicating
    // that recovery is possible, and start the services then.
    NSLog(@"Hype failed starting [%@]", error.localizedDescription);
}

- (void)hypeDidBecomeReady:(HYP *)hype
{
    // This Hype delegate event indicates that the framework believes that it's capable
    // of recovering from a previous start failure. This event is only triggered once.
    // It's not guaranteed that starting the services will result in success, but it's
    // known to be highly likely. If the services are not needed at this point it's
    // possible to delay the execution for later, but it's not guaranteed that the
    // recovery conditions will still hold by then.
    [self requestHypeToStart];
}

- (void)hype:(HYP *)hype didFindInstance:(HYPInstance *)instance
{
    // Hype instances that are participating on the network are identified by a full
    // UUID, composed by the vendor's realm followed by a unique identifier generated
    // for each instance.
    NSLog(@"Found instance: %@", instance.stringIdentifier);
    
    // Instances should be strongly kept by some data structure. Their identifiers
    // are useful for keeping track of which instances are ready to communicate.
    [self.stores setObject:[Store storeWithInstsance:instance]
                    forKey:instance.stringIdentifier];
    
    // Reloading the table reflects the change
    [self.tableView reloadData];
}

- (void)hype:(HYP *)hype didLoseInstance:(HYPInstance *)instance
       error:(NSError *)error
{
    // An instance being lost means that communicating with it is no longer possible.
    // This usually happens by the link being broken. This can happen if the connection
    // times out or the device goes out of range. Another possibility is the user turning
    // the adapters off, in which case not only are all instances lost but the framework
    // also stops with an error.
    NSLog(@"Lost instance: %@ [%@]", instance.stringIdentifier, error.localizedDescription);
    
    // Cleaning up is always a good idea. It's not possible to communicate with instances
    // that were previously lost.
    [self.stores removeObjectForKey:instance.stringIdentifier];
    
    // Reloading the table reflects the change
    [self.tableView reloadData];
}

- (void)hype:(HYP *)hype didReceiveMessage:(HYPMessage *)message fromInstance:(HYPInstance *)instance
{
    NSLog(@"Got a message from: %@", instance.stringIdentifier);
    
    Store * store = [self.stores objectForKey:instance.stringIdentifier];
    
    // Storing the message triggers a reload update in the chat view controller
    [store addMessage:message];
    
    // The data is reloaded so the green circle indicator is shown for contacts that have new
    // messages. Reloading is probably an overkill, but the point is to maintain focus on how
    // the framework works.
    [self.tableView reloadData];
}

- (void)hype:(HYP *)hype didFailSendingMessage:(HYPMessageInfo *)messageInfo toInstance:(HYPInstance *)toInstance error:(NSError *)error
{
    // Sending messages can fail for a lot of reasons, such as the adapters
    // (Bluetooth and Wi-Fi) being turned off by the user while the process
    // of sending the data is still ongoing. The error parameter describes
    // the cause for the failure.
    NSLog(@"Failed to send message: %lu [%@]", (unsigned long)messageInfo.identifier, error.localizedDescription);
}

- (void)hype:(HYP *)hype didSendMessage:(HYPMessageInfo *)messageInfo toInstance:(HYPInstance *)toInstance progress:(float)progress complete:(BOOL)complete
{
    // A message being "sent" indicates that it has been written to the output
    // streams. However, the content could still be buffered for output, so it
    // has not necessarily left the device. This is useful to indicate when a
    // message is being processed, but it does not indicate delivery by the
    // destination device.
    NSLog(@"Message being sent: %f", progress);
}

- (void)hype:(HYP *)hype didDeliverMessage:(HYPMessageInfo *)messageInfo toInstance:(HYPInstance *)toInstance progress:(float)progress complete:(BOOL)complete
{
    // A message being delivered indicates that the destination device has
    // acknowledge reception. If the "done" argument is true, then the message
    // has been fully delivered and the content is available on the destination
    // device. This method is useful for implementing progress bars.
    NSLog(@"Message being delivered: %f", progress);
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
    
    // Configure the cell to display information from the found instance. The description is
    // a feature that has not yet been made available by the framework, which consists of
    // each peer putting an "announcement" on the network that helps identifying the
    // running instance.
    aCell.displayName.text = store.instance.stringIdentifier;
    aCell.details.text = @"Description not available";
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
    
    vc.instanceIdentifier.text = vc.store.instance.stringIdentifier;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

@end
