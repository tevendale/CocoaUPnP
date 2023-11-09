//
//  DetailWindow.m
//  Example-Mac
//
//  Created by Stuart Tevendale on 05/11/2023.
//

#import "DetailWindow.h"
#import "PlaybackManager.h"
#import "DetailViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <AVFAudio/AVFAudio.h>

#import <CocoaUPnP/CocoaUPnP.h>


@interface DetailWindow () <NSTableViewDelegate, NSTableViewDataSource>
@property (strong, nonatomic) IBOutlet NSTableView *tableView;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSTimer *testTimer;

@end

@implementation DetailWindow

- (id)initWithWindowNibName:(NSString *)nibNameOrNil device:(UPPMediaServerDevice *)device playbackManager:(PlaybackManager *)playbackManager objectId:(NSString * _Nullable)objectId {
    
    self = [super initWithWindowNibName:nibNameOrNil];
    if (self) {
        self.device = device;
        self.playbackManager = playbackManager;
        self.objectId = objectId;
        self.items = [NSMutableArray new];
    }
    return self;
}

- (void)windowDidLoad {
//    [self.items addObjectsFromArray:@[@"One", @"Two", @"Three", @"Four"]];
    self.window.title = [self.device friendlyName];
    
//    [_tableView reloadData];
    
//    [self fetchChildren];
    
    [self setupTestTimer];
}

- (void)setupTestTimer
{
    self.testTimer = [NSTimer scheduledTimerWithTimeInterval:3600.0
                                                        target:self
                                                      selector:@selector(timerFired:)
                                                      userInfo:nil
                                                       repeats:YES];
    [self.testTimer fire];
}

- (void)timerFired:(NSTimer *)timer
{
    NSLog(@"Timer Fired");
    NSLog(@"View has loaded: %d", self.contentViewController.viewLoaded);
    [self fetchChildren];
//    [self.testTimer invalidate];
//    [self.tableView reloadData];
}

- (void)fetchChildren
{
    UPPResponseBlock block = ^(NSDictionary *response, NSError *error) {
        if (response) {
            [self loadResults:response[@"Result"]];
        } else {
            NSLog(@"Error fetching results: %@", error);
        }
    };

    [[self.device contentDirectoryService]
     browseWithObjectID:self.objectId
     browseFlag:BrowseDirectChildren
     filter:@"dc:title,upnp:originalTrackNumber,res,res@duration"
     startingIndex:@0
     requestedCount:@0
     sortCritera:nil
     completion:block];
}

- (void)loadResults:(NSArray *)results
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@", results);
        [self.items addObjectsFromArray:results];
//        [self.items addObjectsFromArray:@[@"One", @"Two", @"Three", @"Four"]];
        [self.tableView reloadData];
//        [self.testTimer invalidate];
    });
}

- (NSString *)titleForMediaItem:(UPPMediaItem *)item
{
    if ([item.objectClass isEqualToString:@"object.item.audioItem.musicTrack"]) {
        NSString *title = [NSString stringWithFormat:@"%02d - %@",
                           [item.trackNumber intValue], item.itemTitle];
        return title;
    }

    return item.itemTitle;
}


#pragma  mark - NSTableViewDataSource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSRect rect = [_tableView rectOfColumn:0];
    return [self.items count];
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:self];
    
//    NSString *cellText = @"Cell Text Text";
    
//    UPPMediaItem *item = _items[row];
//    NSString *textLabel = [self titleForMediaItem:item];
//    NSString *detailTextLabel = [item duration];
//    
//    NSString *cellText = [NSString stringWithFormat:@"%@ - %@", textLabel, detailTextLabel];
    
//    [cellView.textField setStringValue:cellText];
    
    [cellView.textField setStringValue:self.items[row]];

    return cellView;
}

- (void)tableView:(NSTableView *)tableView
    didAddRowView:(NSTableRowView *)rowView
           forRow:(NSInteger)row {
    
    NSLog(@"Row view added: %ld", row);
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSLog(@"Selection Changed...");
    
    UPPMediaItem *item = self.items[_tableView.selectedRow];

    if ([item.objectClass isEqualToString:@"object.item.audioItem.musicTrack"]) {
        if (self.playbackManager) {
            [self.playbackManager playItem:item];
            return;
        }
        else { // Playback on local device
//            AVPlayer *player = [AVPlayer playerWithURL:item.resourceURLString];
//
//            // create a player view controller
//            AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
//            [self presentViewController:controller animated:YES completion:nil];
//            controller.player = player;
//            [player play];
        }
    }
    
    DetailWindow *detailWindowController = [[DetailWindow alloc] initWithWindowNibName:@"DetailWindow" device:self.device playbackManager:self.playbackManager objectId:item.objectID];
    
    [detailWindowController showWindow:self];
    

//    newViewController.title = item.itemTitle;


}

@end
