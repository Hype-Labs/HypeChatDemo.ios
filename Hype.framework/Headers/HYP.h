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
#import <Hype/HYPMessageObserver.h>
#import <Hype/HYPNetworkObserver.h>
#import <Hype/HYPStateObserver.h>
#import <Hype/HYPTransportType.h>
#import <Hype/HYPInstance.h>
#import <Hype/HYPMessage.h>

/**
 * @abstract Identifier option key.
 * @discussion Hype automatically generates an identifier for each device
 * on the network. These identifiers, however, are meaningless to the
 * developer because they are only managed internally. This optional 
 * key allows setting a custom byte array of up to 8 bytes, giving the
 * developer some control over identifier generation. It's notable that
 * identifiers are always 16 bytes long, regardless of how many bytes 
 * are passed along with this key. Hype uses the rest of the available
 * space to store the realm and add randomness to the identifier, thus
 * guaranteeing uniqueness. As such, there's no risk of collisions in
 * using, say, user identifiers, even if they have several devices 
 * participating on the network. Doing so would help identify the user
 * as soon as an instance is found. If this key is not set, Hype
 * automatically generates an identifier for the local instance.
 */
FOUNDATION_EXPORT NSString * const HYPOptionIdentifierKey;

/**
 * @abstract Realm option key.
 * @discussion This key allows setting the realm for the local instance,
 * which is used for matching purposes. Realms are used to segregate the
 * network and optimizing the matching process. Access Hype's website to
 * generate a realm that is unique to this implementation. Realms are
 * mandatory and should be set using a string in hexadecimal format. The
 * framework will attempt to parse this string has such and will throw
 * an exception if that is not possible. Realms are 8 hexadecimal digits
 * long, and this is also validated.
 */
FOUNDATION_EXPORT NSString * const HYPOptionRealmKey;

/**
 * @abstract Enumeration of Hype states.
 * @discussion This enumeration provides a list of possible states Hype
 * can be in. The state the framework is in indicates what activities it's
 * performing and what events are to be expected. The state can be queried
 * with Hype's singleton instance propery -state.
 */
typedef NS_ENUM(NSUInteger, HYPState)
{
    /**
     * @abstract The framework is idle.
     * @discussion The framework is not publishing the device on the network
     * nor browsing for other devices being published. The device is not
     * participating on the network, nor is it expected to be so until the
     * framework is requested to start, so no activity is expected until then.
     * This state is not expected to change until further activity is
     * requested. The exception is when the framework has previously been
     * started, instances have been found, and it was explicitly requested
     * to stop. In that case I/O operations can still occur with previously
     * found instances. The fact that the device is not advertising itself
     * nor browsing for other devices still holds.
     */
    HYPStateIdle = 0,
    
    /**
     * @abstract The framework is starting.
     * @discussion The framework has been requested to start but the request 
     * is still being processed. This state changes as soon as Hype is either
     * actively publishing the device on the network or actively browsing for
     * other devices. Instances cannot be found on the network yet. A state
     * update is expected soon.
     */
    HYPStateStarting = 1,
    
    /**
     * @abstract The framework is running.
     * @discussion The framework is actively participating on the network,
     * meaning that it could be advertising itself, browsing for other
     * devices on the network, or both. The framework is considered to be
     * running if at least one of its transport types is as well. If
     * activity is not requested on the framework (such as stopping) this
     * state will change only if external factors trigger a change in
     * the adapter's state, such as the user turning the adapter off,
     * which will cause the framework to halt and become idle with an
     * error.
     */
    HYPStateRunning = 2,
    
    /**
     * @abstract The framework is stopping.
     * @discussion The framework is actively participating on the network, 
     * and the process to stop doing so has already begun but has yet not 
     * been completed. This means that at least one of the transports is
     * still stopping, although others might have already done so. This
     * state changes as soon as all of the framework's transports have
     * stopped. A state update is expected soon.
     */
    HYPStateStopping = 3
};

/**
 * @abstract Hype domestic instance.
 * @discussion This class is the main entry point for the Hype SDK. It 
 * provides facade access to the Hype service running on the background.
 * This class wrapps the domestic instance created for the host device.
 * Each app can only create a single instance, which is why class is a
 * singleton. This class allows users to listen to events on the created
 * instance by subscribing observers, as well as starting and stopping
 * the Hype services.
 */
