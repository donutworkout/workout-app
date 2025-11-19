import HealthKit
import SwiftUI
import SwiftData

struct AdjustMenuCardioView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Router
    @Environment(\.modelContext) private var modelContext
    
    @Environment(iPhoneConnectivityManager.self) private var connectivity
    
    @Query private var weeklyMenu: [DailyMenu]
    @Query private var userWorkouts: [UserWorkout]
    @Query private var userCycle: [UserCycle]
    
    @State private var selectedMenu: String? = nil
    @State private var showCustomAlert = false
    var onNext: () -> Void = {}
    
    // MARK: - Cardio Menu (Dipisah per durasi)
    private let oneHourMenu = [
        "Outdoor Walk", "Indoor Walk",
        "Cycling", "Swimming"
    ]
    
    private let thirtyMinuteMenu = [
        "Badminton", "Basketball",
        "Volleyball", "Tennis",
        "Outdoor Run", "Indoor Run"
    ]
        
    private var userLevel: WorkoutLevel {
        userWorkouts.first?.workoutLevel ?? .beginner
    }
    
    private var currentPhase: MenstrualPhase {
        guard let cycle = userCycle.first else { return .menstruation }
        
        let calendar = Calendar.current
        let daysSinceStart = calendar.dateComponents(
            [.day],
            from: cycle.cycleStartDate,
            to: Date()
        ).day ?? 0
        
        let currentDayInCycle = (daysSinceStart % cycle.cycleLength) + 1
        
        return CyclePhaseCalculator.phaseForDay(
            currentDayInCycle,
            cycleLength: cycle.cycleLength,
            periodDuration: cycle.menstrualDuration
        )
    }
    
    private var cardioSpecs: CardioDetails {
        let generator = WorkoutMenuGenerator(context: modelContext)
        return generator.getCardioSpecs(for: userLevel, phase: currentPhase)
    }
    
    private var vigorousDuration: Int {
        let cardioDays = weeklyMenu.filter { $0.category == .cardio }.count
        let vigorous = cardioSpecs.vigorousDuration / cardioDays
        
        return vigorous
    }
    
    private var moderateDuration: Int {
        let cardioDays = weeklyMenu.filter { $0.category == .cardio }.count
        let moderate = cardioSpecs.moderateDuration / cardioDays
        
        return moderate
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                // MARK: - 1 Hour Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Duration \(moderateDuration) Minutes")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    
                    menuGrid(for: oneHourMenu)
                }
                .padding(.top, 24)
                
                // MARK: - 30 Minute Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Duration \(vigorousDuration) Minutes")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    
                    menuGrid(for: thirtyMinuteMenu)
                }
                
                Spacer()
                
                // MARK: - Start Button (Disabled if no selection)
                PrimaryGlassButton(title: "Start Now") {
                    guard let selectedMenu = selectedMenu else {
                        showCustomAlert = true
                        return
                    }
                    
                    let type = mapActivityToHKType(selectedMenu)
                    router.selectedWorkoutType = type
                    router.selectedCardioMenu = selectedMenu
                    connectivity.startWorkoutFromPhone(type: type)
                    
                    router.lastWorkoutSource = .adjustMenuCardio
                    router.navigateTo(.countdownView)
                }
                .padding(.horizontal)
                .padding(.vertical)
                .opacity(isButtonEnabled ? 1 : 0.5)
                .disabled(!isButtonEnabled)  // 🔒 disable kalau belum pilih
            }
            .background(Color.white.ignoresSafeArea())
            
            // MARK: - Custom Alert Overlay
            if showCustomAlert {
                customAlert
            }
        }
        .navigationTitle("Today’s Cardio Menu!")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { router.navigateTo(.menu) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
    }
    
    
    // MARK: - GRID COMPONENT
    private func menuGrid(for menu: [String]) -> some View {
        let gridItems = [GridItem(.flexible()), GridItem(.flexible())]
        
        return LazyVGrid(columns: gridItems, spacing: 16) {
            ForEach(menu, id: \.self) { activity in
                Button(action: {
                    handleSelection(for: activity)
                }) {
                    Text(activity)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(
                            selectedMenu == activity ? .white : .black
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    selectedMenu == activity
                                    ? Color("pinkTextPrimary")
                                    : Color.white
                                )
                                .shadow(color: .gray.opacity(0.15),
                                        radius: 5, x: 0, y: 3)
                        )
                }
                .animation(.easeInOut(duration: 0.2), value: selectedMenu)
            }
        }
        .padding(.horizontal)
    }
    
    
    // MARK: - Logic
    private func handleSelection(for activity: String) {
        if selectedMenu == activity {
            selectedMenu = nil
        } else {
            selectedMenu = activity
            HapticManager.shared.trigger(.adjustReps)
            let type = mapActivityToHKType(activity)
            router.selectedWorkoutType = type
            iPhoneConnectivityManager.shared.sendSelectedWorkout(type)
        }
    }
    
    private var isButtonEnabled: Bool {
        selectedMenu != nil
    }
    
    
    // MARK: - Custom Alert
    private var customAlert: some View {
        VStack {
            Color.white.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("Oops!")
                    .font(.system(size: 20, weight: .semibold))
                
                Text("Please pick one cardio activity to begin.")
                    .font(.system(size: 15))
                    .multilineTextAlignment(.center)
                
                Button("Okay") {
                    withAnimation { showCustomAlert = false }
                }
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color("pinkTextPrimary"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 20)
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .cornerRadius(28)
            .shadow(radius: 10)
        }
        .transition(.opacity)
    }
}

#Preview {
    NavigationStack {
        AdjustMenuCardioView()
    }
}
