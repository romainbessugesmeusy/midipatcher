//
//  MIDIPatch.swift
//  MidiPatcher
//
//  Created by Romain Bessuges-Meusy on 08/05/2020.
//  Copyright © 2020 Romain Bessuges-Meusy. All rights reserved.
//

import Foundation

struct MIDIPatch:Identifiable {
    var id:UUID = UUID()
    var title:String
    var trigger:MIDIPatchTrigger
    var ops:Array<MIDIPatchOperation>
}

struct MIDIPatchTrigger {
    var channel:Int?
    var controllerNumber:Int?
    var note:Int?
}

struct MIDIPatchOperation {
    var type:MIDIPatchOperationType;
    var value:Int
}

enum MIDIPatchOperationType:String {
    case changeNote = "changeNote"
    case transpose = "transpose"
    case changeChannel = "changeChannel"
    case changeControllerNumber = "changeControllerNumber"
    case invertControllerValue = "invertControllerValue"
    case ignore = "ignore"
}
