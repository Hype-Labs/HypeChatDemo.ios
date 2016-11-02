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
#import "HYPErrorCode.h"

/**
 * @abstract Hype's error domain.
 * @discussion Error domains exist to seggregate error codes. Each domain
 * is associated with a set of error codes, so the code is meaningless 
 * unless the domain is checked. Hype's error domain indicates error
 * codes that are managed by the Hype framework.
 */
FOUNDATION_EXPORT NSString * const HYPErrorDomain;

/**
 * @abstract Describes an error in an utility format.
 * @discussion This function is used to describe errors for logging purposes.
 * It includes the error code localized description.
 */
FOUNDATION_EXPORT NSString * HYPDescribeError(NSError * error);
