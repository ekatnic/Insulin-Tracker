//
//  ContentView.swift
//  InsulinTracker
//
//  Created by Ethan Katnic on 10/31/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            VStack {
                EntryHeader()
                VStack{
                    TimeSelector()
                    EntryTypeSelector()
                    BloodSugarSelector()
                    EnteredBySelector()
                    ValidatedBySelector()
                    Note()
                    Button(action: {}) {
                        Text("Enter")
                    }
                    Spacer()
                }

            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



struct EntryHeader: View {
    var body: some View {
        VStack{
            HStack{
                Image(systemName:"pencil").resizable().frame(width:30,height:20)
                Text("Entry").font(.system(size:30, weight: .medium))
            }
        }.padding(.bottom)
    }
}

struct TimeSelector: View {
    var body: some View {
        VStack{
            DatePicker(selection: /*@START_MENU_TOKEN@*/.constant(Date())/*@END_MENU_TOKEN@*/, label: { Text("Time").font(.system(size:24, weight: .medium)) })
        }.padding()
    }
}

struct EntryTypeSelector: View {
    var body: some View {
        VStack{
            Text("Entry Type").font(.system(size:24, weight: .medium)).frame(maxWidth: .infinity, alignment: .leading)
            
        }.padding()
        ControlGroup {
            Button(action: {}) {
                Text("Breakfast")
            }
            Button(action: {}) {
                Text("Lunch")
            }
            Button(action: {}) {
                Text("Dinner")
            }
            Button(action: {}) {
                Text("Other")
            }
        }
    }
}

struct BloodSugarSelector: View {
    var body: some View {
        VStack{
            HStack{
                Text("Blood Sugar Level").font(.system(size:24, weight: .medium))
                TextField("Level", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                
            }
        }.padding()
    }
}

struct EnteredBySelector: View {
    var body: some View {
        VStack{
            HStack{
                Text("Entered By").font(.system(size:24, weight: .medium))
                Spacer()
                TextField("Name", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
            }
        }.padding()
    }
}

struct ValidatedBySelector: View {
    var body: some View {
        VStack{
            HStack{
                Text("Validated By").font(.system(size:18, weight: .medium))
                TextField("Name", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                Spacer()
                Text("Pin").font(.system(size:24, weight: .medium))
                TextField("Pin", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                Spacer()
            }
        }.padding()
    }
}

struct Note: View {
    var body: some View {
        VStack{
            HStack{
                Text("Note").font(.system(size:24, weight: .medium)).padding(.leading).frame(maxWidth: .infinity, alignment: .leading)
            }
            TextEditor(text: .constant("Write your note here..."))
        }
    }
}
