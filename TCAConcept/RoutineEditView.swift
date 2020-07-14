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
    
    let dayCases = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    
    @State private var repeatEvery: [String] = []
    
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
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text(routine != nil ? "Update" : "Create")
            }).disabled(isDisabled()))
        }
    }
    
    func isDisabled() -> Bool {
        newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct CheckRow: View {
    
    var item: String
    
    @Binding var selectedList: [String]
    
    var action: () -> Void
    
    var body: some View {
        HStack {
            Text(item)
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
}

struct RoutineEditView_Previews: PreviewProvider {
    static var previews: some View {
        RoutineEditView(category: Category.example)
    }
}
