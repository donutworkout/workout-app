//
//  TabBarView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 29/10/25.
//

import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var router: Router
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // MARK: - Menu Tab
            MenuView()
                .tabItem {
                    Label("Menu", systemImage: "house.fill")
                }
                .tag(0)
            
            // MARK: - Summary Tab
            SummaryView()
                .tabItem {
                    Label("Summary", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            // MARK: - Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(Color("pinkTextPrimary")) // warna pink kamu
        .onAppear {
            router.selectedTab = selectedTab
        }
        .onChange(of: selectedTab) { newValue in
            router.selectedTab = newValue
        }
    }
}

#Preview {
    TabBarView()
        .environmentObject(Router())
}
