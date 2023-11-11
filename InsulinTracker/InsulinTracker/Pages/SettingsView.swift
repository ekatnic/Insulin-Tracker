//
//  SettingsView.swift
//  InsulinTracker
//
//  Created by Eli Medina on 11/5/23.
//

import Foundation

import SwiftUI


enum gender : String, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
}
class UserInformation: ObservableObject
{
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var gender = ""
}

struct SettingsView: View
{
    @StateObject var userInformation = UserInformation()
    var body: some View
    {
        ZStack {
            VStack {
                VStack
                {
                    ProfileInformation()
                }
            }
        }
        .environmentObject(userInformation)
        .padding()
    }
}


struct ProfileInformation: View
{
    @EnvironmentObject var userInformation: UserInformation
    var body: some View
    {
        VStack
        {
            Label("Profile",systemImage:"person.crop.circle")
            Spacer()
            HStack
            {
                TextField("First Name", text: $userInformation.firstName)
                Spacer()
                TextField("Last Name", text: $userInformation.lastName)
                
            }
        }
    }
}
