//
//  SettingsView.swift
//  InsulinTracker
//
//  Created by Eli Medina on 11/5/23.
//

import Foundation

import SwiftUI

struct SettingsView: View
{
    var body: some View
    {
        ZStack {
            VStack {
                VStack{
                    Settings()
                }
            }
        }
        .padding()
    }
}

struct Settings: View
{
    var body: some View
    {
        VStack{
            HStack{
                    Text("Settings Page.")
                    Text("More settings")
            }
        }.padding(.bottom)
    }
    
}
