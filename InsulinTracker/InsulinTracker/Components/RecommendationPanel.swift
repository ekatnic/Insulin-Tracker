//
//  RecommendationPanel.swift
//  InsulinTracker
//
//  Created by Ethan Katnic on 11/15/23.
//

import Foundation
import SwiftUI
import Combine
import FirebaseCore
import FirebaseDatabase

struct RecommendationPanel: View {
    @EnvironmentObject var entryData : EntryData
    @Binding public var showingPopup: Bool
    
    var body: some View {
        VStack{
            DosageRecommendation()
            HStack {
                CalculateButton()
                SubmitButton(showingPopup:$showingPopup)
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
        .disabled(!(entryData.bloodSugarLevel.count > 0))
        .buttonStyle(.borderedProminent)
        .padding([.top, .trailing], 20.0)
    }
    
    private func displayDosage(){
        let dosage = calculateDosage(entryType: entryData.entryType, bloodSugarLevel: entryData.bloodSugarLevel)!
        let dosageMessage = dosage.0
        let dosageAmount = dosage.1
        dosageLabel.text =  dosageAmount > 0 ? "\(dosageMessage) \(dosageAmount)" : "\(dosageMessage)"
    }

    private func calculateDosage(entryType: EntryTypes, bloodSugarLevel: String) -> (String, Int)? {
        let processedBloodSugarLevel = getBucketedBloodSugarLevel(entryType: entryType, bloodSugarLevelString: bloodSugarLevel)

        let dosageDict : [EntryTypes : Dictionary] = getDosageDict()

        // if entry type is NA or processed is NA, return none in some capacity
        if(dosageDict[entryType] == nil || dosageDict[entryType]![processedBloodSugarLevel] == nil){
            return ("No dosage found", 0)
        }
        return dosageDict[entryType]![processedBloodSugarLevel]
    }

    private func getBucketedBloodSugarLevel(entryType: EntryTypes, bloodSugarLevelString: String) -> String {
        let bloodSugarLevel : Int? = Int(bloodSugarLevelString)
        if (entryType == EntryTypes.breakfast || entryType == EntryTypes.lunch) {
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
        } else if (entryType == EntryTypes.dinner){
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
        } else if (entryType == EntryTypes.daily){
            return "any"
        }
        return "NA"
    }

    private func getDosageDict() -> [EntryTypes: Dictionary<String, (String, Int)>] {
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
            EntryTypes.breakfast: breakfastDosage,
            EntryTypes.lunch: lunchDosage,
            EntryTypes.dinner: dinnerDosage,
            EntryTypes.daily: dailyDosage
        ]
    }
}


struct SubmitButton: View {
    @EnvironmentObject var entryData : EntryData
    @Binding public var showingPopup: Bool

    private func writeNewEvent(entryData : EntryData) {
        let dataBase = Database.database().reference()
        let ref = dataBase.child("entries")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY, MMM d, hh:mm"
        let entry : [String : Any] = [
            "bsl" : entryData.bloodSugarLevel,
            "name" : entryData.enteredByName,
            "meal": entryData.entryType.rawValue,
            "entryTime": dateFormatter.string(from: entryData.entryTime),
            "administeredByName": entryData.administeredByName.rawValue
        ]
        ref.childByAutoId().setValue(entry)
    }
    
    var body: some View
    {
        Button("Submit "){
            writeNewEvent(entryData: entryData)
            showingPopup = true
        }
        .disabled(
            !(entryData.bloodSugarLevel.count > 0
              && entryData.enteredByName.count > 0
            )
        )
        .buttonStyle(.borderedProminent)
        .padding([.top, .leading], 20.0)
    }
}
