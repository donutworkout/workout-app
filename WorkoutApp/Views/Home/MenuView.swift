import SwiftUI
import SwiftData

struct MenuView: View {
    @EnvironmentObject var router: Router
    
    @Query private var userCycles: [UserCycle]
    @Query private var userProfiles: [UserProfile]
    @Query private var userWorkouts: [UserWorkout]
    
    @StateObject var cycleViewModel: CycleViewModel
    @StateObject var menuViewModel: MenuViewModel
    @State private var selectedDay: Int = Calendar.current.component(.weekday, from: Date()) - 1
    
    private var userCycle: UserCycle? {
        userCycles.first
    }
    
    private var userProfile: UserProfile? {
        userProfiles.first
    }
    
    private var userWorkout: UserWorkout? {
        userWorkouts.first
    }
    
    private var selectedPhase: MenstrualPhase {
        cycleViewModel.phase(for: cycleViewModel.selectedDayIndex) ?? .menstruation
    }
    
    private var selectedDate: Date {
        cycleViewModel.dateForSelectedDay()
    }
    
    private var selectedDayMenu: DailyMenu? {
        menuViewModel.getMenuForDate(selectedDate)
    }
    
    init(modelContext: ModelContext) {
        // Create placeholder ViewModel (will be replaced)
        let placeholder = UserCycle(
            isCycleRegular: true,
            cycleStartDate: Date(),
            cycleEndDate: Date(),
            cycleLength: 28,
            menstrualDuration: 5,
            cycleSymptoms: [],
            cycleEnergy: .stable,
            cycleMoodAffectsMotivation: .never
        )
        _cycleViewModel = StateObject(wrappedValue: CycleViewModel(userCycle: placeholder))
        _menuViewModel = StateObject(wrappedValue: MenuViewModel(modelContext: modelContext))
    }
    
    private var currentPhase: MenstrualPhase {
        cycleViewModel.phase(for: cycleViewModel.selectedDayIndex) ?? .menstruation
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Header
                Text("Menu")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 32)
                    .padding(.horizontal, 20)
                
                // MARK: - Day Selector
                DaySelectorView(selectedDay: $cycleViewModel.selectedDayIndex)
                
                // MARK: - Workout Card
                CombinedWorkoutCardView(
                    phase: selectedPhase,
                    menu: selectedDayMenu,
                    onStartWorkout: {
                        if let menu = selectedDayMenu {
                            if menu.isCardio {
                                router.navigateTo(.adjustMenuCardio)
                            } else if menu.isStrength {
                                router.navigateTo(.adjustMenuStrength)
                            }
                        } else {
                            // Fallback based on phase
                            if selectedPhase == .menstruation {
                                router.navigateTo(.adjustMenuCardio)
                            } else {
                                router.navigateTo(.adjustMenuStrength)
                            }
                        }
                        
                    })
                
                // MARK: - Streak Section
                VStack(spacing: 8) {
                    Text("Streak")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    StreakCardView()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            loadWeeklyMenu()
        }
    }
    
}

struct CombinedWorkoutCardView: View {
    let phase: MenstrualPhase
    let menu: DailyMenu?
    var onStartWorkout: () -> Void
    
