//
//  maintab.swift
//  DIYICI
//
//  Created by 湖光的电脑 on 2024/3/2.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    
    @StateObject var viewModel = HealthKitViewModel()
    @State private var selectedTab = 0
    @EnvironmentObject var appState: AppState
    var body: some View {
        
        VStack {
            Spacer()
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    } .tag(0).environmentObject(appState)
                
                HealthDataView()
                    .tabItem {
                        Image(systemName: "figure.walk")
                        Text("Exercise")
                    }
                    .tag(1)
                
                CategoriesView()
                    .tabItem {
                        Image(systemName: "square.grid.2x2")
                        Text("Categories")
                    }
                    .tag(2)
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                    .tag(3)
            }
            .navigationBarBackButtonHidden(true)
            
        }
    }
}
