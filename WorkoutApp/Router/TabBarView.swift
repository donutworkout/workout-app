//
//  TabBarView.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 17/10/25.
//

import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var router: Router
    @State private var previousTab: Int = 0
    
    var body: some View {
        TabView(selection: $router.selectedTab) {
            //View()
            //.tag(0)
            //.tabItem { Label("Home", systemImage: "") }
            
            //View()
            //.tag(1)
            //.tabItem { Label("Summary", systemImage: "") }
            
            //View()
            //.tag(2)
            //.tabItem { Label("History", systemImage: "") }
    }
        .accentColor(Color.blue)
        .onChange(of: router.selectedTab) {_, newTab in
            if previousTab != newTab {
                let route: Route
                switch newTab {
                case 0:
                    route = .home
                case 1:
                    route = .summary
                case 2:
                    route = .profile
                default:
                    route = .home
                }
                router.setCurrentRoute(route)
                previousTab = newTab
            }
        }
        .onAppear {
            router.setCurrentRoute(.home)
            previousTab = router.selectedTab
        }
    }
}

#Preview {
    NavigationStack {
        TabBarView()
            .environmentObject(Router())
    }
}

