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

/**
 * @abstract Returns Hype's version in numeric form.
 * @discussion  The version number corresponds to the major version times
 * 100, plus the minor. For instance, version 1.5 would yield a value of 
 * 105. Beta versions, for which the major is zero, are indicated by the 
 * minor version alone, so 0.5 gives 5.
 * @returns Hype's version in numeric form.
 */
NSUInteger HYPVersion();

/**
 * @abstract Returns Hype's full version number in string form.
 * @discussion The version is given in a "major.minor.patch" format. These 
 * values could be individually queried using the respective HYPVersionMajor,
 * HYPVersionMinor, or HYPVersionPatch, in numeric format.
 * @returns Hype's full version number in string form.
 */
NSString * HYPVersionString();

/**
 * @abstract Returns Hype's major version.
 * @discussion Major versions indicate profound changes to the framework, 
 * such as new major features, stability, and so on.
 * @returns Hype's major version.
 */
NSUInteger HYPVersionMajor();

/**
 * @abstract Returns Hype's minor version.
 * @discussion The minor version indicates minor changes to the framework, 
 * including new minor features.
 * @returns Hype's minor version.
 */
NSUInteger HYPVersionMinor();

/**
 * @abstract Returns Hype's patch version.
 * @discussion The patch version corresponds to an approximation of the 
 * build count for the current release, so it jumps a lot. Higher patch 
 * values should indicate more bug fixes, although not necessarily more 
 * features.
 * @returns Hype's patch version.
 */
NSUInteger HYPVersionPatch();
