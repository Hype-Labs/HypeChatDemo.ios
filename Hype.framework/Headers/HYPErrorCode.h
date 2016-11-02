//
// Copyright (C) 2015 Hype Labs - All Rights Reserved
// 
// NOTICE: All information contained herein is, and remains the property of Hype
// Labs. The intellectual and technical concepts contained herein are proprietary
// to Hype Labs and may be covered by U.S. and Foreign Patents, patents in process,
// and are protected by trade secret and copyright law. Dissemination of this
// information or reproduction of this material is strictly forbidden unless prior
// written permission is obtained from Hype Labs.
//
// DISCLAIMER: This file is automatically (re)generated during the Hype framework's
// build process. Any changes made to it will be overwritten.
//

#include <Foundation/Foundation.h>

/**
 * @abstract Enumeration of error codes.
 * @discussion Lists and documents error codes implemented by the framework.
 */
typedef NS_ENUM(NSUInteger, HYPErrorCode) {

    /**
     * @abstract An unknown error occurred.
     * @discussion An unknown error occurred and probably few details exist on what
     * went wrong.
     */
    HYPErrorCodeUnknown = 1051,

    /**
     * @abstract The adapter is disabled.
     * @discussion An operation could not be completed because the adapter is off.
     * Implementations must not attempt to turn it on, and instead recommend the
     * user to do so through recovery suggestions. When applicable, implementations
     * should subscribe to adapter state changes and attempt recovery when the
     * adapter is known to be on, after asking a delegate whether they should.
     */
    HYPErrorCodeAdapterDisabled = 1101,

    /**
     * @abstract The adapter is denying permission.
     * @discussion An operation could not be completed because adapter activity has
     * not been authorized by the user and the operating system is denying
     * permission. Recovery suggestions should advise the user to authorize
     * activity on the adapter.
     */
    HYPErrorCodeAdapterUnauthorized = 1102,

    /**
     * @abstract The adapter is not supported.
     * @discussion The implementation is requesting activity on an adapter that is
     * not supported by the current platform. Recovery is not possible. Recovery
     * suggestions should recommend the user to update their systems or contact the
     * manufacturer.
     */
    HYPErrorCodeAdapterNotSupported = 1103,

    /**
     * @abstract The adapter is busy.
     * @discussion An operation cannot be completed because the adapter is busy
     * doing something else or the implementation is not allowing it to overlap
     * with other ongoing activities.
     */
    HYPErrorCodeAdapterBusy = 1104,

    /**
     * @abstract A protocol has been violated.
     * @discussion A remote peer failed to comply with a protocolar specification
     * and the implementation is rejecting to communicate with it.
     */
    HYPErrorCodeProtocolViolation = 1151,

    /**
     * @abstract Not connected.
     * @discussion An operation has failed due to a connection not having
     * previously been established. The implementation should first attempt to
     * connect.
     */
    HYPErrorCodeNotConnected = 1201,

    /**
     * @abstract Not connectable.
     * @discussion A connection request has failed because the peer is not
     * connectable. Implementations should not reattempt to connect.
     */
    HYPErrorCodeNotConnectable = 1202,

    /**
     * @abstract Connection timeout.
     * @discussion An operation failed because the connection timed out.
     */
    HYPErrorCodeConnectionTimeout = 1203,

    /**
     * @abstract A stream is closed.
     * @discussion An operation failed because the stream is not open. The
     * implementation should first attempt to open it.
     */
    HYPErrorCodeStreamNotOpen = 1251
};

