//
//  ContentView.swift
//  InsulinTracker
//
//  Created by Ethan Katnic on 10/31/23.
//
import SwiftUI
import Combine


enum entryTypes : String, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case other = "Other"
}

class EntryType: ObservableObject {
    @Published var type = ""
}

class BloodSugarLevel: ObservableObject {
    @Published var level = ""
}

class EnteredBy: ObservableObject {
    @Published var name = ""
}

struct ContentView: View {
    @StateObject var entryType = EntryType()
    @StateObject var bloodSugarLevel = BloodSugarLevel()
    @StateObject var enteredBy = EnteredBy()

    var body: some View {
        ZStack {
            VStack {
                NavigationStack{
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
                        }
                    }.groupBoxStyle(CustomGroupBoxStyle())
                    RecommendationPanel()
                    NavBar()
                }
                .environmentObject(entryType)
                .environmentObject(bloodSugarLevel)
                .environmentObject(enteredBy)
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

struct CustomGroupBoxStyle: GroupBoxStyle {
    var backgroundColor: UIColor = UIColor.systemGroupedBackground
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.label
            configuration.content
        }
        .padding()
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
        }.padding(.bottom)
    }
}

struct TimeSelector: View {
    var body: some View {
        VStack{
            DatePicker(selection: /*@START_MENU_TOKEN@*/.constant(Date())/*@END_MENU_TOKEN@*/, label: { Text("Time").font(.system(size:20, weight: .medium)) })
        }.padding([.top, .leading])
    }
}

struct EntryTypeSelector: View {
    let buttons: [String] = entryTypes.allCases.map { $0.rawValue }
    @EnvironmentObject var entryType: EntryType
    
    var body: some View {
        VStack{
            Text("Entry Type").font(.system(size:18, weight: .medium)).frame(maxWidth: .infinity, alignment: .leading)
            
        }.padding([.top, .leading])
        HStack{
            ForEach(buttons, id: \.self) { button in
                Button(action: {
                    entryType.type = button
                }) {
                    Text(button).font(.system(size:16))
                }.foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(entryType.type == button ? Color.blue : Color.gray)
                    .cornerRadius(8)
            }
        }
    }
}

struct BloodSugarSelector: View {
    @EnvironmentObject var bloodSugarLevel: BloodSugarLevel

    var body: some View {
        VStack{
            HStack{
                Text("Blood Sugar Level").font(.system(size:18, weight: .medium))
                //Enforces that input must be a valid integer
                TextField("BSL", text: $bloodSugarLevel.level)
                    .keyboardType(.numberPad)
                    .onReceive(Just(bloodSugarLevel.level)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            bloodSugarLevel.level = filtered
                        }
                    }
            }
        }.padding([.top, .leading])
    }
}

struct EnteredBySelector: View {
    @EnvironmentObject var enteredBy : EnteredBy
    
    var body: some View {
        VStack{
            HStack{
                Text("Entered By").font(.system(size:18, weight: .medium))
                Spacer()
                TextField("Name", text: $enteredBy.name)
            }
        }.padding([.top, .leading])
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
        }.padding([.top, .leading])
    }
}

struct Note: View {
    @State private var noteText: String = "Write your note here..."

    var body: some View {
        VStack{
            TextEditor(text: $noteText).onReceive(Just(noteText)) { noteText in
                self.noteText = noteText
            }.font(.custom("HelveticaNeue", size: 13))
                .frame(width: 326.0, height: 100)
        }.padding(.leading)
    }
}

struct RecommendationPanel: View {
    @State private var dosageString: String = "Enter Data to Calc Dosage"
    @State private var isCalculationComputed : Bool = false

    @EnvironmentObject var entryType: EntryType
    @EnvironmentObject var bloodSugarLevel: BloodSugarLevel
    @EnvironmentObject var enteredBy : EnteredBy
    
