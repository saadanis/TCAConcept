//
//  ContentView.swift
//  TCAConcept
//
//  Created by Saad Anis on 7/3/20.
//  Copyright © 2020 Saad Anis. All rights reserved.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    
    @ObservedObject var categories = Categories()
    @State private var showingAddCategory = false
    @State private var showingSettingsView = false
    
    @State var startPage: String
    
    //    @State var isTrue: Bool = true
    
    var body: some View {
        NavigationView() {
            List {
                CurrentlyRunning()
                QuickLook()
                    .sheet(isPresented: $showingSettingsView) {
                        SettingsView()
                    }
                    .environmentObject(categories)
                Section(header: Text("Categories")) {
                    ForEach(self.categories.categories) { category in
                        if category.name != "Inbox" {
                            NavigationLink(destination: CategoryView(category: category)) {
                                Image(systemName: category.iconName)
                                    .foregroundColor(Categories.colorDict[category.colorName])
                                Text(category.name)
                            }
                        }
                    }
                    .onDelete(perform: categories.deleteCategory)
                    .onMove(perform: categories.moveCategory)
                    
                    // Add Category button.
                    Button(action: { self.showingAddCategory = true }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Category")
                        }
                    }
                    .sheet(isPresented: $showingAddCategory) {
                        CategoryEditView()
                            .environmentObject(categories)
                    }
                }
            }
            .onAppear {
                categories.reload()
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("TCAConcept"))
            .navigationBarItems(leading: Button(action: {
                showingSettingsView = true
            }){
                Image(systemName: "gearshape")
            },trailing:
                EditButton()
            )
        }
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: CurrentlyRunning View
struct CurrentlyRunning: View {
    var body: some View {
        Section(header: Text("Currently Running")) {
            NavigationLink(destination: Text("")) {
                HStack {
                    Image(systemName: "timer")
                    VStack(alignment: .leading) {
                        Text("Brush Teeth")
                        Text("Wake Up")
                            .font(.caption)
                    }
                    Spacer()
                    Text("0:04:20")
                }
                .foregroundColor(.red)
            }
        }
    }
}

// MARK: Quick Look View
struct QuickLook: View {
    @State private var todayViewIsActive = true
    @EnvironmentObject var categories: Categories
    
    var body: some View {
        Section {
            //            NavigationLink(destination: CategoryView(category: categories.getInbox())) {
            //                HStack {
            //                    Image(systemName: "tray")
            //                        .foregroundColor(.purple)
            //                    Text("Inbox")
            //                }
            //            }
            NavigationLink(destination: TodayView(), isActive: $todayViewIsActive) {
                HStack {
                    Image(systemName: "deskclock")
                        .foregroundColor(.pink)
                    Text("Today")
                }
            }
            NavigationLink(destination: Text("Upcoming")) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.red)
                    Text("Upcoming")
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(startPage: "Home")
    }
}
