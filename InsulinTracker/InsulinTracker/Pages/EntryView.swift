//
//  ContentView.swift
//  InsulinTracker
//
//  Created by Ethan Katnic on 10/31/23.
//
import SwiftUI
import Combine
import FirebaseCore
import FirebaseDatabase
import PopupView

enum entryTypes : String, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case daily = "Daily"
}

class EntryData: ObservableObject {
    @Published var entryType = ""
    @Published var bloodSugarLevel = ""
    @Published var enteredByName = ""
}

class DosageLabel: ObservableObject {
    @Published var text = "Enter Data to Calc Dosage"
    @Published var isCalculationComplete : Bool = false
}

struct EntryView: View {
    @StateObject var entryData = EntryData()
    @StateObject var dosageLabel = DosageLabel()
    @State var showingPopup = false

    var body: some View {
        ZStack {
            VStack {
                    VStack{
                        EntryHeader()
                    }.frame(maxWidth: .infinity, alignment: .center)
                    GroupBox{
                        VStack{
                            TimeSelector()
                            EntryTypeSelector()
                            BloodSugarSelector()
                            EnteredBySelector()
                            ValidatedBySelector()
                            Note()
                            ClearButton()
                        }
                    }.groupBoxStyle(CustomGroupBoxStyle())
                RecommendationPanel(showingPopup:$showingPopup)
            }
            .environmentObject(entryData)
            .environmentObject(dosageLabel)
        }
        .popup(isPresented: $showingPopup) {
            Text("Submission entered!")
                .frame(width: 200, height: 60)
                .background(Color(red: 0.85, green: 0.8, blue: 0.95))
                .cornerRadius(30.0)
        } customize: {
            $0
                .autohideIn(2)
                .position(.bottom)
        }
        .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EntryView()
    }
}

struct CustomGroupBoxStyle: GroupBoxStyle {
    var backgroundColor: UIColor = UIColor.systemGroupedBackground
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.label
            configuration.content
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 20, style: .circular)
            .fill(Color(backgroundColor)))
    }
}


struct EntryHeader: View {
    var body: some View {
        VStack{
            HStack{
                Image(systemName:"pencil").resizable().frame(width:30,height:20)
                Text("Entry").font(.system(size:30, weight: .medium))
            }
        }.padding(.bottom, 8)
    }
}

struct TimeSelector: View {
    var body: some View {
        VStack{
            DatePicker(selection: /*@START_MENU_TOKEN@*/.constant(Date())/*@END_MENU_TOKEN@*/, label: { Text("Time").font(.system(size:18, weight: .medium)) })
        }.padding([.top, .leading], 8)
    }
}

struct EntryTypeSelector: View {
    let buttons: [String] = entryTypes.allCases.map { $0.rawValue }
    @EnvironmentObject var entryData: EntryData
    
    var body: some View {
        VStack{
            Text("Entry Type").font(.system(size:18, weight: .medium)).frame(maxWidth: .infinity, alignment: .leading)
            
        }.padding([.top, .leading], 8)
        HStack{
            ForEach(buttons, id: \.self) { button in
                Button(action: {
                    entryData.entryType = button
                }) {
                    Text(button).font(.system(size:16))
                }.foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(entryData.entryType == button ? Color.blue : Color.gray)
                    .cornerRadius(8)
            }
        }
    }
}

struct BloodSugarSelector: View {
    @EnvironmentObject var entryData: EntryData

    var body: some View {
        VStack{
            HStack{
                Text("Blood Sugar Level").font(.system(size:18, weight: .medium))
                //Enforces that input must be a valid integer
                TextField("BSL", text: $entryData.bloodSugarLevel)
                    .keyboardType(.numberPad)
                    .onReceive(Just(entryData.bloodSugarLevel)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            entryData.bloodSugarLevel = filtered
                        }
                    }
            }
        }.padding([.top, .leading], 8)
    }
}

struct EnteredBySelector: View {
    @EnvironmentObject var entryData: EntryData

    var body: some View {
        VStack{
            HStack{
                Text("Entered By").font(.system(size:18, weight: .medium))
                Spacer()
                TextField("Name", text: $entryData.enteredByName)
            }
        }.padding([.top, .leading], 8)
    }
}

struct ValidatedBySelector: View {
    @State private var validatedByName: String = "";
    @State private var validatedByPin : String = "";

    var body: some View {
        VStack{
            HStack{
                Text("Validated By").font(.system(size:17, weight: .medium)).frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                TextField("Name", text: $validatedByName).onReceive(Just(validatedByName)) { validatedByName in
                    self.validatedByName = validatedByName
                }
                Text("Pin").font(.system(size:15, weight: .medium))
                TextField("Pin", text: $validatedByPin)
                    .keyboardType(.numberPad)
                    .onReceive(Just(validatedByPin)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.validatedByPin = filtered
                        }
                    }
            }
        }.padding([.top, .leading], 8)
    }
}

struct Note: View {
    @State private var noteText: String = "Write your note here..."

    var body: some View {
        VStack{
            TextEditor(text: $noteText).onReceive(Just(noteText)) { noteText in
                self.noteText = noteText
            }.font(.custom("HelveticaNeue", size: 13))
                .frame(width: 326.0, height: 70)
        }.padding(.leading, 8)
    }
}

struct ClearButton: View {
    @EnvironmentObject var entryData : EntryData
    @EnvironmentObject var dosageLabel : DosageLabel
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Button("Clear")
                {
                    entryData.entryType = ""
                    entryData.bloodSugarLevel = ""
                    entryData.enteredByName = ""
                    dosageLabel.text = "Enter Data to Calc Dosage"
                    dosageLabel.isCalculationComplete = false
                }
                .padding(3)
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
