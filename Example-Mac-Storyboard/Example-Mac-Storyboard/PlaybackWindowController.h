//
//  PlaybackWindowController.h
//  Example-Mac-Storyboard
//
//  Created by Stuart Tevendale on 08/11/2023.
//

#import <Cocoa/Cocoa.h>

@class UPPMediaItem;

NS_ASSUME_NONNULL_BEGIN

@interface PlaybackWindowController : NSWindowController

@property (strong, nonatomic) UPPMediaItem *item;

@end

NS_ASSUME_NONNULL_END