@interface HYP : NSObject

/**
 * @abstract The framwork's state.
 * @discussion This property yields the framework's state, indicate what
 * kind of activity it's performing at any given moment.
 * @see HYPState
 */
@property (atomic, readonly) HYPState state;

/**
 * @abstract The local HYPInstance object.
 * @discussion This property yields the HYPInstance object associated with
 * the domestic instance, created on the host device. This property is nil
 * until the Hype framework is first requested to start. At that point, a
 * local identifier is generated and the realm queried from the Info.plist
 * file or start options. This object is then kept throughout the framework's
 * lifecycle.
 * @see HYPInstance
 */
@property (atomic, readonly) HYPInstance * domesticInstance;

/**
 * @abstract Getter for the framework's singleton instance.
 * @discussion This class method returns Hype's singleton instance. Any 
 * attempt to instantiate this class in any other way will result in an
 * exception being thrown. This method is thread safe and will return 
 * the same instance to all threads calling it concurrently.
 * @returns Hype's singleton instance (instance of HYP).
 */
+ (instancetype)instance;

/**
 * @abstract Adds a message observer.
 * @discussion After being added, the message observer will get notifications
 * for message states. Notifications will be triggered when messages are
 * received, when they fail delivery, or when a message is delivered. If the
 * observer has previously already been registered, it will not be registered
 * twice, and the method will do nothing.
 * @param messageObserver The message observer (HYPMessageObserver) to add.
 */
- (void)addMessageObserver:(id<HYPMessageObserver>)messageObserver;

/**
 * @abstract Removes a message observer.
 * @discussion This method removes a message observer (HYPMessageObserver) that
 * was previously registered with -addHypeMessageObserver:. If the observer
 * was not previously registered or has already been removed, this method
 * does nothing. After being removed, the observer will no longer get any
 * notifications from the SDK.
 * @param messageObserver The message observer (HPYMessageObserver) to remove.
 */
- (void)removeMessageObserver:(id<HYPMessageObserver>)messageObserver;

/**
 * @abstract Adds a network observer.
 * @discussion Network observers get notifications for network events, such
 * as instances being found and lost on the network. The network observer
 * (HYPNetworkObserver) being added will get notifications after a call
 * to this method. If the observer has already been registered, this method
 * does nothing, and the observer will not get duplicated events.
 * @param networkObserver The network observer (HYPNetworkObserver) to add.
 */
- (void)addNetworkObserver:(id<HYPNetworkObserver>)networkObserver;

/**
 * @abstract Removes a network observer.
 * @discussion This method removes a previously registered network observer
 * (HYPNetworkObserver). If the observer has not been registered or has
 * already been removed, this method does nothing. After being removed,
 * the observer will no longer get notifications from the SDK.
 * @param networkObserver The network observer (HYPNetworkObserver) to remove.
 */
- (void)removeNetworkObserver:(id<HYPNetworkObserver>)networkObserver;

/**
 * @abstract Adds a state observer.
 * @discussion State observers get notifications for Hype's state and
 * lifecycle events. If the observer has already been registered it will
 * not be registered twice, preventing the observer from getting duplicate
 * notifications.
 * @param stateObserver The state observer (HYPStateObserver) to register.
 */
- (void)addStateObserver:(id<HYPStateObserver>)stateObserver;

/**
 * @abstract Removes a state observer.
 * @discussion This method removes a previously registered state observer
 * (HYPStateObserver). If the observer is not present on the registry,
 * because it was not added or because it has already been removed, this
 * method does nothing. After being removed, the observer will no longer
 * get notifications from the SDK.
 * @param stateObserver The state observer (HYPStateObserver) to remove.
 */
- (void)removeStateObserver:(id<HYPStateObserver>)stateObserver;

