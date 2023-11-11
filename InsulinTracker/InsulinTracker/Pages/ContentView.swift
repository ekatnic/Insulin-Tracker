//
//  ContentView.swift
//  InsulinTracker
//
//  Created by Eli Medina on 11/10/23.
//

import Foundation
import SwiftUI
import Combine



struct ContentView: View
{
    var body: some View
    {
        ZStack {
            VStack {
                VStack{
                    NavBar()
                }
            }
        }
        .padding()
    }
}
struct LandingPage: View {
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
}



struct NavBar: View
{
    @State private var selected = 1
    let navTitles = [1: "Entry",
                     2: "History",
                     3: "Profile",
                     4: "More"]
    var body: some View
    {
        TabView(selection: $selected    )
        {
            EntryView()
            .tabItem
            {
                Label("Entry", systemImage: "syringe")
                //EntryView()
                //EntryView()
            }
            HistoryView()
                .tabItem
            {
                Label("History",systemImage:"calendar.badge.clock")
                //HistoryView()
            }.tag(2)
            
            ProfileView()
                .tabItem
            {
                Label("Profile",systemImage:"person.crop.circle")
            }.tag(3)
            SettingsView()
                .tabItem
            {
                Label("Settings",systemImage:"ellipsis.rectangle")
            }.tag(4)
        }
        
    }
}
