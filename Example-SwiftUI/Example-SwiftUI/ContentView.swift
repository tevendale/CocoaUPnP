//
//  ContentView.swift
//  Example-SwiftUI
//
//  Created by Stuart Tevendale on 23/12/2023.
//

import SwiftUI

class UPNP : NSObject, UPPDiscoveryDelegate, ObservableObject
{
    @Published var devices: [UPPBasicDevice] = []
    
    func start() -> Void {
        UPPDiscovery.sharedInstance().addBrowserObserver(self)
    }
    
    // MARK: - UPPDiscoveryDelegate
    @objc func discovery(_ discovery: UPPDiscovery, didFind device: UPPBasicDevice) {
        print("Found device" + device.friendlyName)
        if self.devices.contains(device) {
            return
        }
        
        self.devices.append(device)
//        print(self.devices)
    }
    
    @objc func discovery(_ discovery: UPPDiscovery, didRemove device: UPPBasicDevice) {
        if !(self.devices.contains(device)) {
            return
        }
        
        if let i = self.devices.firstIndex(of: device) {
            self.devices.remove(at: i)
        }
    }
    
}

struct ContentView: View {
    
    @ObservedObject var upnpClass = UPNP()
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    @State private var selection: String?
    @State private var itemSelection: String!
    
    var playbackManager: PlaybackManager = PlaybackManager()
    @State var objectId: String? = nil
    @State var device: UPPMediaServerDevice? = nil
    @State var items: [UPPMediaItem] = []
//    @State var serverItems: [UPPMediaServerDevice] = []
    
    var body: some View {
        VStack {
            Table($upnpClass.devices, selection: $selection) {
                
                TableColumn("Name", value: \.friendlyName.wrappedValue)
                
                TableColumn("Type", value: \.deviceType.wrappedValue)
            }
            Table($items, selection: $itemSelection) {
                TableColumn("Item", value: \.itemTitle.wrappedValue)
            }
        }
        .padding()
        .onAppear() {
            upnpClass.start()
        }
        .onReceive(timer) { _ in
            UPPDiscovery.sharedInstance().startBrowsing(forServices: "ssdp:all"/*, withInterface: self.selectedInterface*/)
        }
        .onChange(of: itemSelection) { newValue in
            let arrayindex = self.itemSelection
            let item = items.filter() { arrayindex!.contains($0.id) }
            print(item[0].itemTitle ?? "")
            objectId = item[0].objectID
//            device = item[0] as? UPPMediaServerDevice
            items = []
            fetchChildren()

        }
        .onChange(of: selection) { newValue in
            print("Name changed to \(selection)!")
            if selection != nil {
                let selectedDevice = deviceForName(name: selection!)
                print (selectedDevice)
                if selectedDevice != nil {
                    if selectedDevice!.isKind(of: UPPMediaRendererDevice.self) {
                        self.playbackManager.renderer = selectedDevice as? UPPMediaRendererDevice
                    }
                    else if selectedDevice!.isKind(of: UPPMediaServerDevice.self) {
                        device = selectedDevice as? UPPMediaServerDevice
                        fetchChildren()
                    }
                }
            }
        }
    }
    
    func deviceForName(name: String) -> UPPBasicDevice? {
        
        for device in $upnpClass.devices {
            if device.friendlyName.wrappedValue == name {
                return device.wrappedValue
            }
        }
        return nil
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
            items.append(contentsOf: results)
//            self.tableView.reloadData()
        }
    }
    
    func titleFormMediaItem(item: UPPMediaItem) -> String {
        if item.objectClass == "object.item.audioItem.musicTrack" {
            let title:String = (item.trackNumber ?? "-1") + " - " + item.itemTitle
            
            return title
        }
        
        return item.itemTitle
    }
    
}

#Preview {
    ContentView()
}

extension UPPBasicDevice: Identifiable {
    public var id: String {
        self.friendlyName
    }
}

extension UPPMediaItem: Identifiable {
    public var id: String {
        self.objectID
    }
}
