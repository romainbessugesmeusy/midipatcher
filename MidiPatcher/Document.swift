//
//  Document.swift
//  MidiPatcher
//
//  Created by Romain Bessuges-Meusy on 08/05/2020.
//  Copyright © 2020 Romain Bessuges-Meusy. All rights reserved.
//

import Cocoa
import SwiftUI
import MIKMIDI

class Document: NSDocument {
     

    var data:Data?;
    var contentView:ContentView?;
    
    override init() {
        super.init()
    }
    
    override class var autosavesInPlace: Bool {
        return true
    }
    
    override func makeWindowControllers() {
        // Create the SwiftUI view that provides the window contents.
        contentView = ContentView()
        if(data != nil){
            contentView!.state.setData(self.data!)
        }
        
        // Create the window and set the content view.
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 560),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.contentView = NSHostingView(rootView: contentView!)
        let windowController = NSWindowController(window: window)
        self.addWindowController(windowController)
    }
    
    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
        return contentView?.state.getData() ?? Data();
        //throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.
        // If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
        self.data = data;
    }
    
    
}

