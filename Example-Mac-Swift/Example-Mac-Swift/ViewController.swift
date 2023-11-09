//
//  ViewController.swift
//  Example-Mac-Swift
//
//  Created by Stuart Tevendale on 09/11/2023.
//

import Cocoa



class ViewController: NSViewController, UPPDiscoveryDelegate, NSTableViewDelegate, NSTableViewDataSource  {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var networksPopup: NSPopUpButton!
    
    var searchTimer: Timer = Timer()
    var devices: [UPPBasicDevice] = []
    var selectedInterface = ""
    var playbackManager: PlaybackManager = PlaybackManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Set first item as currently selected interface
        let interfaces: Dictionary = SSDPServiceBrowser.availableNetworkInterfaces()
        let interfaceNameArray = interfaces.keys
        networksPopup.removeAllItems()
        for name in interfaceNameArray {
            networksPopup.addItem(withTitle: name as! String)
        }
        networksPopup.action = #selector(popupDataTypeChanged (_:))
        networksPopup.target = self
        
        UPPDiscovery.sharedInstance().addBrowserObserver(self)
        setupSearchTimer()
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
   @IBAction func popupDataTypeChanged(_ sender: NSPopUpButton) {
       self.selectedInterface = sender.titleOfSelectedItem ?? ""
       
       print("Selection changed: %s", sender.titleOfSelectedItem as Any)
       
       UPPDiscovery.sharedInstance().forgetAllKnownDevices()
       devices.removeAll()
       tableView.reloadData()
       setupSearchTimer()
       
        
    }
    
    func setupSearchTimer() {
        self.searchTimer = Timer(timeInterval: 5.0, target: self, selector: #selector(timerFired(timer: )), userInfo: nil, repeats: true)
        
        self.searchTimer.fire()
    }
    
    @IBAction func timerFired(timer: Timer) {
        UPPDiscovery.sharedInstance().startBrowsing(forServices: "ssdp:all", withInterface: self.selectedInterface)
    }
    
    // MARK: - UPPDiscoveryDelegate
    func discovery(_ discovery: UPPDiscovery, didFind device: UPPBasicDevice) {
        print("Found device" + device.friendlyName)
        if self.devices.contains(device) {
            return
        }
        
        self.devices.append(device)
        tableView.reloadData()
    }
    
    func discovery(_ discovery: UPPDiscovery, didRemove device: UPPBasicDevice) {
        if !(self.devices.contains(device)) {
            return
        }
        
        if let i = self.devices.firstIndex(of: device) {
            self.devices.remove(at: i)
        }
        
        tableView.reloadData()
    }
    
    // MARK: - NSTableViewDataSource methods
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.devices.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let cellView = tableView.makeView(withIdentifier:
                NSUserInterfaceItemIdentifier(rawValue: "AutomaticTableColumnIdentifier.0"),
                owner: self) as? NSTableCellView
            else {
                return nil
            }
         
        let device: UPPBasicDevice = self.devices[row]
        let cellText = device.friendlyName + " - " + device.deviceType
        
        cellView.textField?.stringValue = cellText
        return cellView
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        print ("Selection changed")
        let selectedDevice = self.devices[tableView.selectedRow];
        
        if selectedDevice.isKind(of: UPPMediaRendererDevice.self) {
            self.playbackManager.renderer = selectedDevice as? UPPMediaRendererDevice
            
        }
        else if selectedDevice.isKind(of: UPPMediaServerDevice.self) {

            let sb = NSStoryboard(name: "Main", bundle: nil)
            let detailWindowController:DetailWindowController = sb.instantiateController(withIdentifier: "detailWindow") as! DetailWindowController
            detailWindowController.window?.title = selectedDevice.friendlyName
            detailWindowController.playbackManager = self.playbackManager
            detailWindowController.device = selectedDevice as? UPPMediaServerDevice ?? nil
            
            detailWindowController.showWindow(self)
        }
    }

}

