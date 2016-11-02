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

@class HYPMessage;

/**
 * @abstract Message metadata.
 * @discussion This class is used to hold message metadata. At this point,
 * it only includes the message identifier, but this will change with future
 * releases. It's mostly useful to associate messages with the metadata, as
 * Hype notifications usually use instances of this class and not HYPMessage.
 * This is motivated by the fact that HYPMessage holds the message's payload,
 * which would consume more memory.
 */
@interface HYPMessageInfo : NSObject

/**
 * @abstract Message identifier.
 * @discussion This identifier is used to keep track of delivery state of
 * messages sent of the network. Each message is assigned a unique identifier.
 */
@property (atomic, readonly) NSUInteger identifier;

/**
 * @abstract Initializes the instance.
 * @discussion This method initilizes the instance with the given identifier.
 * @param identifier The identifier to assign.
 */
- (instancetype)initWithIdentifier:(NSUInteger)identifier;

/**
 * @abstract Compares two HYPMessageInfo instances.
 * @discussion This method returns YES if the two instances (self and
 * messageInfo) have the same identifier. It returns NO otherwise.
 * @return Whether the message and the message metadata have the same identifier.
 */
- (BOOL)isEqualToMessageInfo:(HYPMessageInfo *)messageInfo;

@end
