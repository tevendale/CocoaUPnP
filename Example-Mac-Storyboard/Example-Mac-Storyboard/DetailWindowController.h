//
//  DetailWindowController.h
//  Example-Mac-Storyboard
//
//  Created by Stuart Tevendale on 08/11/2023.
//

#import <Cocoa/Cocoa.h>

@class PlaybackManager;
@class UPPMediaServerDevice;

NS_ASSUME_NONNULL_BEGIN

@interface DetailWindowController : NSWindowController

@property (strong, nonatomic) UPPMediaServerDevice *device;
@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) PlaybackManager *playbackManager;

@end

NS_ASSUME_NONNULL_END
