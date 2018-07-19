//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGContentProtectionConstants.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  When attempting to play a media, the system (whether it is the application itself or an AirPlay receiver) first
 *  attempts to play the stream with known rules (e.g. simple HLS stream over HTTP or FairPlay skd:// extraction).
 *  When it gets stuck on URL it cannot manage, it asks the asset resource loader delegate (if any has been set)
 *  for help.
 *
 *  In most cases this mechanism should work fine. In some cases (e.g. Akamai URL with missing token), and on a
 *  remote receiver, the receiver will not branch to the resource loader without help, as it thinks the URL is
 *  playable. To force the resource loader to be asked for help, we introduce the concept of routing URLs, which
 *  are URLs guaranteed to force any player (whether local or distant) to ask the proper resource loader delegate
 *  for help.
 *
 *  These URLs, though readable, should be treated as opaque URLs and converted back and forth using the methods
 *  provided in this file.
 */

/**
 *  Convert a URL to a routing URL.
 */
OBJC_EXPORT NSURL *SRGContentProtectionRoutingURL(NSURL *URL, SRGContentProtection contentProtection);

/**
 *  Converts back a routing URL to its original routed URL. 
 */
OBJC_EXPORT NSURL * _Nullable SRGContentProtectionRoutedURL(NSURL *routingURL, SRGContentProtection contentProtection);

NS_ASSUME_NONNULL_END
