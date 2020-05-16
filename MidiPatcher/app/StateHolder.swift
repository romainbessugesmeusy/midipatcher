//
//  StateHolder.swift
//  MidiPatcher
//
//  Created by Romain Bessuges-Meusy on 16/05/2020.
//  Copyright © 2020 Romain Bessuges-Meusy. All rights reserved.
//

import Foundation
import MIKMIDI
import SwiftyJSON

class StateHolder:ObservableObject {
    @Published var jsonText:String = "" {
        didSet {
            if let dataFromString = jsonText.data(using: .utf8, allowLossyConversion: false) {
                print("parseJSON")
                do {
                    json = try JSON(data: dataFromString)
                } catch {
                    json = nil
                }
            }
        }
    };
    @Published var json:JSON? {
        didSet {
            if(json != nil){
                print("convert JSON to struct")
                patches = json!.arrayValue.map({ (jsonPatch:JSON) -> MIDIPatch in
                    return MIDIPatch(
                        title: jsonPatch["title"].stringValue,
                        trigger: MIDIPatchTrigger(
                            channel: jsonPatch["trigger"]["channel"].int,
                            controllerNumber: jsonPatch["trigger"]["controllerNumber"].int,
                            note: jsonPatch["trigger"]["note"].int
                        ),
                        ops: jsonPatch["ops"].arrayValue.map({ (jsonOp:JSON) -> MIDIPatchOperation in
                            return MIDIPatchOperation(
                                type: MIDIPatchOperationType(rawValue: jsonOp["type"].stringValue) ?? MIDIPatchOperationType.ignore,
                                value: jsonOp["value"].numberValue.intValue
                            )
                        })
                    )
                })
            }
        }
    }
    @Published var patches:Array<MIDIPatch> = [] {
        didSet {
            print(patches);
        }
    }
    @Published var sourceName:String = "";
    @Published var selectedDevice:MIKMIDIDevice? { didSet {
        if(selectedDevice != nil){
            self.connectTo(device: selectedDevice!)
        }
        }}
    @Published var devices: Array<MIKMIDIDevice> = []
    @Published var matching:Bool = false;
    @Published var virtualDevice:VirtualMidiDevice = VirtualMidiDevice();
    @Published var isVirtualDeviceStarted:Bool = false;
    
    var connectionToken:Any?
    var connectedDevice:MIKMIDIDevice?;
    
    init(){
        devices = MIKMIDIDeviceManager.shared.availableDevices.filter({ (device:MIKMIDIDevice) -> Bool in
            return device.entities.count > 0;
        })
    }
    
    func setData(_ data:Data) -> Void {
        do {
            print(data);
            let doc = try JSON(data: data)
            sourceName = doc["sourceName"].stringValue
            jsonText = doc["patches"].rawString() ?? "[]";
        } catch {
            print("Could not process data");
            json = nil
        }
    }
    func getData() -> Data {
        var doc = JSON();
        doc["sourceName"].string = sourceName;
        if(json != nil){
            doc["patches"] = json!;
        } else {
            doc["patches"] = JSON("[]")
        }
        return doc.rawString()!.data(using: .utf8)!
    }
    
    func startVirtualDevice(){
        virtualDevice.start(withName: sourceName);
        isVirtualDeviceStarted = true
    }
    
    func stopVirtualDevice(){
        virtualDevice.stop();
        isVirtualDeviceStarted = false
    }
    
    func connectTo(device: MIKMIDIDevice) {
        if(connectedDevice != nil){
            disconnect()
        }
        
/*        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")*/
            Swift.print("Connecting to device", device.model!)
            do {
                self.connectionToken = try MIKMIDIDeviceManager.shared.connect(device) {
                    (sourceEndpoint:MIKMIDISourceEndpoint, command:Array<MIKMIDICommand>) in
                    self.handle(command: command)
                }
                self.connectedDevice = device;
            } catch {
                Swift.print("Could not connect to device")
            }
            /*DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
            }
        }*/
        
    }
    
