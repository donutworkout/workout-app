import SwiftUI

struct RouterView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var surveyManager: SurveyManager
    @Environment(iPhoneConnectivityManager.self) private var connectivity
    @Environment(\.modelContext) private var modelContext
    
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
            case .tabBar:
                TabBarView()
                    .environmentObject(router)
                    .environmentObject(surveyManager)
                
            case .menu:
                MenuView(modelContext: modelContext)
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
                
            case .restView:
                RestView(onNext: {
                    router.navigateTo(.startStrength)
                })
                .environmentObject(router)
                
                // MARK: - Profile Section Routes
            case .profile:
                ProfileView()
                    .environmentObject(router)
                
            case .editBodyInfo:
                EditBodyInfoView()
                    .environmentObject(router)
                
            case .editMotivation:
                EditMotivationView()
                    .environmentObject(router)
                
            case .editProfile:
                EditProfileView()
                
            case .menstrualCycle:
                MenstrualCycleView()
                
            case .startWorkout:
                // Misal: tentukan jenis workout berdasarkan hari
                let weekday = Calendar.current.component(.weekday, from: Date())
                if weekday % 2 == 0 {
                    AdjustMenuCardioView()
                        .environmentObject(router)
                } else {
                    AdjustMenuStrengthView()
                        .environmentObject(router)
                }
            case .countdownView:
                CountdownView(onCountdownComplete: {
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
            }
        }
    }
}
