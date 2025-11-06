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
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // MARK: - Menu Tab
            MenuView(modelContext: modelContext)
                .tabItem {
                    Label("Menu", systemImage: "menucard.fill")
                }
                .tag(0)
            
            // MARK: - Summary Tab
            SummaryView()
                .tabItem {
                    Label("Summary", systemImage: "text.line.3.summary")
                }
                .tag(1)
            
            // MARK: - Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(2)
        }
        .accentColor(Color("pinkTextPrimary")) // warna pink kamu
        .onAppear {
            router.selectedTab = selectedTab
        }
        .onChange(of: selectedTab) { _, newValue in
            router.selectedTab = newValue
        }
    }
}

#Preview {
    TabBarView()
        .environmentObject(Router())
}
