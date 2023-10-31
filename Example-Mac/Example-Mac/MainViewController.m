//
//  MainViewController.m
//  Example-Mac
//
//  Created by Stuart Tevendale on 30/10/2023.
//

#import "MainViewController.h"

#import <CocoaUPnP/CocoaUPnP.h>

@interface MainViewController () <UPPDiscoveryDelegate, NSTableViewDelegate, NSTableViewDataSource>
@property (strong, nonatomic) NSTimer *searchTimer;
@property (strong, nonatomic) NSMutableArray *devices;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    NSDictionary *interfaces = [SSDPServiceBrowser availableNetworkInterfaces];
    NSArray *interfaceNameArray = [interfaces allKeys];
    [networksPopup removeAllItems];
    
    for (NSString *interfaceName in interfaceNameArray) {
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:interfaceName action:@selector(popupDataTypeChanged:) keyEquivalent:@""];
        [menuItem setEnabled:YES];
        // Addition needed for Mac OS X 10.10 otherwise the menu items aren't enabled - worked on 10.9 without this
        [menuItem setTarget:self];
        [networksPopup.menu addItem:menuItem];
    }
    
    [textField setStringValue:@"Some Text"];
    
    [[UPPDiscovery sharedInstance] addBrowserObserver:self];
    [self setupSearchTimer];
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
    [[UPPDiscovery sharedInstance] startBrowsingForServices:@"ssdp:all"];
}

- (IBAction)popupDataTypeChanged:(id)sender {
    NSMenuItem *item = (NSMenuItem *)sender;
    NSLog(@"Popup Changed: %@", item.title);
}



#pragma mark - UPPDiscoveryDelegate

- (void)discovery:(UPPDiscovery *)discovery didFindDevice:(UPPBasicDevice *)device
{
    if ([self.devices containsObject:device]) {
        return;
    }

    [self.devices addObject:device];
    
    [tableView reloadData];
}

- (void)discovery:(UPPDiscovery *)discovery didRemoveDevice:(UPPBasicDevice *)device
{
    if (![self.devices containsObject:device]) {
        return;
    }

    NSInteger row = [self.devices indexOfObject:device];
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
    
}

@end
