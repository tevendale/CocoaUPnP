//
//  MainViewController.h
//  Example-Mac
//
//  Created by Stuart Tevendale on 30/10/2023.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainViewController : NSViewController {
    
    IBOutlet NSTextField *textField;
    IBOutlet NSTableView *tableView;
    IBOutlet NSPopUpButton *networksPopup;
    
   
    
}

@end

NS_ASSUME_NONNULL_END
