//
//  CategoryView.swift
//  TCAConcept
//
//  Created by Saad Anis on 7/3/20.
//  Copyright © 2020 Saad Anis. All rights reserved.
//

import SwiftUI

struct CategoryView: View {
    
    var category: Category
    
    @State var showingAddRoutineSheet = false
    
    @ObservedObject var categories = Categories()
    
    @State var showingCategoryEditView = false
    
    var body: some View {
        List {
            // Check whether something is currently running.
            //            if false {
            //                Section(header: Text("Currently Running")) {
            //                    Text("f2ew")
            //                }
            //            }
            Section {
                ForEach(categories.getCategory(category: category).routines) { routine in
                    NavigationLink(destination: RoutineView(routine: routine, category: category)) {
                        VStack(alignment: .leading) {
                            Text(routine.name)
                            repetition(repeatEvery: routine.repeatEvery)
                                .font(.caption)
                        }
//                        Spacer()
//                        Button(action: {
//                            print("starting routine.")
//                        }) {
//                            Image(systemName: "play")
//                                .foregroundColor(Categories.colorDict[category.colorName])
//                        }
                    }
                }
                .onMove { indecies, newOffset in
                    categories.moveRoutine(from: indecies, to: newOffset, category: category)
                }
                .onDelete { indexSet in
                    categories.deleteRoutine(at: indexSet, category: category)
                }
                
                Button(action: {
                    showingAddRoutineSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Routine")
                    }
                }
                .sheet(isPresented: $showingAddRoutineSheet) {
                    RoutineEditView(category: category)
                        .environmentObject(categories)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .onAppear {
            categories.reload()
        }
        .navigationBarTitle(Text(categories.getCategory(category: category).name))
        .navigationBarItems(trailing:
                                HStack {
                                    //                                    Button(action: {}){
                                    //                                        Image(systemName: "arrow.up.arrow.down")
                                    //                                    }
                                    EditButton()
                                    Button(action: {
                                        showingCategoryEditView = true
                                    }) {
                                        Image(systemName: "ellipsis.circle")
                                    }
                                })
        
        .sheet(isPresented: $showingCategoryEditView) {
            CategoryEditView(category: category)
                .environmentObject(categories)
        }
    }
    
    func repetition(repeatEvery: [String]) -> some View {
        //        if repeatEvery.count == 5 &&
        //            !repeatEvery.contains("Saturday") &&
        //            !repeatEvery.contains("Sunday") {
        //            return "Every weekday"
        //        } else if repeatEvery.contains("Saturday") &&
        //                    repeatEvery.contains("Sunday") &&
        //                    repeatEvery.count == 2 {
        //            return "Every weekend"
        //        } else {
        //            return "Every \(ListFormatter.localizedString(byJoining: repeatEvery))"
        //        }
        
        var str = Text("")
        
        let dayToLetter: [String: String] = ["Monday" : "M",
                                             "Tuesday" : "T",
                                             "Wednesday" : "W",
                                             "Thursday" : "T",
                                             "Friday" : "F",
                                             "Saturday" : "S",
                                             "Sunday" : "S"]
        
        let days = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
        
        for day in days {
            if repeatEvery.contains(day) {
                str = str + Text(dayToLetter[day] ?? "")
                    .foregroundColor(.primary)
                    .bold()
            } else {
                str = str + Text(dayToLetter[day] ?? "")
                    .foregroundColor(.secondary)
            }
        }
//
        
        return str
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView(category: .example)
    }
}