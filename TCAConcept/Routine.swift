//
//  Checklist.swift
//  TCAConcept
//
//  Created by Saad Anis on 7/3/20.
//  Copyright © 2020 Saad Anis. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct Routine: Identifiable, Hashable, Codable {
    
    var id = UUID()
    var name: String = ""
    var items: [Item] = []
    var startTime: Date
    var totalTime: Int {
        var total = 0
        for item in items {
            if item.time == 0 { return 0 }
            total += item.time
        }
        return total
    }
    
    var repeatEvery: [String] = []
    
    init(name: String, items: [Item], repeatEvery: [String], startTime: Date) {
        self.name = name
        self.items = items
        self.repeatEvery = repeatEvery
        self.startTime = startTime
    }
    
    static let example = Routine(name: "Wake Up Routine", items: Item.examples, repeatEvery: ["Monday","Tuesday"], startTime: Date())
    
    static func == (lhs: Routine, rhs: Routine) -> Bool {
        lhs.id == rhs.id
    }
}

struct Item: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var time: Int = 0
    var isTask: Bool = true
    static let examples = [Item(name: "Make bed"),Item(name: "Brush teeth"),Item(name: "Take shower"),Item(name: "Make coffee")]
}

struct Category: Identifiable, Hashable, Codable {
    
    var id = UUID()
    var name: String = ""
    var iconName: String = ""
    var colorName: String
    var routines: [Routine] = []
    
    init(name: String, iconName: String, colorName: String) {
        self.name = name
        self.iconName = iconName
        self.colorName = colorName
    }
    
    static let example = Category(name: "Morning", iconName: "sunrise", colorName: "red")
    
    
}

class Categories: ObservableObject {
    @Published private(set) var categories: [Category]
    static let saveKey = "SavedData"
    
    let objectWillChange = ObservableObjectPublisher()
    
    static let colorDict: [String:Color] = ["red": .red,
                                            "yellow": .yellow,
                                            "pink": .pink,
                                            "purple": .purple,
                                            "orange": .orange,
                                            "green": .green,
                                            "blue": .blue,
                                            ".gray": .gray]
    
    static func getColorString(color: Color) -> String {
        for (forName, forColor) in colorDict {
            if(color == forColor) { return forName }
        }
        return ""
    }
    
    init() {
        self.categories = []
        let url = self.getDocumentsDirectory().appendingPathComponent("\(Self.saveKey).json")
        
        if let data = try? Data(contentsOf: url) {
            do {
                if let decoded = try? JSONDecoder().decode([Category].self, from: data) {
                    self.categories = decoded
                    print("loaded from directory.")
                    objectWillChange.send()
                    return
                }
            }
        }
        print("loaded blank.")
    }
    
    func reload() {
        let url = self.getDocumentsDirectory().appendingPathComponent("\(Self.saveKey).json")
        
        if let data = try? Data(contentsOf: url) {
            do {
                if let decoded = try? JSONDecoder().decode([Category].self, from: data) {
                    self.categories = decoded
                    print("loaded from directory.")
                    objectWillChange.send()
                    return
                }
            }
        }
    }
    
    func addCategory(_ category: Category) {
        self.categories.append(category)
        objectWillChange.send()
        save()
    }
    
    func addRoutine(to category: Category, routine: Routine) {
        let index = self.categories.firstIndex(where: {$0.id == category.id})
        if let index = index {
            self.categories[index].routines.append(routine)
        }
        objectWillChange.send()
        save()
    }
    
    func getCategory(category: Category) -> Category {
        let index = self.categories.firstIndex(where: {$0.id == category.id})
        return self.categories[index!]
    }
    
    func updateCategory(category: Category, newName: String, newIconName: String, newColorName: String) {
        let index = self.categories.firstIndex(where: {$0.id == category.id})
        self.categories[index!].name = newName
        self.categories[index!].iconName = newIconName
        self.categories[index!].colorName = newColorName
        print("updated category.")
        objectWillChange.send()
        save()
    }
    
