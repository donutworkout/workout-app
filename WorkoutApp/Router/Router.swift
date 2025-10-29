import SwiftUI

enum Route {
    case onboarding
    case healthConnect
    case watchConnect
    case survey
    case menu
    case startWorkout
    case tabBar
    
    case surveyBodyInfo
    case surveyMotivation
    case editProfile
    case menstrualCycle
    
    case adjustMenuCardio
    case adjustMenuStrength
    case startCardio
    case startStrength
    case restView
}

final class Router: ObservableObject {
    @Published var path = NavigationPath()
    @Published var currentRoute: Route = .onboarding
    @Published var selectedTab: Int = 0
    
    func navigateTo(_ route: Route) {
        currentRoute = route
    }
    
    func setCurrentRoute(_ route: Route) {
        currentRoute = route
    }
}
