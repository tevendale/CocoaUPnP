//
//  PlaybackViewController.m
//  Example-Mac-Storyboard
//
//  Created by Stuart Tevendale on 08/11/2023.
//

#import "PlaybackViewController.h"
#import "PlaybackWindowController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <AVFAudio/AVFAudio.h>

#import <CocoaUPnP/CocoaUPnP.h>


@interface PlaybackViewController ()

@property (strong, nonatomic) AVPlayer *audioPlayer;
@property (strong, nonatomic) IBOutlet NSButton *playButton;
@property (strong, nonatomic) IBOutlet NSButton *stopButton;
@property (strong, nonatomic) IBOutlet NSTextField *time;
@property (strong, nonatomic) UPPMediaItem *item;
@property (strong, nonatomic) id timeObserverToken;

@end

@implementation PlaybackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}


- (void)viewDidAppear {
    PlaybackWindowController *playbackWindow = (PlaybackWindowController *)[self view].window.windowController;
    self.item = playbackWindow.item;
    
    NSString *resourceString = self.item.resources[0].resourceURLString;
    NSURL *resourceURL = [NSURL URLWithString:resourceString];
   
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:resourceURL options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:avAsset];
    self.audioPlayer = [AVPlayer playerWithPlayerItem:playerItem];
    
    [self addPeriodicTimeObserver];
    
    [self.audioPlayer play];
}

- (void)viewWillDisappear {
    [self removeBoundaryTimeObserver];
}

- (IBAction)playClicked: (id) sender {
    NSLog(@"Play clicked");
    [self.audioPlayer play];
}
- (IBAction)stopClicked: (id) sender {
    NSLog(@"Stop clicked");
    [self.audioPlayer pause];
}

- (void)addPeriodicTimeObserver {
    
    // Invoke callback every half second
    CMTime interval = CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);
    // Queue on which to invoke the callback
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    __weak typeof(self) weakSelf = self;
    // Add time observer
    self.timeObserverToken = [self.audioPlayer addPeriodicTimeObserverForInterval:interval
                                                  queue:mainQueue
                                             usingBlock:^(CMTime time) {
            // Use weak reference to self
            // Update player transport UI
            NSUInteger dTotalSeconds = CMTimeGetSeconds(time);

            NSUInteger dHours = floor(dTotalSeconds / 3600);
            NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
            NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);

            NSString *videoDurationText = [NSString stringWithFormat:@"%i:%02i:%02i",dHours, dMinutes, dSeconds];
            [weakSelf.time setStringValue:videoDurationText];
        }];
}

- (void)removeBoundaryTimeObserver {
    if (self.timeObserverToken) {
        [self.audioPlayer removeTimeObserver:self.timeObserverToken];
        self.timeObserverToken = nil;
    }
}

@end
