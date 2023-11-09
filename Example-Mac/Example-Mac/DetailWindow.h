//
//  DetailWindow.h
//  Example-Mac
//
//  Created by Stuart Tevendale on 05/11/2023.
//

#import <Cocoa/Cocoa.h>

@class PlaybackManager;
@class UPPMediaServerDevice;

NS_ASSUME_NONNULL_BEGIN

@interface DetailWindow : NSWindowController {
}

@property (strong, nonatomic) UPPMediaServerDevice *device;
@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) PlaybackManager *playbackManager;

- (id)initWithWindowNibName:(NSString *)nibNameOrNil device:(UPPMediaServerDevice *)device playbackManager:(PlaybackManager *)playbackManager objectId:(NSString * _Nullable)objectId;


@end

NS_ASSUME_NONNULL_END