    func getRoutine(category: Category, routine: Routine) -> Routine {
        let indexC = self.categories.firstIndex(where: {$0.id == category.id})
        let indexR = self.categories[indexC!].routines.firstIndex(where: {$0.id == routine.id})
        return self.categories[indexC!].routines[indexR!]
    }
    
    func updateRoutine(category: Category, routine: Routine, newName: String, newStartTime: Date, newRepeatEvery: [String]) {
        let indexC = self.categories.firstIndex(where: {$0.id == category.id})
        let indexR = self.categories[indexC!].routines.firstIndex(where: {$0.id == routine.id})
        self.categories[indexC!].routines[indexR!].name = newName
        self.categories[indexC!].routines[indexR!].startTime = newStartTime
        self.categories[indexC!].routines[indexR!].repeatEvery = newRepeatEvery
        print("updated routine.")
        objectWillChange.send()
        save()
    }
    
    func addItem(category: Category, routine: Routine, item: Item) {
        let indexC = self.categories.firstIndex(where: {$0.id == category.id})
        if let indexC = indexC {
            let indexR = self.categories[indexC].routines.firstIndex(where: {$0.id == routine.id})
            if let indexR = indexR {
                self.categories[indexC].routines[indexR].items.append(item)
            }
        }
        print("created item.")
        objectWillChange.send()
        save()
    }
    
    func moveCategory(from source: IndexSet, to destination: Int) {
        categories.move(fromOffsets: source, toOffset: destination)
        objectWillChange.send()
        save()
    }
    
    func deleteCategory(at offsets: IndexSet) {
        categories.remove(atOffsets: offsets)
        objectWillChange.send()
        save()
    }
    
    func moveRoutine(from source: IndexSet, to destination: Int, category: Category) {
        let index = self.categories.firstIndex(where: {$0.id == category.id})
        self.categories[index!].routines.move(fromOffsets: source, toOffset: destination)
        objectWillChange.send()
        save()
    }
    
    func deleteRoutine(at offsets: IndexSet, category: Category) {
        let index = self.categories.firstIndex(where: {$0.id == category.id})
        self.categories[index!].routines.remove(atOffsets: offsets)
        objectWillChange.send()
        save()
    }
    
    func moveItem(from source: IndexSet, to destination: Int, category: Category, routine: Routine) {
        let indexC = self.categories.firstIndex(where: {$0.id == category.id})
        let indexR = self.categories[indexC!].routines.firstIndex(where: {$0.id == routine.id})
        self.categories[indexC!].routines[indexR!].items.move(fromOffsets: source, toOffset: destination)
        objectWillChange.send()
        save()
    }
    
    func getItemIndex(category: Category, routine: Routine, item: Item) -> Int {
        return getRoutine(category: category, routine: routine).items.firstIndex(where: {$0.id == item.id})!
    }
    
    func deleteItem(at offsets: IndexSet, category: Category, routine: Routine) {
        let indexC = self.categories.firstIndex(where: {$0.id == category.id})
        let indexR = self.categories[indexC!].routines.firstIndex(where: {$0.id == routine.id})
        self.categories[indexC!].routines[indexR!].items.remove(atOffsets: offsets)
        objectWillChange.send()
        save()
    }
    
    //    static let WeekToNum: [String: Int] = ["Sunday":1,
    //                                           "Monday":2,
    //                                           "Tuesday":3,
    //                                           "Wednesday":4,
    //                                           "Thursday":5,
    //                                           "Friday":6,
    //                                           "Saturday":7]
    //
    static let WeekNumToString: [Int: String] = [1:"Sunday",
                                                 2:"Monday",
                                                 3:"Tuesday",
                                                 4:"Wednesday",
                                                 5:"Thursday",
                                                 6:"Friday",
                                                 7:"Saturday",]
    
