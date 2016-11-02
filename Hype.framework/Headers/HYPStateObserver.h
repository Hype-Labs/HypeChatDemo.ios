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

/**
 * @abstract State observer.
 * @discussion State observers handle Hype state change events, such as the
 * framework starting, stopping, among others. This is helpful for tracking
 * the framework's lifecycle.
 */
@protocol HYPStateObserver <NSObject>

/**
 * @abstract Notification issued when Hype services start.
 * @discussion This notification is issued uppon a successful call to
 * -startWithOptions on the Hype singleton instance. When this notification
 * is triggered, Hype services are activelly being advertised on the network
 * and device matches can occur at any time.
 * @param hype The HYP singleton instance.
 */
- (void)hypeDidStart:(HYP *)hype;

/**
 * @abstract Notification issued when Hype services stop.
 * @discussion This notification is issued when the Hype services are requested
 * to stop, or otherwised forced to do so. If the services were forced to stop
 * (such as the adapter being turned of) the error instance will indicate the
 * cause of failure. If this is being triggered due to a successful call to
 * -stop, then the error will be set to nil.
 * @param hype The HYP singleton instance.
 * @param error An error (NSError) indicating the cause for the stoppage, if any.
 */
- (void)hypeDidStop:(HYP *)hype
              error:(NSError *)error;

/**
 * @abstract Notification issued when Hype services fail starting.
 * @discussion This notification is issued in response to a failed start request.
 * This means that the device is not actively participating on the network with
 * any transport nor trying to recover from the failure. If, at some point, the
 * framework finds indications that recovery is possible, a -hypeDidBecomeReady:
 * notification is issued. Hype services will not start unless explicitly told to.
 * @param hype The HYP singleton instance.
 * @param error An error (NSError) indicating the cause of failure.
 */
- (void)hypeDidFailStarting:(HYP *)hype
                      error:(NSError *)error;

/**
 * @abstract Notification issued when Hype services become ready after failing.
 * @discussion This notification is issued after a failed start request (that is,
 * after -startWithOptions: resulting in -hypeDidFailStarting:error:) and the
 * framework identifying that the cause of failure might not apply anymore.
 * Attempting to start the framework's services is not guaranteed to succeed 
 * as other causes for failure might exist, but they are likely to do so. It's
 * up to the receiver to decide whether the services should be started. This
 * event is only triggered once and Hype stops listenning to adapter state events.
 * @param hype The HYP singleton instance.
 */
- (void)hypeDidBecomeReady:(HYP *)hype;

@optional

/**
 * @abstract Notification issued when the HYP instance changes state.
 * @discussion This notification is issued whenenever the Hype instance
 * changes state. This method could be used as an alternative to -hypeDidStart:
 * and -hypeDidStop:error:, as it indicates when Hype enters into HYPStateRunning
 * and HYPStateIdle states, but also HYPStateStarting and HYPStateStopping.
 * Whether to use this method or the other specific notifications is a design
 * call, as both types of notification are guaranteed to always be triggered
 * when state changes occur. However, the more specific onStart(Hype) and
 * onStop(Hype, Error) are preferable. Notice, for instance, that this method
 * does not provide error information in case of stoppage. 
 * @param hype The HYP singleton instance.
 */
- (void)hypeDidChangeState:(HYP *)hype;

@end
