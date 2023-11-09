//
//  DetailViewController.m
//  Example-Mac-Storyboard
//
//  Created by Stuart Tevendale on 08/11/2023.
//

#import "DetailViewController.h"
#import "DetailWindowController.h"
#import "PlaybackWindowController.h"
#import "PlaybackManager.h"

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <AVFAudio/AVFAudio.h>

#import <CocoaUPnP/CocoaUPnP.h>


@interface DetailViewController () <NSTableViewDelegate, NSTableViewDataSource>
@property (strong, nonatomic) IBOutlet NSTableView *tableView;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSTimer *testTimer;
@property (strong, nonatomic) UPPMediaServerDevice *device;
@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) PlaybackManager *playbackManager;@property (strong, nonatomic) AVPlayer *audioPlayer;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    

}

- (void)viewDidAppear {
    
    self.items = [NSMutableArray new];

    // Get the Window Controller
    DetailWindowController *windowController = (DetailWindowController *)[self view].window.windowController;
    
    self.device = windowController.device;
    self.playbackManager = windowController.playbackManager;
    self.objectId = windowController.objectId;
    
    
    [self fetchChildren];
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
        [self.tableView reloadData];
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
    return [self.items count];
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:self];
    NSString *cellText = @"Cell Text";
    
    UPPMediaItem *item = _items[row];
    NSString *textLabel = [self titleForMediaItem:item];
    NSString *detailTextLabel = [item duration];
    
    if (detailTextLabel) {
        cellText = [NSString stringWithFormat:@"%@ - %@", textLabel, detailTextLabel];
    }
    else {
        cellText = textLabel;
    }

//    NSString *cellText = [NSString stringWithFormat:@"%@ - %@", textLabel, detailTextLabel];
    
    [cellView.textField setStringValue:cellText];
    
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
        else { // Open a new window and playback on local device
            
            NSStoryboard *sb = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
            
            PlaybackWindowController *playBackWindowController = (PlaybackWindowController *)[sb instantiateControllerWithIdentifier:@"playbackWindow"];
            
            playBackWindowController.item = item;
            
            [playBackWindowController showWindow:self];
            
            return;
        }
    }
        
    NSStoryboard *sb = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DetailWindowController *detailWindowController = (DetailWindowController *)[sb instantiateControllerWithIdentifier:@"detailWindow"];

    detailWindowController.playbackManager = self.playbackManager;
    detailWindowController.device = self.device;
    detailWindowController.objectId = item.objectID;
    detailWindowController.window.title = item.itemTitle;

    [detailWindowController showWindow:self];
}

@end
