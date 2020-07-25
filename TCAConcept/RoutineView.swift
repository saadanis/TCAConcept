//
//  ChecklistView.swift
//  TCAConcept
//
//  Created by Saad Anis on 7/3/20.
//  Copyright © 2020 Saad Anis. All rights reserved.
//

import SwiftUI
import Combine
import Foundation

struct RoutineView: View {
    
    @State var routine: Routine
    
    @State var category: Category
    
    @State var newName: String = ""
    
    @State var showingTaskAddView = false
    @State var showingRoutineEditView = false
    
    @State var isTask = true
    
    @ObservedObject var categories = Categories()
    @ObservedObject var textBindingManager = TextBindingManager(limit: 2)
    
    var body: some View {
        VStack {
            List {
                //                Section(header: Text("Currently Running")) {
                //                    HStack {
                //                        Text("Example")
                //                        Spacer()
                //                        Text("00:04:20")
                //                    }
                //                    .foregroundColor(.red)
                //                }
           //     Section {
                    ForEachView(categories: categories, category: category, routine: routine)
                    VStack {
                        if !showingTaskAddView {
                            VStack {
                                Button(action: {
                                    showingTaskAddView = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus")
                                        Text("Add Task")
                                    }
                                }
                            }
                        }
                        else {
                            VStack(spacing: 8) {
                                Picker(selection: $isTask, label: Text("Picker"), content: {
                                    Text("Task").tag(true)
                                    Text("Break").tag(false)
                                }).pickerStyle(SegmentedPickerStyle())
                                if(isTask) {
                                    TextField("Task name", text: $newName) {
                                        print("commit.")
                                    }
                                    .padding(.top, 5)
                                }
                                HStack {
                                    Text("Length of \(isTask ? "task" : "break")").layoutPriority(1)
                                    Spacer()
                                    TextField("HH",text:$textBindingManager.hourText)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 45)
                                        .keyboardType(.numberPad)
                                        .onReceive(Just(textBindingManager.hourText)) { newValue in
                                            let filtered = newValue.filter { "0123456789".contains($0) }
                                            if filtered != newValue {
                                                if Int(filtered) ?? 0 <= 12 {
                                                    self.textBindingManager.hourText = filtered
                                                }
                                            }
                                        }
                                    Text(":")
                                    TextField("MM",text:$textBindingManager.minText)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 45)
                                        .keyboardType(.numberPad)
                                        .onReceive(Just(textBindingManager.minText)) { newValue in
                                            let filtered = newValue.filter { "0123456789".contains($0) }
                                            if filtered != newValue {
                                                self.textBindingManager.minText = filtered
                                            }
                                        }
                                    Text(":")
                                    TextField("SS",text:$textBindingManager.secText)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 45)
                                        .keyboardType(.numberPad)
                                        .onReceive(Just(textBindingManager.secText)) { newValue in
                                            let filtered = newValue.filter { "0123456789".contains($0) }
                                            if filtered != newValue {
                                                self.textBindingManager.secText = filtered
                                            }
                                        }
                                }
                                HStack {
                                    Button(action: {
                                            print("cancelling.")
                                            showingTaskAddView = false }) {
                                        Text("Cancel")
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    Spacer()
                                    Button(action: {
                                        // Create task.
                                        print("creating.")
                                        createItem()
                                    }){
                                        Text("Create")
                                    }
                                    .disabled(isDisabled())
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                                .padding(.bottom, 5)
                            }
                        //}
                    } //1
                }
            }
            .listStyle(GroupedListStyle())
            .sheet(isPresented: $showingRoutineEditView) {
                RoutineEditView(category: category, routine: routine)
                    .environmentObject(categories)
            }
            .navigationBarTitle(Text(categories.getRoutine(category: category, routine: routine).name))
            .navigationBarItems(trailing: HStack {
                EditButton()
                Button(action: {
                    showingRoutineEditView = true
                }) {
                    Image(systemName: "ellipsis.circle")
                }
            })
            Button(action: {
                
            }) {
                Image(systemName: "play")
                    .font(.title)
            }
        }
    }
    
    
    func createItem() {
        let hours = (Int(textBindingManager.hourText) ?? 0) * 3600
        let minutes = (Int(textBindingManager.minText) ?? 0) * 60
        let seconds = Int(textBindingManager.secText) ?? 0
        let newTime = hours + minutes + seconds
        if !isTask {
            newName = "Break"
        }
        let newItem: Item = Item(name: newName, time: newTime, isTask: isTask)
        categories.addItem(category: category, routine: routine, item: newItem)
        newName = ""
        textBindingManager.hourText = ""
        textBindingManager.minText = ""
        textBindingManager.secText = ""
        showingTaskAddView = false
        isTask = true
        categories.reload()
        categories.updateNotifications(category: category, routine: routine)
    }
    
    func isDisabled() -> Bool {
        newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isTask
    }
}

