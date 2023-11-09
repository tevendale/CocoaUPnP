//
//  DetailViewController.swift
//  Example-Mac-Swift
//
//  Created by Stuart Tevendale on 09/11/2023.
//

import Cocoa

class DetailViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    var device: UPPMediaServerDevice? = nil
    var objectId: String? = nil
    var playbackManager: PlaybackManager? = nil
    var items: [UPPMediaItem] = []
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        let windowController: DetailWindowController = self.view.window?.windowController as! DetailWindowController
        
        self.device = windowController.device
        self.playbackManager = windowController.playbackManager
        self.objectId = windowController.objectId
        
        fetchChildren()
        
        
        
    }
    
    func fetchChildren() {
        let block:UPPResponseBlock = {(response: Optional<Dictionary<AnyHashable, Any>>, error: Optional<any Error> ) in
//        let block:UPPResponseBlock = {(response: NSDictionary, error: NSError ) in
            if response != nil {
                self.loadResults(results: response?["Result"] as! [UPPMediaItem])
            }
            else {
                print("Error fetching results:", error as Any)
            }
        }
        
        self.device!.contentDirectoryService().browse(withObjectID: self.objectId, browseFlag: BrowseDirectChildren, filter: "dc:title,upnp:originalTrackNumber,res,res@duration", startingIndex: 0 as NSNumber, requestedCount: 0 as NSNumber, sortCritera: nil, completion: block)
    }
    
    func loadResults(results: [UPPMediaItem]) {
        DispatchQueue.main.async {
            print(results)
            self.items.append(contentsOf: results)
            self.tableView.reloadData()
        }
    }
    
    func titleFormMediaItem(item: UPPMediaItem) -> String {
        if item.objectClass == "object.item.audioItem.musicTrack" {
            let title:String = (item.trackNumber ?? "-1") + " - " + item.itemTitle
            
            return title
        }
        
        return item.itemTitle
    }
    
    // MARK: - NSTableViewDataSource methods
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let cellView = tableView.makeView(withIdentifier:
                NSUserInterfaceItemIdentifier(rawValue: "AutomaticTableColumnIdentifier.0"),
                owner: self) as? NSTableCellView
            else {
                return nil
            }
        
        var cellText = "Cell Text"
         
        let item: UPPMediaItem = self.items[row] 
        
        let textLabel = titleFormMediaItem(item: item)
        let detailTextLabel = item.duration()
        
        if detailTextLabel != nil {
            cellText = textLabel + " - " + (detailTextLabel ?? "")
        }
        else {
            cellText = textLabel
        }
                
        cellView.textField?.stringValue = cellText
        return cellView
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        print ("Selection changed")
        
        let item: UPPMediaItem = self.items[tableView.selectedRow]
        
        if item.objectClass == "object.item.audioItem.musicTrack" {
            if self.playbackManager != nil {
                playbackManager!.play(item)
                return
            }
            else {
                // Play local
            }
        }
        
        let sb = NSStoryboard(name: "Main", bundle: nil)
        let detailWindowController:DetailWindowController = sb.instantiateController(withIdentifier: "detailWindow") as! DetailWindowController
        detailWindowController.window?.title = item.itemTitle
        detailWindowController.playbackManager = self.playbackManager!
        detailWindowController.device = self.device
        detailWindowController.objectId = item.objectID
        
        detailWindowController.showWindow(self)
    }
}
