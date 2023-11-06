//
//  SettingsView.swift
//  InsulinTracker
//
//  Created by Eli Medina on 11/5/23.
//

import Foundation

import SwiftUI

struct ProfileView: View
{
    var body: some View
    {
        ZStack {
            VStack {
                VStack{
                    Profile()
                }
            }
        }
        .padding()
    }
}

struct Profile: View
{
    var body: some View
    {
        VStack{
            HStack{
                    Text("Profile Page.")
                    Text("More Profile?")
            }
        }.padding(.bottom)
    }
    
}
