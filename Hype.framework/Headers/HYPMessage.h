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

#import <Hype/HYPMessageInfo.h>

/**
 * @abstract Represents a message sent over the network.
 * @discussion Messages are abstract entities that help keeping track of
 * data as it is sent over the network, by holding a unique identifier.
 * The identifier is actually held by the underlying HYPMessageInfo
 * instance (-info), but the HYPMessage class provides dynamic access
 * to that attribute. This is mostly motivated by the fact that Hype
 * does not keep messages for memory purposes. As such, it's up to 
 * the developer to hold or discard the data as needed. Instead,
 * HYPMessageInfo instances are used to keep track of the state of
 * any given HYPMessage.
 */
@interface HYPMessage : NSObject

/**
 * @abstract Message data.
 * @discussion The data holds the content that was sent or received with a
 * given message.
 */
@property (atomic, readonly) NSData * data;

/**
 * @abstract The message's identifier.
 * @discussion This property uses dynamic storage to access the identifier
 * from the underlying HYPMessageInfo instance. It returns an identifier
 * that has been uniquely assigned to this message.
 */
@property (atomic, readonly) NSUInteger identifier;

/**
 * @abstract Message metadata.
 * @discussion Instances of HYPMessageInfo hold message metadata. Currently,
 * this only includes the message's identifier, but future releases will
 * use this for other purposes. Instances of HYPMessage compare equally to
 * instances of HYPMessageInfo if they hold the same identifier. That is,
 * calling [message isEqual:message.info] always returns YES. This is useful
 * for keeping track of messages in data structures (such as NSDictionary)
 * when only the HYPMessageInfo instance is made available by the framework.
 * The two instances also hash to the same value, which is always the
 * message's identifier.
 */
@property (atomic, readonly) HYPMessageInfo * info;

/**
 * @abstract Initializer.
 * @discussion Initializes a message object with the given parameters.
 * @param info Message metadata.
 * @param data The data to associate the message with.
 */
- (instancetype)initWithInfo:(HYPMessageInfo *)info
                        data:(NSData *)data;

/**
 * @abstract Compares two HYPMessage instances.
 * @discussion This method returns YES if the two instances (self and message)
 * have the same message identifier. It returns NO otherwise.
 * @param message The HYPMessage instance to compare.
 * @return Whether the two messages have equal identifier.
 */
- (BOOL)isEqualToMessage:(HYPMessage *)message;

@end
