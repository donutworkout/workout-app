//
//  Router.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 14/10/25.
//

import SwiftUI

enum Route: Hashable {
   //tambahin kalo mau buat page route baru
    case onboarding
    case survey
    case home
    case summary
    case profile
//  case
//  case
}

class Router: ObservableObject {
    @Published var path = NavigationPath()
    @Published var currentRoute: Route = .home
    @Published var selectedTab: Int = 0
    @Published var routeHistory: [Route] = []
    
    func navigateTo(_ route: Route) {
        currentRoute = route
        path.append(route)
        addToHistory(route)
    }
    
    func navigateToWithoutAnimation(_ route: Route) {
        withTransaction(.init(animation: nil)) {
            currentRoute = route
            path.append(route)
            addToHistory(route)
        }
    }
    
    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func setCurrentRoute(_ route: Route) {
        currentRoute = route
        addToHistory(route)
    }
    
    func selectTab(_ tabIndex: Int, forRoute route: Route? = nil) {
        selectedTab = tabIndex
        if let route = route {
            setCurrentRoute(route)
        }
    }
    
    private func addToHistory(_ route: Route) {
        routeHistory.append(route)
    }
}