    func getRoutinesForToday() -> [Routine] {
        var routinesForToday: [Routine] = []
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let components = Calendar.current.dateComponents([.weekday], from: Date())
        let todayNum = components.weekday ?? 0
        let todayString = Categories.WeekNumToString[todayNum] ?? ""
        for category in categories {
            for routine in category.routines {
                if routine.repeatEvery.contains(todayString) {
                    routinesForToday.append(routine)
                }
            }
        }
        
        return routinesForToday.sorted(by: sortByTime)
    }

    func sortByTime(r1: Routine, r2: Routine) -> Bool {
        
        let timeComponents1 = Calendar.current.dateComponents([.hour, .minute], from: r1.startTime)
        let dateSeconds1 = timeComponents1.hour! * 3600 + timeComponents1.minute! * 60
        let timeComponents2 = Calendar.current.dateComponents([.hour, .minute], from: r2.startTime)
        let dateSeconds2 = timeComponents2.hour! * 3600 + timeComponents2.minute! * 60

        return dateSeconds1 < dateSeconds2
        
//        return r1.startTime < r2.startTime
    }
    
    func getColor(for routine: Routine) -> Color {
        return Categories.colorDict[findCategory(for: routine).colorName] ?? .secondary
    }
    
    func getIconName(for routine: Routine) -> String {
        return findCategory(for: routine).iconName
    }
    
    func getTotalTime(for routine: Routine) -> Int {
        var totalTime = 0
        for item in routine.items {
            totalTime += item.time
        }
        return totalTime
    }
    
    func findCategory(for routine: Routine) -> Category {
        for category in categories {
            if category.routines.contains(routine) {
                return category
            }
        }
        return Category(name: "Unknown Category", iconName: "note", colorName: "secondary")
    }
    
    static func secondsToHHMMSS(seconds: Int) -> String {
        
        let hh: Int = seconds / 3600
        
        //let sent1 = "\(hh>1 ? "\(hh) hours" : (hh>0 ? "\(hh) hour" : ""))"
        
        let remainder1: Float = (Float(seconds) / 3600.0) - Float(hh)
        
        let mm: Int = Int(remainder1 * 60)
        
        //let sent2 = "\(mm>1 ? "\(mm) minutes" : (mm>0 ? "\(mm) minute" : ""))"
        
        let remainder2: Float = ((remainder1 * 60) - Float(mm))
        
        let ss: Int = Int(round(remainder2 * 60))
        
        //let sent3 = "\(ss>1 ? "\(ss) seconds" : (ss>0 ? "\(ss) second" : ""))"
        
        // if hh>0 && m>00 && s>0 then comma, otherwise nothing.
        //let comma1 = "\(hh>0 && mm>0 && ss>0 ? ", " : "")"
        
        //let comma2 = "\(hh>0 && mm>0 && ss>0 ? "," : "")"
        
        // if hh>0 && mm>0 && ss==0 then and. (or)
        // if hh>0 && ss>0 && mm==0 then and.
        // otherwise nothing.
        //let and1 = "\(hh>0 && ((mm>0 && ss==0)||(ss>0 && mm==0)) ? " and " : "")"
        
        // mm>0 && ss>0 then and.
        //let and2 = "\(mm>0 && ss>0 ? " and " : "")"
        
        //return "\(sent1)\(comma1)\(and1)\(sent2)\(comma2)\(and2)\(sent3)"
        
        let hh1 = "\(hh)".count == 2 ? "\(hh)" : ("\(hh)".count == 1 ? "0\(hh)" : "00")
        let mm1 = "\(mm)".count == 2 ? "\(mm)" : ("\(mm)".count == 1 ? "0\(mm)" : "00")
        let ss1 = "\(ss)".count == 2 ? "\(ss)" : ("\(ss)".count == 1 ? "0\(ss)" : "00")
        
        return "\(hh1):\(mm1):\(ss1)"
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(categories) {
            let url = self.getDocumentsDirectory().appendingPathComponent("\(Self.saveKey).json")
            do {
                try encoded.write(to: url, options: .atomicWrite)
            } catch {
                print("failed to save: \(error.localizedDescription)")
            }
            print("saved!")
        }
    }
}
