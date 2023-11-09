//
//  DetailWindowController.swift
//  Example-Mac-Swift
//
//  Created by Stuart Tevendale on 09/11/2023.
//

import Cocoa

class DetailWindowController: NSWindowController {
    
    var device: UPPMediaServerDevice? = UPPMediaServerDevice()
    var objectId: String? = nil
    var playbackManager: PlaybackManager = PlaybackManager()


    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}