    func shouldTrigger(command:MIKMIDICommand, trigger: MIDIPatchTrigger) -> Bool {
        
        // Filter by channel
        if(trigger.channel != nil && command is MIKMIDIChannelVoiceCommand && (command as! MIKMIDIChannelVoiceCommand).channel != trigger.channel! ) {
            return false;
        }
        
        // If it's a note event and it matches
        if(trigger.note != nil && command is MIKMIDINoteCommand && (command as! MIKMIDINoteCommand).note == UInt(trigger.note!)){
            return true;
        }
        
        if(trigger.controllerNumber != nil && command is MIKMIDIControlChangeCommand && (command as! MIKMIDIControlChangeCommand).controllerNumber == UInt(trigger.controllerNumber!)){
            return true;
        }
        
        // Random event
        return false;
    }
    
    
    func applyPatch(command:MIKMIDICommand, patch:MIDIPatch) -> MIKMIDICommand {
        
        if(command is MIKMIDINoteCommand){
            let noteCommand = (command as! MIKMIDINoteCommand);
            var note = noteCommand.note;
            var channel = noteCommand.channel;
            patch.ops.forEach { op in
                switch op.type {
                case .changeChannel:
                    channel = UInt8(op.value)
                    break;
                case .changeNote:
                    note = UInt(op.value)
                    break;
                case .transpose:
                    note += UInt(op.value)
                    break;
                default:
                    break;
                }
            }
            return MIKMIDINoteCommand(
                note: note,
                velocity: noteCommand.velocity,
                channel: channel,
                isNoteOn: noteCommand.isNoteOn,
                midiTimeStamp: noteCommand.midiTimestamp
            )
        }
        
        if(command is MIKMIDIControlChangeCommand) {
            let ccCommand = command as! MIKMIDIControlChangeCommand
            var channel = ccCommand.channel;
            var controllerNumber = ccCommand.controllerNumber;
            var controllerValue = ccCommand.controllerValue;
            patch.ops.forEach { op in
                switch op.type {
                case .changeChannel:
                    channel = UInt8(op.value)
                    break;
                case .changeControllerNumber:
                    controllerNumber = UInt(op.value)
                    break;
                case .invertControllerValue:
                    controllerValue = 127 - controllerValue;
                    break;
                default:
                    break;
                }
            }
            let patchedCommand = MIKMutableMIDIControlChangeCommand(
                controllerNumber: controllerNumber,
                value: controllerValue
            );
            patchedCommand.channel = channel;
            return patchedCommand;
        }
        return command;
    }
    
    /// The handle method is receiving an array of MIDI commands
    /// from the connectedDevice.
    ///
    /// For each one of them, it checks if they match the one or several
    /// of the patches' triggers that have been describred in the
    /// patches configuration JSON.
    func handle(command:Array<MIKMIDICommand>){
        
        var patched:Array<MIKMIDICommand> = [];
        
        for i in 0 ..< command.count {
            /// This flag is intended to be used as a visual indicator of
            /// a valid MIDI patch
            matching = false;
            for j in 0 ..< patches.count {
                if(self.shouldTrigger(command: command[i], trigger: patches[j].trigger)){
                    matching = true;
                    patched.append( self.applyPatch(command: command[i], patch: patches[j] ))
                } else {
                    patched.append(command[i])
                }
            }
        }
        
        if(virtualDevice.enabled){
            let packet = MIKMIDIPacketCreateFromCommands(command[0].midiTimestamp, patched)
            virtualDevice.send(packet: packet.pointee)
            MIKMIDIPacketFree(packet)
        }
        
        patched.removeAll();
    }
    
    func disconnect() {
        if(self.connectionToken != nil){
            print("Disconnecting", self.connectionToken!)
            MIKMIDIDeviceManager.shared.disconnectConnection(forToken: self.connectionToken!)
        }
        self.connectionToken = nil;
        self.connectedDevice = nil;
    }
    
    func refresh() {
        devices = MIKMIDIDeviceManager.shared.availableDevices.filter({ (device:MIKMIDIDevice) -> Bool in
            return device.entities.count > 0;
        })
    }
    
    
}