    private var cardInfo: (image: String, workoutTitle: String, phaseDesc: String, duration: String) {
        // Get workout type from menu, fallback to phase
        let isCardioDay: Bool
        let isStrengthDay: Bool
        
        if let menu = menu {
            isCardioDay = menu.isCardio
            isStrengthDay = menu.isStrength
        } else {
            // Fallback based on phase: menstruation -> cardio, others -> strength
            isCardioDay = (phase == .menstruation)
            isStrengthDay = !isCardioDay
        }
        
        // Get duration from menu (default to 30 min for now)
        let duration: String = "30 min"
        
        // Determine card content
        if isCardioDay {
            return (
                "buttercup",
                "Today's Cardio Menu!",
                "Don't worry about being perfect! just move and let your body wake up!",
                duration
            )
        } else if isStrengthDay {
            return (
                "bubbles",
                "Today's Strength Menu!",
                "Let's wake up those muscles just good vibes and sweat!",
                duration
            )
        } else {
            return (
                "bubbles",
                "Time to rest",
                "Take your time to relax and enjoy the day!",
                duration
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // MARK: - Phase Header
            Text("\(phase.rawValue.capitalized) Phase")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 17,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 17,
                        style: .continuous
                    )
                    .fill(Color("pinkTextTertiary"))
                )
            
            // MARK: - Abu-abu dan Gambar
            ZStack {
                // Abu-abu full kiri-kanan
                Color.gray.opacity(0.15)
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipShape(Rectangle())
                
                // Gambar di tengah
                Image(cardInfo.image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
            }
            
            // MARK: - Konten bawah (judul, deskripsi, tombol)
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center) {
                        Text(cardInfo.workoutTitle)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if (menu?.isCardio ?? false) || (menu?.isStrength ?? false) {
                            Text(cardInfo.duration)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.black.opacity(0.7))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.gray.opacity(0.2))
                                )
                                .fixedSize()
                        }
                    }
                    
                    Text(cardInfo.phaseDesc)
                        .font(.system(size: 14))
                        .foregroundColor(.black.opacity(0.7))
                        .lineSpacing(3)
                }
                if (menu?.isCardio ?? false) || (menu?.isStrength ?? false) {
                    PrimaryGlassButton(title: "Start Workout", action: onStartWorkout)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Day Selector
struct DaySelectorView: View {
    @Binding var selectedDay: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<7) { index in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedDay = index
                    }
                } label: {
                    Circle()
                        .fill(selectedDay == index ? Color("pinkTextPrimary") : Color("pinkTextTertiary"))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(String(Calendar.current.shortWeekdaySymbols[index].prefix(1)))
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                        )
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Phase Card
struct PhaseCardView: View {
    let phase: MenstrualPhase
    
    private var phaseInfo: (desc: String, mood: String) {
        switch phase {
        case .menstruation:
            return (
                "Take it slow today ✨Your body's busy doing internal magic – it's okay to rest or move gently.",
                "Mood note: Self-care focus."
            )
        case .follicular:
            return (
                "You're glowing, girl! Perfect time to try new moves or push a little more.",
                "Mood note: Rising energy, motivation boost, open to challenges."
            )
        case .luteal:
            return (
                "You're glowing, girl! Perfect time to try new moves or push a little more.",
                "Mood note: Rising energy, motivation boost, open to challenges."
            )
        case .ovulation:
            return (
                "You're glowing, girl! Perfect time to try new moves or push a little more.",
                "Mood note: Rising energy, motivation boost, open to challenges."
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(phase.rawValue)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)
            
            Text(phaseInfo.desc)
                .font(.system(size: 15))
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .lineSpacing(4)
            
            // Pink bar dengan rounded corners seperti di foto
            Text(phaseInfo.mood)
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color("pinkTextPrimary").opacity(0.15))
                )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
}

// MARK: - Streak Card
struct StreakCardView: View {
    //    let phase: PhaseType
    //
    //    private var streakInfo: (title: String, desc: String) {
    //        switch phase {
    //        case .menstrual:
    //            return ("You're on a roll!", "Another checkmark for the consistency queen!")
    //        case .follicular:
    //            return ("Go Girl!", "Don’t break it, bestie! You’re killing it!")
    //        }
    //    }
    
    var body: some View {
        HStack(spacing: 16) {
            Text("🔥")
                .font(.system(size: 48))
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Streak")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                Text("You go girl!")
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .lineSpacing(3)
            }
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Enum
enum PhaseType: String {
    case menstrual = "Menstrual Phase"
    case follicular = "Follicular Phase"
}

extension MenuView {
    private func loadWeeklyMenu() {
        guard let cycle = userCycle, let profile = userWorkout else { return }
        
        // Get user's chosen days (you need to fetch this from somewhere)
        let chosenDays: [WorkoutDayPreference] = profile.workoutDaysPreference // TODO: Get from profile
        print("Chosen days: \(chosenDays.map { $0.rawValue })")
        
        Task {
            await menuViewModel.generateWeeklyMenu(
                userCycle: cycle,
                userLevel: profile.workoutLevel,
                chosenDays: chosenDays
            )
        }
    }
}

//#Preview {
//    MenuView(modelContext: ModelContext)
//        .environmentObject(Router())
//}

