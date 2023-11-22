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

enum AdministeredByOptions : String, CaseIterable {
    case myself = "Self"
    case other = "Other"
}

enum EntryTypes : String, CaseIterable {
    case daily = "Daily"
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
}

class EntryData: ObservableObject {
    @Published var entryType : EntryTypes = EntryTypes.daily
    @Published var bloodSugarLevel : String = ""
    @Published var entryTime : Date = Date.now
    @Published var administeredByName : AdministeredByOptions = AdministeredByOptions.myself
}

class DosageLabel: ObservableObject {
    @Published var text = "Enter B.S.L. to Calc Dosage"
    @Published var isCalculationComplete : Bool = false
}

struct EntryView: View {
    @StateObject var entryData = EntryData()
    @StateObject var dosageLabel = DosageLabel()
    @State var showingPopup = false

    var body: some View {
        ScrollView{
            ZStack {
                VStack {
                        VStack{
                            EntryHeader()
                        }.frame(maxWidth: .infinity, alignment: .center)
                        GroupBox{
                            VStack{
                                TimeSelector()
                                BloodSugarSelector()
                                EntryTypeSelector()
                                AdministeredBySelector()
                                Note()
                                ClearButton()
                            }
                        }
                        .ignoresSafeArea(.keyboard)
                        .groupBoxStyle(CustomGroupBoxStyle())
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
    @EnvironmentObject var entryData : EntryData
    
    var body: some View {
        VStack{
            DatePicker(selection: $entryData.entryTime, label: { Text("Time").font(.system(size:18, weight: .medium)) })
        }
        .padding(.top, 14)
        .padding(.leading, 8)
    }
}

struct EntryTypeSelector: View {
    @EnvironmentObject var entryData: EntryData
    
    var body: some View {
        VStack{
            Text("Entry Type").font(.system(size:18, weight: .medium)).frame(maxWidth: .infinity, alignment: .leading)
            
        }        
        .padding(.top, 14)
        .padding(.leading, 8)
        HStack{
            Picker("Entry Type", selection: $entryData.entryType) {
                ForEach(EntryTypes.allCases, id: \.self) { option in
                    Text(option.rawValue)
                }
            }
            .pickerStyle(.segmented)
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
                TextField("Enter BSL here", text: $entryData.bloodSugarLevel)
                    .frame(width: 140)
                    .padding(.leading, 20)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .onReceive(Just(entryData.bloodSugarLevel)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            entryData.bloodSugarLevel = filtered
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 14)
        .padding(.leading, 8)
    }
}


struct AdministeredBySelector: View {
    @EnvironmentObject var entryData : EntryData

    var body: some View {
        VStack{
            HStack{
                Text("Administered By").font(.system(size:18, weight: .medium)).frame(maxWidth: .infinity, alignment: .leading)
                Picker("Administered By", selection: $entryData.administeredByName) {
                    ForEach(AdministeredByOptions.allCases, id: \.self) { option in
                        Text(option.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.top, 14)
            .padding(.leading, 8)
        }
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
        }
        .padding(.top, 14)
        .padding(.leading, 8)
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
                    entryData.entryType = EntryTypes.daily
                    entryData.bloodSugarLevel = ""
                    entryData.entryTime = Date.now
                    entryData.administeredByName = AdministeredByOptions.myself
                    dosageLabel.text = "Enter BSL to Calc Dosage"
                    dosageLabel.isCalculationComplete = false
                    
                }
                .padding(8)
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

//struct ValidatedBySelector: View {
//    @State private var validatedByName: String = "";
//    @State private var validatedByPin : String = "";
//
//    var body: some View {
//        VStack{
//            HStack{
//                Text("Validated By").font(.system(size:17, weight: .medium)).frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
//                TextField("Name", text: $validatedByName).onReceive(Just(validatedByName)) { validatedByName in
//                    self.validatedByName = validatedByName
//                }
//                Text("Pin").font(.system(size:15, weight: .medium))
//                TextField("Pin", text: $validatedByPin)
//                    .keyboardType(.numberPad)
//                    .onReceive(Just(validatedByPin)) { newValue in
//                        let filtered = newValue.filter { "0123456789".contains($0) }
//                        if filtered != newValue {
//                            self.validatedByPin = filtered
//                        }
//                    }
//            }
//        }.padding([.top, .leading], 8)
//    }
//}

//struct EnteredBySelector: View {
//    @EnvironmentObject var entryData: EntryData
//
//    var body: some View {
//        VStack{
//            HStack{
//                Text("Entered By").font(.system(size:18, weight: .medium))
//                Spacer()
//                TextField("Name", text: $entryData.enteredByName)
//            }
//        }.padding([.top, .leading], 8)
//    }
//}
