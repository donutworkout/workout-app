import SwiftUI

enum Route {
    case onboarding
    case healthConnect
    case watchConnect
    case survey
    case tabBar
    case menu
    case profile
    case adjustMenuCardio
    case adjustMenuStrength
    case startCardio
    case startStrength
    case restView
    case editBodyInfo
    case editMotivation
    case editProfile
    case menstrualCycle
    case startWorkout
    case countdownView
}

final class Router: ObservableObject {
    @Published var currentRoute: Route = .onboarding
    @Published var isFromProfile: Bool = false
    @Published var selectedTab: Int = 0
    @Published var lastWorkoutSource: Route? = nil   // ✅ tambahkan ini

    func navigateTo(_ route: Route) {
        currentRoute = route
    }

    func goBack(to route: Route = .tabBar) {
        currentRoute = route
    }
}
