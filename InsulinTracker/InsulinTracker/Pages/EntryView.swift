//
//  SettingsView.swift
//  InsulinTracker
//
//  Created by Eli Medina on 11/5/23.
//

import Foundation

import SwiftUI

struct EntryView: View
{
    var body: some View
    {
        ZStack {
            VStack {
                VStack{
                    Entry()
                }
            }
        }
        .padding()
    }
}

struct Entry: View
{
    var body: some View
    {
        VStack{
            HStack{
                    Text("Entry Page.")
                    Text("More Entry")
            }
        }.padding(.bottom)
    }
    
}