    var body: some View {
        VStack{
            Text(self.dosageString)
                .foregroundColor(self.isCalculationComputed ? .green : .gray)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(self.isCalculationComputed ? .green : .gray, lineWidth: 4)
                )
            
            HStack {
                Button("Calculate Dosage")
                {
                    self.isCalculationComputed = true
                    displayDosage()
                }
                .disabled(!(entryType.type.count > 0 && bloodSugarLevel.level.count > 0))
                .buttonStyle(.borderedProminent)
                .padding([.top, .trailing], 20.0)
                
                Button("Submit "){
                    print(enteredBy.name)
                }
                .disabled(
                    !(entryType.type.count > 0
                      && bloodSugarLevel.level.count > 0
                      && enteredBy.name.count > 0
                    )
                )
                .buttonStyle(.borderedProminent)
                .padding([.top, .leading], 20.0)
            }
        }.padding([.top, .bottom], 25)
    }
    
    private func displayDosage(){
        let dosage = calculateDosage(entryType: entryType.type, bloodSugarLevel: bloodSugarLevel.level)!
        self.dosageString =  dosage.1 > 0 ? "\(dosage.0) \(dosage.1)" : "\(dosage.0)"
    }
    
    private func calculateDosage(entryType: String, bloodSugarLevel: String) -> (String, Int)? {
        let processedBloodSugarLevel = getBucketedBloodSugarLevel(entryType: entryType, bloodSugarLevelString: bloodSugarLevel)
        
        let dosageDict : [String : Dictionary] = getDosageDict()

        // if entry type is NA or processed is NA, return none in some capacity
        if(dosageDict[entryType] == nil || dosageDict[entryType]![processedBloodSugarLevel] == nil){
            return ("No dosage found", 0)
        }
        return dosageDict[entryType]![processedBloodSugarLevel]
    }

    private func getBucketedBloodSugarLevel(entryType: String, bloodSugarLevelString: String) -> String {
        let bloodSugarLevel : Int? = Int(bloodSugarLevelString)
        if (entryType == "Breakfast" || entryType == "Lunch") {
            if (bloodSugarLevel! < 80) {
                return "<80"
            } else if (bloodSugarLevel! < 121) {
                return "81:120"
            } else if (bloodSugarLevel! < 151) {
                return "121:150"
            } else if (bloodSugarLevel! < 201) {
                return "151:200"
            } else if (bloodSugarLevel! < 251) {
                return "201:250"
            } else {
                return ">250"
            }
        } else if (entryType == "Dinner"){
            if (bloodSugarLevel! < 80) {
                return "<80"
            } else if (bloodSugarLevel! < 121) {
                return "81:120"
            } else if (bloodSugarLevel! < 161) {
                return "121:160"
            } else if (bloodSugarLevel! < 201) {
                return "161:200"
            } else if (bloodSugarLevel! < 251) {
                return "201:250"
            } else {
                return ">250"
            }
        } else if (entryType == "Other"){
            return "any"
        }
        return "NA"
    }
    
    private func getDosageDict() -> [String: Dictionary<String, (String, Int)>] {
        let breakfastDosage = ["<80" : ("No insulin required", 0),
                                    "81:120" : ("Humalog", 8),
                                    "121:150" : ("Humalog", 10),
                                    "151:200" : ("Humalog", 14),
                                    "201:250" : ("Humalog", 16)
                            ]
        let lunchDosage = ["<80" : ("No insulin required", 0),
                           "81:120" : ("Humalog", 8),
                           "121:150" : ("Humalog", 10),
                           "151:200" : ("Humalog", 14),
                           "201:250" : ("Humalog", 16)
                           ]
        let dinnerDosage = ["<80" : ("No insulin required", 0),
                            "81:120" : ("Humalog", 4),
                            "121:160" : ("Humalog", 5),
                            "161:200" : ("Humalog", 6),
                            "201:250" : ("Humalog", 8),
                            ">250" : ("Humalog", 10),
                            ]
        let otherDosage = ["any": ("Lantus", 16)]
        return [
            "Breakfast": breakfastDosage,
            "Lunch": lunchDosage,
            "Dinner": dinnerDosage,
            "Other": otherDosage
        ]
    }
}


struct NavBar: View
{
    var body: some View
    {
            HStack(spacing:45)
            {
                //Entry Button
                NavigationLink{
                    EntryView()
                } label:{
                    VStack
                    {//VStack is needed if you want Text underneath image.
                        Image(systemName: "syringe")
                            .resizable()
                            .frame(width:40, height:40)
                            .foregroundColor(.black)
                        Text("Entry")
                            .foregroundColor(.black )
                    }
                    
                }

                
                //History Button
                NavigationLink{
                    HistoryView()
                }label:{
                    VStack
                    {
                        Image(systemName: "calendar.badge.clock")
                            .resizable()
                            .frame(width:40, height:40)
                            .foregroundColor(.black)
                        Text("History")
                            .foregroundColor(.black)
                    }
                }
                
                //Profile Button
                NavigationLink{
                    ProfileView()
                }label:{
                    VStack
                    {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width:40, height:40)
                            .foregroundColor(.black)
                        Text("Profile")
                            .foregroundColor(.black)
                    }
                }

                
                //Settings/More Button
                NavigationLink{
                    SettingsView()
                    } label:{
                        VStack
                        {
                            Image(systemName: "ellipsis.rectangle")
                                .resizable()
                                .frame(width:40, height:40)
                                .foregroundColor(.black)
                            Text("More")
                                .foregroundColor(.black)
                        }
                    }
                }
    }
}
