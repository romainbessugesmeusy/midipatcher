//
//  VirtualMidiDevice.swift
//  MIDIBar
//
//  Created by Joshua Breeden on 11/6/16.
//  Copyright © 2016 Joshua Breeden. All rights reserved.
//

import Foundation
import CoreMIDI

class VirtualMidiDevice: ObservableObject {
    public var midiClient = MIDIClientRef()
    public var midiSource = MIDIEndpointRef()

    @Published public var enabled: Bool = false
    
    func start(withName: String){
        MIDIClientCreate(withName as CFString, nil, nil, &midiClient)
        MIDISourceCreate(midiClient, withName as CFString, &midiSource)
        self.enabled = true;
    }

    func stop(){
        MIDIClientDispose(midiClient)
        self.enabled = false;

    }
    func send(packet: MIDIPacket) {
        var packets = MIDIPacketList(numPackets: 1, packet: packet)
        MIDIReceived(midiSource, &packets)
    }
    func send(data: [UInt8]) {

        var packet = MIDIPacket()
        packet.data.0 = data[0]
        packet.data.1 = data[1]
        packet.data.2 = data[2]
        packet.length = 3
        packet.timeStamp = 0

        var packets = MIDIPacketList(numPackets: 1, packet: packet)

        MIDIReceived(midiSource, &packets)
    }
}
