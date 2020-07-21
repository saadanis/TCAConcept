//
//  TCAConceptApp.swift
//  TCAConcept
//
//  Created by Saad Anis on 7/14/20.
//

import SwiftUI

@main
struct TCAConceptApp: App {
    
    var defaultStartPage = UserDefaults.standard.string(forKey: "StartPage") ?? "Home"
    
    var body: some Scene {
        WindowGroup {
            switch(defaultStartPage) {
            case "Today":
                TodayView()
            case "Upcoming":
                TodayView()
            case "Inbox":
                TodayView()
            default:
                ContentView(startPage: "")
            }
   //         ContentView()
        }
    }
}
