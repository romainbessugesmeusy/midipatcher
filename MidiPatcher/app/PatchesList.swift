////
////  PatchesList.swift
////  MidiPatcher
////
////  Created by Romain Bessuges-Meusy on 09/05/2020.
////  Copyright © 2020 Romain Bessuges-Meusy. All rights reserved.
////
//
//import SwiftUI
//
//
//
//struct PatchesList: View {
//    @Binding var patches:Array<MIDIPatch>
//    var body: some View {
//        VStack {
//            ForEach (patches) { patch in
//                PatchRow(
//                    title: patch.title
//                )
//            }
//        }
//    }
//}
//
//struct PatchRow: View {
//
//    @Binding var title:String;
//
//    var body: some View {
//        HStack {
//            TextField("title", text: $title)
//        }
//    }
//}
//
//
//
//struct PatchesList_Previews: PreviewProvider {
//    static var previews: some View {
//        Text("No Preview")
//    }
//}
