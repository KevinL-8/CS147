//
//  tab3.swift
//  DIYICI
//
//  Created by 湖光的电脑 on 2024/3/2.
//

//import Foundation
//import SwiftUI
//
//struct CategoriesView: View {
//    var body: some View {
//        Text("Categories Tab")
//    }
//}


import Foundation
import SwiftUI

struct CategoryItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String // This could be an image name from your assets
}

struct CategoriesView: View {
    // Sample categories
    let categories: [CategoryItem] = [
        CategoryItem(name: "Fitness", icon: "figure.walk"),
        CategoryItem(name: "Nutrition", icon: "leaf"),
        CategoryItem(name: "Wellness", icon: "heart"),
        CategoryItem(name: "Sleep", icon: "moon.stars"),
        // Add more categories as needed
    ]
    
    // Define the grid layout
    private var gridLayout: [GridItem] = Array(repeating: .init(.flexible()), count: 2) // Adjust count for number of columns
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridLayout, spacing: 20) {
                ForEach(categories) { category in
                    CategoryView(category: category)
                }
            }
            .padding()
        }
        .navigationTitle("Categories")
    }
}

struct CategoryView: View {
    let category: CategoryItem
    
    var body: some View {
        VStack {
            Image(systemName: category.icon) // Consider using custom images
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.blue)
                .padding()
            Text(category.name)
                .font(.headline)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
    }
}
