//
//  MIDIDeviceList.swift
//  MidiPatcher
//
//  Created by Romain Bessuges-Meusy on 08/05/2020.
//  Copyright © 2020 Romain Bessuges-Meusy. All rights reserved.
//

import SwiftUI
import MIKMIDI

struct MIDIDeviceList: View {
    
    @Binding var selectedDevice: MIKMIDIDevice?
    var devices:Array<MIKMIDIDevice> = []

    var body: some View {
        List(selection: $selectedDevice) {
            ForEach (devices, id: \.uniqueID) { device in
                MIDIDeviceRow(device: device).tag(device)
            }
        }
    }
}

struct MIDIDeviceList_Previews: PreviewProvider {
    static var previews: some View {
        Text("No preview")
    }
}
