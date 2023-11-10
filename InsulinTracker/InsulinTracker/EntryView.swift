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

    var body: some View {
        ZStack {
            VStack {
                NavigationStack{
                    //EntryView()
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
                    RecommendationPanel()
                    NavBar()
                }
                .tabItem
                {
                    Label("Entry", systemImage: "syringe")
                }
                .environmentObject(entryData)
                .environmentObject(dosageLabel)
            }
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


struct RecommendationPanel: View {
    @EnvironmentObject var entryData : EntryData
    
    var body: some View {
        VStack{
            DosageRecommendation()
            HStack {
                CalculateButton()
                SubmitButton()
            }
        }.padding([.top, .bottom], 25)
    }

}


struct DosageRecommendation: View {
    @EnvironmentObject var dosageLabel : DosageLabel
    var body: some View
    {
        Text(dosageLabel.text)
            .foregroundColor(dosageLabel.isCalculationComplete ? .green : .gray)
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(dosageLabel.isCalculationComplete ? .green : .gray, lineWidth: 4)
            )
    }
}


struct CalculateButton: View {
    @EnvironmentObject var entryData : EntryData
    @EnvironmentObject var dosageLabel : DosageLabel

    var body: some View
    {
        Button("Calculate Dosage")
        {
            dosageLabel.isCalculationComplete = true
            displayDosage()
        }
        .disabled(!(entryData.entryType.count > 0 && entryData.bloodSugarLevel.count > 0))
        .buttonStyle(.borderedProminent)
        .padding([.top, .trailing], 20.0)
    }
    
    private func displayDosage(){
        let dosage = calculateDosage(entryType: entryData.entryType, bloodSugarLevel: entryData.bloodSugarLevel)!
        let dosageMessage = dosage.0
        let dosageAmount = dosage.1
        dosageLabel.text =  dosageAmount > 0 ? "\(dosageMessage) \(dosageAmount)" : "\(dosageMessage)"
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
        if (entryType == entryTypes.breakfast.rawValue || entryType == entryTypes.lunch.rawValue) {
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
        } else if (entryType == entryTypes.dinner.rawValue){
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
        } else if (entryType == entryTypes.daily.rawValue){
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
        let dailyDosage = ["any": ("Lantus", 16)]
        return [
            entryTypes.breakfast.rawValue: breakfastDosage,
            entryTypes.lunch.rawValue: lunchDosage,
            entryTypes.dinner.rawValue: dinnerDosage,
            entryTypes.daily.rawValue: dailyDosage
        ]
    }
}


struct SubmitButton: View {
    @EnvironmentObject var entryData : EntryData
    var body: some View
    {
        Button("Submit "){
        }
        .disabled(
            !(entryData.entryType.count > 0
              && entryData.bloodSugarLevel.count > 0
              && entryData.enteredByName.count > 0
            )
        )
        .buttonStyle(.borderedProminent)
        .padding([.top, .leading], 20.0)
    }
}


struct NavBar: View
{
    var body: some View
    {
        TabView
        {
            Text("")
            .tabItem
            {
                Label("Entry", systemImage: "syringe")
            }
            Text("")
                .tabItem
            {
                Label("History",systemImage:"calendar.badge.clock")
            }
            Text("")
                .tabItem
            {
                Label("Profile",systemImage:"person.crop.circle")
            }
            Text("")
                .tabItem
            {
                Label("More",systemImage:"ellipsis.rectangle")
            }
        }
        
    }
}
