//
//  RoutineEditView.swift
//  TCAConcept
//
//  Created by Saad Anis on 7/5/20.
//  Copyright © 2020 Saad Anis. All rights reserved.
//

import SwiftUI

struct RoutineEditView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var categories: Categories
    
    var category: Category
    var routine: Routine?
    
    @State private var newName = ""
    @State private var newStartTime = Date()
    
    let dayCases = [2,3,4,5,6,7,1]
    
    @State private var repeatEvery: [Int] = []
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("Routine name", text: $newName)
                        DatePicker("Routine starts at", selection: $newStartTime, displayedComponents: .hourAndMinute)
                    }
                    Section(header:Text("Repeat Every")) {
                        ForEach(dayCases, id: \.self) { day in
                            CheckRow(item: day, selectedList: $repeatEvery) {
                                print(repeatEvery)
                            }
                        }
                    }
                }
            }
            .onAppear {
                if routine != nil {
                    newName = routine!.name
                    newStartTime = routine!.startTime
                    repeatEvery = routine!.repeatEvery
                }
                print(repeatEvery)
            }
            .navigationBarTitle(Text(routine != nil ? "Edit Routine" : "New Routine"))
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }){
                Text("Cancel")
            }, trailing: Button(action: {
                if routine != nil {
                    categories.updateRoutine(category: category, routine: routine!, newName: newName, newStartTime: newStartTime, newRepeatEvery: repeatEvery)
                } else {
                    let newRoutine = Routine(name: newName, items: [], repeatEvery: repeatEvery, startTime: newStartTime)
                    categories.addRoutine(to: category, routine: newRoutine)
                }
                addNotification(repeatEvery: repeatEvery)
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text(routine != nil ? "Update" : "Create")
            }).disabled(isDisabled()))
        }
    }
    
    func isDisabled() -> Bool {
        newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func addNotification(repeatEvery: [Int]) {
//        for day in repeatEvery {
//            var notificationDate = Calendar.current.dateComponents([.hour, .minute], from: newStartTime)
//      //      notificationDate.weekday =
////            let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDate, repeats: true)
//        }
    }
}

struct CheckRow: View {
    
    var item: Int
    
    @Binding var selectedList: [Int]
    
    var action: () -> Void
    
    var body: some View {
        HStack {
            Text(intToText(item: item))
            Spacer()
            if selectedList.contains(item) {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .onAppear {
            print(selectedList)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if(!selectedList.contains(item)) {
                selectedList.append(item)
            } else {
                selectedList.removeAll(where: {$0 == item})
            }
        }
    }
    
    func intToText(item: Int) -> String {
        switch item {
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tueday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thurday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            return "Error"
        }
    }
}

struct RoutineEditView_Previews: PreviewProvider {
    static var previews: some View {
        RoutineEditView(category: Category.example)
    }
}
