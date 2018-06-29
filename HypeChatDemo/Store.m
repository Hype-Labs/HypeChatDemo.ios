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

#import "Store.h"

@interface Store ()

@property (atomic, readonly) NSMutableArray * messages;

@end

@implementation Store

@synthesize messages = _messages;
@synthesize lastReadIndex = _lastReadIndex;

- (instancetype)initWithInstance:(HYPInstance *)instance
{
    self = [super init];
    
    if (self) {
        
        _instance = instance;
        _lastReadIndex = 0;
    }
    
    return self;
}

+ (instancetype)storeWithInstance:(HYPInstance *)instance
{
    return [[self alloc] initWithInstance:instance];
}

- (NSMutableArray *)messages
{
    @synchronized(self) {
        
        if (_messages == nil) {
            _messages = [NSMutableArray new];
        }
        
        return _messages;
    }
}

- (void)addMessage:(HYPMessage *)message isMessageReceived:(BOOL)isMessageReceived
{
    [self.messages addObject:message];
    
    
    if (!isMessageReceived && self.lastReadIndex == self.messages.count-1) {
        self.lastReadIndex = self.messages.count; // Avoid NewContent indicator to be activated when the message to be added to the store was sent by this instance
    }
    
    if ([self.delegate respondsToSelector:@selector(store:didAddMessage:)]) {
        [self.delegate store:self
               didAddMessage:message];
    }
}

- (BOOL)hasNewMessages
{
    return self.lastReadIndex < self.messages.count;
}

- (NSArray *)allMessages
{
    return [NSArray arrayWithArray:self.messages];
}

@end