class TextBindingManager: ObservableObject {
    @Published var hourText = "" {
        didSet {
            if hourText.count > characterLimit && oldValue.count <= characterLimit {
                hourText = oldValue
            }
        }
    }
    @Published var minText = "" {
        didSet {
            if minText.count > characterLimit && oldValue.count <= characterLimit {
                minText = oldValue
            }
        }
    }
    @Published var secText = "" {
        didSet {
            if secText.count > characterLimit && oldValue.count <= characterLimit {
                secText = oldValue
            }
        }
    }
    let characterLimit: Int
    
    init(limit: Int = 1){
        characterLimit = limit
    }
}

struct ForEachView: View {
    
    @ObservedObject var categories: Categories
    
    @State var category: Category
    
    @State var routine: Routine
    
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        
        ForEach(categories.getRoutine(category: category, routine: routine).items) { item in
            HStack {
                if item.isTask {
                    VStack(alignment: .leading) {
                        Text(categories.getRoutine(category: category, routine: routine).items[categories.getItemIndex(category: category, routine: routine, item: item)].name)
                        if categories.getRoutine(category: category, routine: routine).items[categories.getItemIndex(category: category, routine: routine, item: item)].time > 0 {
                            Text("\(Categories.secondsToHHMMSS(seconds: categories.getRoutine(category: category, routine: routine).items[categories.getItemIndex(category: category, routine: routine, item: item)].time))")
                                .font(.caption)
                        } else {
                            Text("Time not added")
                                .font(.caption)
                        }
                    }
                } else {
                    HStack {
                        Text("BREAK")
                            .font(.caption)
                            .bold()
                            .padding(.horizontal, 2)
                            .background(RoundedRectangle(cornerRadius: 2, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/).foregroundColor(.secondary).opacity(0.5))
                        if categories.getRoutine(category: category, routine: routine).items[categories.getItemIndex(category: category, routine: routine, item: item)].time > 0 {
                            Text("\(Categories.secondsToHHMMSS(seconds: categories.getRoutine(category: category, routine: routine).items[categories.getItemIndex(category: category, routine: routine, item: item)].time))")
                                .font(.caption2)
                        } else {
                            Text("Time not added")
                                .font(.caption2)
                        }
                    }
                }
                Spacer()
                if categories.getRoutine(category: category, routine: routine).items[categories.getItemIndex(category: category, routine: routine, item: item)].time > 0 {
                    Group {
                        Text("\(formatter.string(from: getStartTime(index: categories.getItemIndex(category: category, routine: routine, item: item))))")
                        Image(systemName: "chevron.right")
                        Text("\(formatter.string(from: getEndTime(index: categories.getItemIndex(category: category, routine: routine, item: item))))")
                    }.font(item.isTask ? .caption : .caption)
                }
            }
            .foregroundColor(item.isTask ? .primary : .primary)
        }
        .onMove { indecies, newOffset in
            categories.moveItem(from: indecies, to: newOffset, category: category, routine: routine)
            categories.updateNotifications(category: category, routine: routine)
        }
        .onDelete { indexSet in
            categories.deleteItem(at: indexSet, category: category, routine: routine)
            categories.updateNotifications(category: category, routine: routine)
        }
    }
    
    func getStartTime(index: Int) -> Date {
        if index==0 {
            return categories.getRoutine(category: category, routine: routine).startTime
        } else {
            return Date(timeInterval: 0, since: getEndTime(index: index-1))
        }
    }
    
    func getEndTime(index: Int) -> Date {
        if index == 0 {
            return Date(timeInterval: Double(categories.getRoutine(category: category, routine: routine).items[index].time), since: categories.getRoutine(category: category, routine: routine).startTime)
        } else {
            return Date(timeInterval: Double(categories.getRoutine(category: category, routine: routine).items[index].time), since: getStartTime(index: index))
        }
    }
}

//struct RoutineView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoutineView(routine: Routine.example, category: Category.example)
//    }
//}
