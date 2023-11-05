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
                VStack{
                    EntryHeader()
                }.frame(maxWidth: .infinity, alignment: .center)
                VStack{
                    TimeSelector()
                    EntryTypeSelector()
                    BloodSugarSelector()
                    EnteredBySelector()
                    ValidatedBySelector()
                    Note()
                }.overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.gray, lineWidth: 2)
                )

                RecommendationPanel()
                NavBar()
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
            DatePicker(selection: /*@START_MENU_TOKEN@*/.constant(Date())/*@END_MENU_TOKEN@*/, label: { Text("Time").font(.system(size:20, weight: .medium)) })
        }.padding()
    }
}

struct EntryTypeSelector: View {
    var body: some View {
        VStack{
            Text("Entry Type").font(.system(size:18, weight: .medium)).frame(maxWidth: .infinity, alignment: .leading)
            
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
        .padding(.horizontal)
    }
}

struct BloodSugarSelector: View {
    var body: some View {
        VStack{
            HStack{
                Text("Blood Sugar Level").font(.system(size:18, weight: .medium))
                TextField("Level", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                
            }
        }.padding()
    }
}

struct EnteredBySelector: View {
    var body: some View {
        VStack{
            HStack{
                Text("Entered By").font(.system(size:18, weight: .medium))
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
                Text("Validated By").font(.system(size:15, weight: .medium))
                TextField("Name", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                Spacer()
                Text("Pin").font(.system(size:15, weight: .medium))
                TextField("Pin", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                Spacer()
            }
        }.padding()
    }
}

struct Note: View {
    @State var fullText: String = "Write your note here..."

    var body: some View {
        VStack{
            TextEditor(text: $fullText).font(.custom("HelveticaNeue", size: 13))
                .frame(width: 326.0, height: 100)
        }
    }
}

struct RecommendationPanel: View {
    var body: some View {
        VStack{
            Spacer()
            Text("Placeholder of Recommended Dosage")
            Spacer()
            HStack {
                Button(action: {}) {
                    Text("Calculate Dosage")
                }
                .padding([.top, .trailing], 20.0)
                
                Button(action: {}) {
                    Text("Submit ")
                }
                .padding([.top, .leading], 20.0)

            }
            Spacer()
        }
    }
}
struct NavBar: View{
    var body: some View{
        //TODO: Add button actions that route to correct pages
        HStack(spacing:45)
        {
            //Entry Button
            Button(action: {}, label: {
                Image(systemName: "syringe")
                    .resizable()
                    .frame(width:40, height:40)
                    .foregroundColor(.black)
                    
            })
            
            //History Button
            Button(action: {}, label: {
                Image(systemName: "heart.circle")
                    .resizable()
                    .frame(width:40, height:40)
                    .foregroundColor(.black)
                    
            })
            
            //Profile Button
            Button(action: {}, label: {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.black)
            })
            
            //More Button
            Button(action: {}, label: {
                Image(systemName: "ellipsis.rectangle")
                    .resizable()
                    .frame(width:40, height:40)
                    .foregroundColor(.black)
            })
            
        }
    }
}
