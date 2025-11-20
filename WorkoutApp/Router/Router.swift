import SwiftUI
import HealthKit

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
    case startWorkout
    case countdownView
    case finishWorkout
    case afterSurvey
}

@MainActor
final class Router: ObservableObject {
    @Published var currentRoute: Route = .onboarding
    @Published var isFromProfile: Bool = false
    @Published var selectedTab: Int = 0
    @Published var lastWorkoutSource: Route? = nil
    @Published var selectedWorkoutType: HKWorkoutActivityType? = nil
    @Published var selectedCardioMenu: String? = nil
    @Published var workoutExercises: [Exercise] = []
    
    @Published var selectedDailyMenu: DailyMenu? = nil
    
    @Published var cardioSpecs: CardioDetails? = nil
    @Published var vigorousDuration: Int = 0
    @Published var moderateDuration: Int = 0
    
    // In your Router class
    init(surveyManager: SurveyManager? = nil) {
        if let manager = surveyManager, manager.isSurveyComplete {
            self.currentRoute = .menu  // ✅ Start at menu if surveys done
        } else {
            self.currentRoute = .onboarding  // Start at onboarding if not
        }
    }
    
    func navigateTo(_ route: Route) {
        currentRoute = route
    }

    func goBack(to route: Route = .tabBar) {
        currentRoute = route
    }
}

