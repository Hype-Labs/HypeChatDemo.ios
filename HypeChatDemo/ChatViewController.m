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

#import "ChatViewController.h"
#import "MessageTableViewCell.h"

#import <Hype/Hype.h>

@interface ChatViewController () <UITableViewDataSource, StoreDelegate>

@end

@implementation ChatViewController

@synthesize store = _store;

- (IBAction)didTapSendButton:(id)sender
{
    NSString * text = self.textView.text;
    
    if (text.length > 0) {
        
        // When sending content there must be some sort of protocol that both parties
        // understand. In this case, we simply send the text encoded in UTF8. The data
        // must be decoded when received, using the same encoding.
        NSData * data = [text dataUsingEncoding:NSUTF8StringEncoding];
        
        HYPMessage * message = [HYP sendData:data
                                             toInstance:self.store.instance];
        
        // Clear the input view
        self.textView.text = @"";
            
        // Adding the message to the store updates the table view
        [self.store addMessage:message isMessageReceived:NO];
    }
}

- (void)store:(Store *)store didAddMessage:(HYPMessage *)message
{
    // Reloads the data and scrolls the table to the bottom. The UX for this is not
    // very good if there are not enough messags to fill the table, but it's nice
    // otherwise.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messageDisplay reloadData];
        [self.messageDisplay scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.store.allMessages.count - 1 inSection:0]
                                   atScrollPosition:UITableViewScrollPositionBottom
                                           animated:YES];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *announcement = [[NSString alloc] initWithData:self.store.instance.announcement encoding:NSUTF8StringEncoding];
    [self.instanceAnnouncement setText:announcement];
    [self.messageDisplay setDataSource:self];
}

- (Store *)store
{
    return _store;
}

- (void)setStore:(Store *)store
{
    _store = store;
    _store.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    // Sets all messages as read
    self.store.lastReadIndex = self.store.allMessages.count;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.store.allMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTableViewCell * aCell = [tableView dequeueReusableCellWithIdentifier:@"MessageTableViewCell"];
    HYPMessage * message = [self.store.allMessages objectAtIndex:indexPath.row];
    
    if (aCell == nil) {
        
        aCell = [MessageTableViewCell cellWithMessage:message];
    }
    
    else {
        
        aCell.message = message;
    }
    
    // Initialize the cell
    aCell.textView.text = [[NSString alloc] initWithData:message.data
                                                encoding:NSUTF8StringEncoding];
    
    return aCell;
}

- (IBAction)didRecognizeTapGesture:(id)sender
{
    [self.textView resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -keyboardSize.height;
        self.view.frame = f;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

@end
