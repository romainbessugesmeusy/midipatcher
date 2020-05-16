//
//  MidiDeviceRow.swift
//  MidiPatcher
//
//  Created by Romain Bessuges-Meusy on 08/05/2020.
//  Copyright © 2020 Romain Bessuges-Meusy. All rights reserved.
//

import SwiftUI
import MIKMIDI

struct MIDIDeviceRow: View {
    var device: MIKMIDIDevice
    var body: some View {
        VStack(alignment: .leading) {
            Text(device.model!)
                .fontWeight(.bold)
                .truncationMode(.tail)
                .frame(minWidth: 20)
            Text(device.manufacturer!)
                .font(.caption)
                .opacity(0.625)
                .truncationMode(.middle)
        }
        .padding(.vertical, 4)
    }
}

struct MIDIDeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        Text("Preview unavailable")
    }
}
