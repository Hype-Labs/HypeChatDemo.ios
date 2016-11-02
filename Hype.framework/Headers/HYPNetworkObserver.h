//
// Copyright (C) 2015 Hype Labs - All Rights Reserved
//
// NOTICE: All information contained herein is, and remains the property of
// Hype Labs. The intellectual and technical concepts contained herein are
// proprietary to Hype Labs and may be covered by U.S. and Foreign Patents,
// patents in process, and are protected by trade secret and copyright law.
// Dissemination of this information or reproduction of this material is
// strictly forbidden unless prior written permission is obtained from
// Hype Labs.
//

#import <Foundation/Foundation.h>

@class HYP;
@class HYPInstance;

/**
 * @abstract Network observer.
 * @discussion Network observers handle network events, such as instances
 * being found and lost on the network.
 */
@protocol HYPNetworkObserver <NSObject>

/**
 * @abstract Notification issued when an instance is found on the network.
 * @discussion This notification is issued when an instance is found on a
 * matching realm. At this point communication with the given instance should
 * already be possible, even though it will not be secure (not encrypted or
 * authenticated). The instance's announcement should help identify whether
 * the instance is interesting and, if so, a session should be started with
 * it. After the session is started communication will be encrypted. Your
 * app should keep track of found instances (and clear them when they are
 * lost) as these instances will be necessary in order to send messages.
 * @param hype The HYP singleton instance.
 * @param instance The found instance.
 */
- (void)hype:(HYP *)hype didFindInstance:(HYPInstance *)instance;

/**
 * @abstract Notification issued when an instance is lost on the network.
 * @discussion This notification is issued when a previously found instance
 * is lost, such as it going out of range, or the adapter being turned off.
 * The error parameter indicates the cause for the loss. When a cause cannot
 * be properly determined the framework uses a probable one instead, usually
 * indicating that the device appeared to go out of range.
 * @param hype The HYP singleton instance.
 * @param instance The lost instance.
 * @param error An error (NSError) describing the cause for the loss.
 */
- (void)hype:(HYP *)hype didLoseInstance:(HYPInstance *)instance
       error:(NSError *)error;

@end
