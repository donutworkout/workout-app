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
                if surveyManager.isSurveyComplete {
                    TabBarView()
                        .environmentObject(router)
                        .environmentObject(surveyManager)
                        .onAppear {
                            router.currentRoute = .menu
                        }
                } else {
                    OnboardingView()
                        .environmentObject(router)
                }
                
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
                AdjustMenuCardioView(
                    dailyMenu: router.selectedDailyMenu,
                    vigorousDuration: router.vigorousDuration,
                    moderateDuration: router.moderateDuration)
                    .environmentObject(router)
                //.environment(connectivity)
                
            case .adjustMenuStrength:
                AdjustMenuStrengthView(dailyMenu: router.selectedDailyMenu)
                    .environmentObject(router)
                //.environment(connectivity)
                
            case .finishWorkout:
                FinishWorkoutView()
                    .environmentObject(router)
                
            case .startCardio:
                StartCardioView()
                    .environmentObject(router)
                
            case .startStrength:
                StartStrengthView()
                    .environmentObject(router)
                    .environmentObject(sessionManager)
                
            case .restView:
                RestView(onNext: {
                    sessionManager.moveToNextExercise()
                    router.navigateTo(.startStrength)
                }, level: surveyManager.tempWorkoutLevel)
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
                    AdjustMenuCardioView(dailyMenu: router.selectedDailyMenu)
                    .environmentObject(router)
                    //.environment(connectivity)
                } else {
                    AdjustMenuStrengthView()
                        .environmentObject(router)
                    //.environment(connectivity)
                }
                
                
            case .countdownView:
                if let last = router.lastWorkoutSource {
                    switch last {
                    case .adjustMenuCardio:
                        CountdownCardioView(
                            activityName: router.selectedCardioMenu ?? "Cardio",
                            imageName: router.selectedCardioMenu?
                                .lowercased()
                                .replacingOccurrences(of: " ", with: "") ?? "indoorWalk",
                            onCountdownComplete: {
                                print("🚀 CountdownCardio selesai → ke StartCardioView")
                                router.navigateTo(.startCardio)
                            }
                        )
                        .environmentObject(router)
                        .environment(iPhoneConnectivityManager.shared)
                        
                    case .adjustMenuStrength:
                        CountdownView(
                            exercises: router.workoutExercises,
                            onCountdownComplete: {
                                print("🚀 CountdownStrength selesai → ke StartStrengthView")
                                router.navigateTo(.startStrength)
                            }
                        )
                        .environmentObject(router)
                        .environmentObject(sessionManager)
                        
                        // fallback kalau undefined
                    default:
                        VStack {
                            Text("⚠️ Workout Source Not Found")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Button("Back to Menu") {
                                router.navigateTo(.menu)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                } else {
                    VStack {
                        Text("⚠️ No workout source set")
                        Button("Back to Menu") {
                            router.navigateTo(.menu)
                        }
                    }
                }
            case .afterSurvey:
                AfterSurveyView()
                    .environmentObject(router)
            }
        }
        .onAppear {
            // ✅ Check on first appear and navigate if needed
            if router.currentRoute == .onboarding && surveyManager.isSurveyComplete {
                router.currentRoute = .menu
            }
        }
    }
}