/**
 * @abstract Starts all Hype services.
 * @discussion Calling this method requests the framework to start its 
 * services, by publishing itself on the network and browsing for other 
 * devices. In case of success, all observers will get a -hypeDidStart:
 * notification, indicating that the device is somehow participating on
 * the network. This might not mean that the device is both browsing and
 * advertising, but that it is participating in either or both ways. In
 * case of failure, the observers get a -hypeDidFailStarting:error:
 * notification. This is common if all adapters are off, for instance. At
 * that point, it's usuless trying to start the services again. Instead,
 * the implementation should wait for an observer notification indicating
 * that recovery is possible, with -hypeDidBecomeReady:. If the services
 * have already been requested to run but have not succeeded nor failed
 * (that is, the request is still being processed) this method does nothing.
 * If the services are already running, the observers get an immediate
 * notification indicating that the services have started as if they just
 * did (-hypeDidStart:). The options object allows passing custom 
 * configurations, such as HYPOptionRealmKey or HYPOptionIdentifierKey.
 * Some of this options (such as HYPOptionRealmKey) are mandatory, and the
 * framework throws an exception if not properly set. Others are optional,
 * and allow for fine tunning of the framework's behaviour. Future releases
 * will keep adding more options for further configuration habilities.
 * @param options An options object for configuring the session.
 */
- (void)startWithOptions:(NSDictionary *)options;

/**
 * @abstract Stops all Hype services.
 * @discussion Calling this method requests the framework to stop its
 * services by no longer publishing itself on the network nor browsing
 * for other instances. This does not imply previoulsy found instances
 * to be lost; ongoing operations should continue and communicating with
 * known instances should be possible, but the framework will no longer
 * find or be found by other instances participating on the network.
 */
- (void)stop;

/**
 * @abstract Sends a message to a given instance.
 * @discussion This method attempts to send a message to a given instance.
 * The instance must be a previously found and not lost instance, or else
 * this method fails with an error. It returns immediately (non blocking),
 * queues the data to be sent, and returns the message (HYPMessage) that 
 * was created for wrapping the data. That data structure is helpful for
 * tracking the progress of messages as they are being sent over the network.
 * The message or the data are not strongly kept by the framework. The data
 * is copied and kept while it's queued, but the memory is released as
 * its fragments are sent. If the data is needed for later use, it should
 * be kept at this point, or otherwise it won't be recoverable. Messages 
 * contain an identifier which can later be used to match events with the
 * original data. Progress notifications are issued to message observers 
 * (HYPMessageObserver). When listening to progress tracking notifications,
 * two concepts are important to distinguish: sending and deliverying. A 
 * message being sent (-hype:didSendMessage:toInstance:progress:complete:)
 * indicates that the data was buffered, but has not necessarily arrived to
 * its destination. Delivery (-hype:didDeliverMessage:toInstance:progress:complete:)
 * on the other hand, indicates that the content has reached its destination
 * and that has been acknowledged by the receiving instance. This
 * distinction is especially important in mesh, when the proxy device
 * may not be the same as the one the data is intented to. The trackProgress
 * argument indicates whether to track delivery. The data being queued to
 * the output stream (sent) is always notified, regardless of that setting.
 * Notice that passing YES to this parameter incurs extra overhead on the 
 * network, as it implies acknowledgements from the destination back to the
 * origin. If progress tracking is not needed, this should always be set to NO.
 * In case an error occurs that prevents the message from reaching the 
 * destination, the delegate gets a failure notification
 * (-hype:didFailSendingMessage:toInstance:error:) with an appropriate
 * error message describing the reasons. If a proper reason cannot be
 * determined, a probable one is used instead.
 * @param data The data to be sent.
 * @param toInstance The destination instance.
 * @param trackProgress Whether to track delivery progress.
 * @returns A message wrapper containing some metadata.
 */
- (HYPMessage *)sendData:(NSData *)data
              toInstance:(HYPInstance *)toInstance
           trackProgress:(BOOL)trackProgress;
/**
 * @abstract Sends a message to a given instance without tracking progress.
 * @discussion This method calls -sendData:toInstance:trackProgress: with
 * the progress tracking option set to NO. All other technicalities described
 * for that method also apply.
 * @param data The data to send.
 * @param toInstance The instance to send the data to.
 * @returns A message wrapper containing some metadata.
 * @see -sendData:toInstance:trackProgress:
 */
- (HYPMessage *)sendData:(NSData *)data
              toInstance:(HYPInstance *)toInstance;

@end
