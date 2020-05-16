//
//  ContentView.swift
//  MidiPatcher
//
//  Created by Romain Bessuges-Meusy on 08/05/2020.
//  Copyright © 2020 Romain Bessuges-Meusy. All rights reserved.
//

import SwiftUI
import MIKMIDI
import SwiftyJSON

struct ContentView: View {
    
    @State var isEditing:Bool = false;
    @ObservedObject var virtualDevice:VirtualMidiDevice = VirtualMidiDevice();
    @ObservedObject var state:StateHolder = StateHolder();
    
    var body: some View {
        VStack {
            Text("Choose a MIDI Device to proxy").bold().font(.callout)
            MIDIDeviceList(
                selectedDevice: $state.selectedDevice,
                devices: state.devices
            )
            Text("Create a Virtual MIDI source").bold().font(.callout)
            HStack {
                HStack() {
                    Text("MIDI Source Name")
                        .font(.caption)
                    TextField("MIDI Source Name", text: $state.sourceName)
                }.padding(.leading, 4)
                if (!state.isVirtualDeviceStarted){
                    Button(action: {
                        self.state.startVirtualDevice();
                    }) { Text("Start Virtual Instrument")}
                } else {
                    Button(action: {
                        self.state.stopVirtualDevice();
                    }) { Text("Stop Virtual Instrument")}
                }
            }.padding(.all, 10)
            HStack() {
                Button(action: {
                    self.state.refresh()
                }) {
                    Text("Refresh device list")
                }
                Button(action: {
                    self.isEditing = !self.isEditing;
                }) {
                    Text(isEditing ? "Close Editor" : "Open Editor")
                }
            }.padding(.all, 10)
            if (isEditing){
                VStack {
                    MultilineTextView(text: $state.jsonText)
                }
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Text("No Preview")
    }
}
