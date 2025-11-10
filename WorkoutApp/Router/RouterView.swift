import SwiftUI

struct RouterView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var surveyManager: SurveyManager
    @Environment(iPhoneConnectivityManager.self) private var connectivity
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var sessionManager: StrengthSessionManager
    
    var body: some View {
        NavigationStack {
            switch router.currentRoute {
                
            // MARK: - Onboarding & Setup Flow
            case .onboarding:
                OnboardingView()
                    .environmentObject(router)
                
            case .healthConnect:
                HealthConnectView(
                    onAllow: { router.navigateTo(.watchConnect) },
                    onSkip: { router.navigateTo(.watchConnect) }
                )
                .environmentObject(router)
                
            case .watchConnect:
                ConnectWatchView(
                    onAllow: { router.navigateTo(.survey) },
                    onSkip: { router.navigateTo(.survey) }
                )
                .environmentObject(router)
                
            case .survey:
                SurveyView()
                    .environmentObject(router)
                    .environmentObject(surveyManager)
                
            // MARK: - Main App Flow
            case .tabBar, .menu, .profile:
                TabBarView()
                    .environmentObject(router)
                    .environmentObject(surveyManager)
                
            // MARK: - Workout Flow
            case .adjustMenuCardio:
                AdjustMenuCardioView()
                    .environmentObject(router)
                    .environment(connectivity)
                
            case .adjustMenuStrength:
                AdjustMenuStrengthView()
                    .environmentObject(router)
                    .environment(connectivity)
                
            case .startCardio:
                StartCardioView()
                    .environmentObject(router)
                
            case .startStrength:
                StartStrengthView()
                    .environmentObject(router)
                    .environmentObject(sessionManager)
                
            case .restView:
                RestView(onNext: {
//                    sessionManager.moveToNextExercise()
                    router.navigateTo(.startStrength)
                })
                .environmentObject(router)
                
            // MARK: - Profile Section (Tetap di dalam TabBar)
//            case .editBodyInfo:
//                TabBarView(selectedTab: 2) // tab ke-2 = Profile
//                    .environmentObject(router)
//                    .environmentObject(surveyManager)
//                
//            case .editMotivation:
//                TabBarView(selectedTab: 2)
//                    .environmentObject(router)
//                    .environmentObject(surveyManager)
//                
//            case .editProfile:
//                TabBarView(selectedTab: 2)
//                    .environmentObject(router)
//                    .environmentObject(surveyManager)
//                
//            case .menstrualCycle:
//                TabBarView(selectedTab: 2)
//                    .environmentObject(router)
//                    .environmentObject(surveyManager)
                
            // MARK: - Workout Start Flow
            case .startWorkout:
                let weekday = Calendar.current.component(.weekday, from: Date())
                if weekday % 2 == 0 {
                    AdjustMenuCardioView()
                        .environmentObject(router)
                } else {
                    AdjustMenuStrengthView()
                        .environmentObject(router)
                }
                
            case .countdownView:
                CountdownView(exercises: router.workoutExercises, onCountdownComplete: {
                    if let last = router.lastWorkoutSource {
                        switch last {
                        case .adjustMenuCardio:
                            router.navigateTo(.startCardio)
                        case .adjustMenuStrength:
                            router.navigateTo(.startStrength)
                        default:
                            router.navigateTo(.menu)
                        }
                    }
                })
                .environmentObject(router)
                .environmentObject(sessionManager)
            }
        }
    }
}
