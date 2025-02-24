//
//  ViewController.m
//  Example-Mac-Storyboard
//
//  Created by Stuart Tevendale on 08/11/2023.
//

#import "ViewController.h"
#import "PlaybackManager.h"
#import "DetailViewController.h"
#import "DetailWindowController.h"

#import <CocoaUPnP/CocoaUPnP.h>


@interface ViewController () <UPPDiscoveryDelegate, NSTableViewDelegate, NSTableViewDataSource>
@property (strong, nonatomic) NSTimer *searchTimer;
@property (strong, nonatomic) NSMutableArray *devices;
@property (strong, nonatomic) NSString *selectedInterface;
@property (strong, nonatomic) PlaybackManager *playbackManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *interfaces = [SSDPServiceBrowser availableNetworkInterfaces];
    NSArray *interfaceNameArray = [interfaces allKeys];
    [networksPopup removeAllItems];
    
    // TODO: Set first item as currently selected interface
    for (NSString *interfaceName in interfaceNameArray) {
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:interfaceName action:@selector(popupDataTypeChanged:) keyEquivalent:@""];
        [menuItem setEnabled:YES];
        // Addition needed for Mac OS X 10.10 otherwise the menu items aren't enabled - worked on 10.9 without this
        [menuItem setTarget:self];
        [networksPopup.menu addItem:menuItem];
    }
    
    [[UPPDiscovery sharedInstance] addBrowserObserver:self];
    [self setupSearchTimer];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


- (void)setupSearchTimer
{
    self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                        target:self
                                                      selector:@selector(timerFired:)
                                                      userInfo:nil
                                                       repeats:YES];
    [self.searchTimer fire];
}

- (void)timerFired:(NSTimer *)timer
{
//    [[UPPDiscovery sharedInstance] startBrowsingForServices:@"ssdp:all" withInterface:_selectedInterface];
    
    // Look for media servers
    [[UPPDiscovery sharedInstance] startBrowsingForServices:@"urn:schemas-upnp-org:service:ContentDirectory:1" withInterface:_selectedInterface];
}

- (IBAction)popupDataTypeChanged:(id)sender {
    NSMenuItem *item = (NSMenuItem *)sender;
    NSString *selectedNetwork = item.title;
    NSLog(@"Popup Changed: %@", selectedNetwork);
    _selectedInterface = selectedNetwork;
    [[UPPDiscovery sharedInstance] forgetAllKnownDevices];
    [_devices removeAllObjects];
    [tableView reloadData];
    [self setupSearchTimer];
}



#pragma mark - UPPDiscoveryDelegate

- (void)discovery:(UPPDiscovery *)discovery didFindDevice:(UPPBasicDevice *)device
{
    NSLog(@"In - (void)discovery:(UPPDiscovery *)discovery didFindDevice:(UPPBasicDevice *)device");
    if ([self.devices containsObject:device]) {
        return;
    }

    [self.devices addObject:device];
    
    [tableView reloadData];
}

- (void)discovery:(UPPDiscovery *)discovery didRemoveDevice:(UPPBasicDevice *)device
{
    NSLog(@"In - (void)discovery:(UPPDiscovery *)discovery didRemoveDevice:(UPPBasicDevice *)device");
    if (![self.devices containsObject:device]) {
        return;
    }

    [self.devices removeObject:device];
    
    [tableView reloadData];
}

#pragma mark - Lazy Instantiation

- (NSMutableArray *)devices
{
    if (!_devices) {
        _devices = [NSMutableArray array];
    }

    return _devices;
}


#pragma  mark - NSTableViewDataSource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.devices count];
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:self];
    
    UPPBasicDevice *device = self.devices[row];
    
    NSString *cellText = [NSString stringWithFormat:@"%@ - %@", device.friendlyName , device.deviceType];
    
    [cellView.textField setStringValue:cellText];

    return cellView;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSLog(@"Selection Changed...");
    NSLog(@"Selected Row: %ld", tableView.selectedRow);
    id selectedDevice = [_devices objectAtIndex:tableView.selectedRow];
    NSLog(@"Device: %@", selectedDevice);
    
    if ([selectedDevice isKindOfClass:[UPPMediaRendererDevice class]]) {
        self.playbackManager.renderer = selectedDevice;
    }

    else if ([selectedDevice isKindOfClass:[UPPMediaServerDevice class]]) {
        NSString *objectId;
        
        
        NSStoryboard *sb = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
        
        DetailWindowController *detailWindowController = (DetailWindowController *)[sb instantiateControllerWithIdentifier:@"detailWindow"];
  
        detailWindowController.window.title = [selectedDevice friendlyName];
        
        
        detailWindowController.playbackManager = self.playbackManager;
        detailWindowController.device = selectedDevice;
        detailWindowController.objectId = objectId;

        [detailWindowController showWindow:self];

     }
}

@end
