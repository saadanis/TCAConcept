//
//  CategoryEditView.swift
//  TCAConcept
//
//  Created by Saad Anis on 7/5/20.
//  Copyright © 2020 Saad Anis. All rights reserved.
//

import SwiftUI

struct CategoryEditView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var categories: Categories
    
    @State private var newName = ""
    @State private var newIconName = "note"
    @State private var newColor = Color.red
    
    let iconNames = ["note", "sunrise","sunset","sun.max","moon","snow","mic","quote.bubble","phone","envelope","book.closed","umbrella","pianokeys","gamecontroller","paintpalette","binoculars","car","airplane","bicycle"]
    let iconColors: [Color] = [.red, .pink, .purple, .orange, .yellow, .green, .blue, .gray]
    let rows =  [GridItem(.flexible())]
    
    @State var showingAlreadyExistsAlert = false
    
    @State var category: Category?
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("Category name", text: $newName)
                        //                    }
                        //                    Section(header: Text("Choose Glyph")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHGrid(rows: rows, spacing: 10) {
                                ForEach(0..<iconNames.count) { index in
                                    Button(action: {
                                        newIconName = iconNames[index]
                                        newColor = iconColors[index % iconColors.count]
                                    }) {
                                        Image(systemName: iconNames[index])
                                            .font(.title)
                                    }
                                    .foregroundColor(iconColors[index % iconColors.count])
                                    .frame(width: 20, height: 20, alignment: .center)
                                    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 10)
                                    .overlay(RoundedRectangle(cornerRadius: 4)
                                                .opacity(iconNames[index] == newIconName ? 0.08 : 0)
                                                .animation(.default))
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                newName = category?.name ?? ""
                newIconName = category?.iconName ?? "note"
                newColor = Categories.colorDict[category?.colorName ?? "red"] ?? .red
            }
            .navigationBarTitle(category == nil ? "New Category" : "Edit Category")
            .navigationBarItems(leading: Button(action: {
                // Cancel.
                presentationMode.wrappedValue.dismiss()
            }){Text("Cancel")},trailing: Button(action: {
                // Create.
                    if(alreadyExists(newName: newName)) {
                        showingAlreadyExistsAlert = true
                        return
                    }
                if(category == nil) {
                categories.addCategory(Category(name: newName, iconName: newIconName, colorName: Categories.getColorString(color: newColor)))
                } else {
                    categories.updateCategory(category: category!, newName: newName, newIconName: newIconName, newColorName: Categories.getColorString(color: newColor))
                }
                presentationMode.wrappedValue.dismiss()
            }){Text(category != nil ? "Update" : "Create")}
            .disabled(isDisabled()))
        }
        .alert(isPresented: $showingAlreadyExistsAlert) {
            Alert(title: Text("Error"), message: Text("Category with the similar name exists."), dismissButton: .default(Text("Okay")))
        }
    }
    
    func isDisabled() -> Bool {
        if(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            return true
        } else {
            return false
        }
    }
    
    func alreadyExists(newName: String) -> Bool {
        for _category in categories.categories {
            if _category.name == newName {
                if category != nil {
                    if category!.id == _category.id {
                        return false
                    }
                }
                return true
            }
        }
        return false
    }
}

struct CategoryEditView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryEditView()
    }
}
