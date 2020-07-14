//
//  TodayView.swift
//  TCAConcept
//
//  Created by Saad Anis on 7/11/20.
//  Copyright © 2020 Saad Anis. All rights reserved.
//

import SwiftUI

struct TodayView: View {
    
    @ObservedObject var categories = Categories()
    
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .center) {
                ForEach(categories.getRoutinesForToday()) { routine in
                    NavigationLink(destination: RoutineView(routine: routine, category: categories.findCategory(for: routine))) {
                        ZStack(alignment: .top) {
                            //                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            //                            .frame(width: UIScreen.screenWidth - 15, height: categories.getTotalTime(for: routine)==0 ? 100 : (categories.getTotalTime(for: routine)>1000 ? CGFloat(categories.getTotalTime(for: routine)/10) : 100), alignment: .center)
                            //                            .foregroundColor(categories.getColor(for: routine))
                            ZStack {
                                HStack(alignment: .firstTextBaseline) {
                                    VStack(spacing: 2) {
                                        Text("\(formatter.string(from: getStartTime(routine: routine)))")
                                        //                                ForEach(1..<categories.getTotalTime(for: routine)/800) { _ in
                                        //                                    Text(" ")
                                        //                                }
                                        RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                                            .frame(width: 3, height: CGFloat(categories.getTotalTime(for: routine)/40>12 ? categories.getTotalTime(for: routine)/40 : 12), alignment: .center)
                                            .opacity(0.5)
                                        Text("\(formatter.string(from: getEndTime(routine: routine)))")
                                    }
                                    .font(.subheadline)
                                    Image(systemName: categories.getIconName(for: routine))
                                        .font(.headline)
                                    VStack(alignment: .leading) {
                                        Text(routine.name)
                                            .font(.headline)
                                        //.padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                                        Text("\(categories.getTotalTime(for: routine) > 0 ? Categories.secondsToHHMMSS(seconds: categories.getTotalTime(for: routine)) : "No time allocated")")
                                            .font(.caption)
                                    }
                                    Spacer()
                                    //.padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                                }
                                .padding(.all, 10)
                                .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundColor(categories.getColor(for: routine)))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 0)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .onAppear {
            categories.reload()
        }
        .navigationBarTitle("Today")
    }
    
    func getStartTime(routine: Routine) -> Date {
        return routine.startTime
    }
    
    func getEndTime(routine: Routine) -> Date {
        return Date(timeInterval: Double(categories.getTotalTime(for: routine)), since: routine.startTime)
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
    }
}

extension UIScreen{
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}
