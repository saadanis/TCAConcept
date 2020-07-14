//
//  SettingsView.swift
//  TCAConcept
//
//  Created by Saad Anis on 7/13/20.
//  Copyright © 2020 Saad Anis. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @State private var defaultSelection = UserDefaults.standard.string(forKey: "StartPage") ?? "Home"
    @State private var categories = Categories()
    
    var body: some View {
        NavigationView {
            Form {
                // Option: Choose a default home page.
                Picker(selection: $defaultSelection, label: Text("Start Page")) {
                    HStack {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag("Home")
                    HStack {
                        Image(systemName: "deskclock")
                        Text("Today")
                    }
                    .tag("Today")
                    HStack {
                        Image(systemName: "calendar")
                        Text("Upcoming")
                    }
                    .tag("Upcoming")
                    HStack {
                        Image(systemName: "tray")
                        Text("Inbox")
                    }
                    .tag("Inbox")
                    ForEach(categories.categories) { category in
                        HStack {
                            Image(systemName: category.iconName)
                                .foregroundColor(Categories.colorDict[category.colorName])
                            Text(category.name)
                        }
                        .tag(category.name)
                    }
                }
            }
            .navigationBarTitle(Text("Settings"))
            .navigationBarItems(leading: Button(action: {
                // Cancel.
                
            }) {
                Text("Cancel")
            }, trailing: Button(action: {
                // Save.
                UserDefaults.standard.set(self.defaultSelection, forKey: "StartPage")
            }) {
                Text("Save")
            })
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
