import SwiftUI
import SwiftData

struct MenuView: View {
    @EnvironmentObject var router: Router
    @Environment(\.modelContext) private var modelContext
    
    @Query private var menus: [DailyMenu]
    @Query private var userCycles: [UserCycle]
    @Query private var userProfiles: [UserProfile]
    @Query private var userWorkouts: [UserWorkout]
    
    @StateObject var cycleViewModel: CycleViewModel
    @StateObject var menuViewModel: MenuViewModel
//    @State private var selectedDayIndex: Int = 0
    
    @State private var cardioSpecs: CardioDetails?
    @State private var vigorousDuration: Int = 0
    @State private var moderateDuration: Int = 0
    
    // MARK: - Animation States
    @State private var showContent: Bool = false
    @State private var workoutCardScale: CGFloat = 0.5
    @State private var workoutCardOpacity: Double = 0
    @State private var streakCardOffset: CGFloat = 50
    
    private var userCycle: UserCycle? {
        userCycles.first
    }
    
    private var userProfile: UserProfile? {
        userProfiles.first
    }
    
    private var userWorkout: UserWorkout? {
        userWorkouts.first
    }
    
    private var selectedDate: Date {
        dateForIndex(cycleViewModel.selectedDayIndex)
    }
    
    private var selectedPhase: MenstrualPhase {
        let phase = cycleViewModel.phase(for: cycleViewModel.selectedDayIndex) ?? .menstruation
//        
//        print("🔍 selectedDayIndex: \(cycleViewModel.selectedDayIndex)")
//        print("🔍 selectedPhase from ViewModel: \(phase)")
//        print("🔍 phasesForWeek count: \(cycleViewModel.phasesForWeek.count)")
        
        // Debug: print all phases
//        for (index, phaseData) in cycleViewModel.phasesForWeek.enumerated() {
//            print("🔍 Index \(index): \(phaseData.date) -> \(phaseData.phase)")
//        }
        
        return phase
    }
    
    private var selectedDayMenu: DailyMenu? {
        menuViewModel.getMenuForDate(selectedDate)
    }
    
    init(modelContext: ModelContext) {
        //self.modelContext = modelContext
        
        // Load existing UserCycle from database
        let cycleFetch = FetchDescriptor<UserCycle>()
        let cycles = (try? modelContext.fetch(cycleFetch)) ?? []
        
        // Use existing cycle or create a default one
        let existingCycle: UserCycle
        if let firstCycle = cycles.first {
            existingCycle = firstCycle
        } else {
            // Create default cycle only if none exists
            existingCycle = UserCycle(
                isCycleRegular: true,
                cycleStartDate: Date(),
                cycleEndDate: Date(),
                cycleLength: 28,
                menstrualDuration: 5,
                cycleSymptoms: [],
                cycleEnergy: .stable,
                cycleMoodAffectsMotivation: .sometimes
            )
            modelContext.insert(existingCycle)
        }
        
        _cycleViewModel = StateObject(wrappedValue: CycleViewModel(userCycle: existingCycle))
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
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : -20)
                
                // MARK: - Day Selector
                DaySelectorView(
                    selectedDayIndex: $cycleViewModel.selectedDayIndex,
                    userCycle: userCycle)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : -20)
                
                // MARK: - Workout Card
                CombinedWorkoutCardView(
                    phase: selectedPhase,
                    menu: selectedDayMenu,
                    vigorousDuration: vigorousDuration,
                    moderateDuration: moderateDuration,
                    onStartWorkout: {
                        if let menu = selectedDayMenu {
                            router.vigorousDuration = vigorousDuration
                            router.moderateDuration = moderateDuration
                            router.cardioSpecs = cardioSpecs
                            
                            if menu.isCardio {
                                router.selectedDailyMenu = menu
                                router.navigateTo(.adjustMenuCardio)
                            } else if menu.isStrength {
                                router.selectedDailyMenu = menu
                                router.navigateTo(.adjustMenuStrength)
                            }
                        }
                    })
                    .scaleEffect(workoutCardScale)
                    .opacity(workoutCardOpacity)
                    .rotation3DEffect(
                        .degrees(showContent ? 0 : 15),
                        axis: (x: 0, y: 1, z: 0)
                    )
                
                // MARK: - Streak Section
                VStack(spacing: 8) {
                    Text("Streak")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    StreakCardView()
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: streakCardOffset)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            if let cycle = userCycle {
                cycleViewModel.updateCycle(cycle)
                print("USERCYCLE ON MENUVIEW UPDATED")
            }
            
            cycleViewModel.selectedDayIndex = todayIndex()
            loadWeeklyMenu()
            calculateCardioSpecs()
            
            // Start entrance animation
            startEntranceAnimation()
        }
    }
    
    // MARK: - Entrance Animation Sequence
    private func startEntranceAnimation() {
        // Step 1: Show header and day selector (0.3s delay)
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            showContent = true
        }
        
        // Step 2: Workout card pop in with bounce (0.5s delay)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5)) {
            workoutCardScale = 1.0
            workoutCardOpacity = 1.0
        }
        
        // Step 3: Streak card slide up (0.8s delay)
        withAnimation(.easeOut(duration: 0.5).delay(0.8)) {
            streakCardOffset = 0
        }
    }
    
    private func weekDates() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        
        // Calculate days to Monday (weekday 2)
        let daysToMonday = weekday == 1 ? -6 : -(weekday - 2)
        
        guard let monday = calendar.date(byAdding: .day, value: daysToMonday, to: today) else {
            return []
        }
        
        return (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: monday)
        }
    }
    
    // Convert index to date
    private func dateForIndex(_ index: Int) -> Date {
        let dates = weekDates()
        guard index >= 0 && index < dates.count else { return Date() }
        return dates[index]
    }
    
    // Get today's index (0-6)
    private func todayIndex() -> Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        // Convert: Sunday=1 -> 6, Monday=2 -> 0, ..., Saturday=7 -> 5
        return weekday == 1 ? 6 : weekday - 2
    }
    
    // Calculate phase for a date
    private func phaseForDate(_ date: Date, cycle: UserCycle) -> MenstrualPhase {
        let calendar = Calendar.current
        let startOfDate = calendar.startOfDay(for: date)
        let startOfLastPeriod = calendar.startOfDay(for: cycle.cycleStartDate)
        
        let daysSinceStart = calendar.dateComponents([.day], from: startOfLastPeriod, to: startOfDate).day ?? 0
        let currentDayInCycle = (daysSinceStart % cycle.cycleLength) + 1
        
        return CyclePhaseCalculator.phaseForDay(
            currentDayInCycle,
            cycleLength: cycle.cycleLength,
            periodDuration: cycle.menstrualDuration
        )
    }
    
    private func calculateCardioSpecs() {
        guard let workout = userWorkouts.first,
              let cycle = userCycles.first else { return }
        
        let phase = CyclePhaseCalculator.calculateCurrentPhase(
            lastPeriodStart: cycle.cycleStartDate,
            cycleLength: cycle.cycleLength,
            menstrualDuration: cycle.menstrualDuration
        )
        
        let generator = WorkoutMenuGenerator(context: modelContext)
        cardioSpecs = generator.getCardioSpecs(for: workout.workoutLevel, phase: phase)
        
        let cardioDays = menus.filter { $0.category == .cardio }.count
        
        if let specs = cardioSpecs, cardioDays > 0 {
            vigorousDuration = specs.vigorousDuration / cardioDays
            moderateDuration = specs.moderateDuration / cardioDays
        }
    }
    
}

struct CombinedWorkoutCardView: View {
    @EnvironmentObject var router: Router
    
    let phase: MenstrualPhase
    let menu: DailyMenu?
    let vigorousDuration: Int
    let moderateDuration: Int
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
        
        var duration: String {
            if isCardioDay {
                return "\(vigorousDuration)-\(moderateDuration) min"
            } else if isStrengthDay {
                return "30 min"
            } else {
                return ""
            }
        }
        
        // Determine card content
        if isCardioDay {
            return (
                "menuCardio",
                "Today's Cardio Menu!",
                "Don't worry about being perfect! just move and let your body wake up!",
                duration
            )
        } else if isStrengthDay {
            return (
                "menuStrength",
                "Today's Strength Menu!",
                "Let's wake up those muscles just good vibes and sweat!",
                duration
            )
        } else {
            return (
                "menuRest",
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
//            ZStack {
//                // Abu-abu full kiri-kanan
//                Color.gray.opacity(0.15)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 180)
//                    .clipShape(Rectangle())
                
                // Gambar di tengah
            Image(cardInfo.image)
                .frame(maxWidth: .infinity)
//                                    .frame(height: 180)
//            }
            
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
                    PrimaryGlassButton(title: "Start Workout", action: {
                        HapticManager.shared.trigger(.buttonTap)
                        onStartWorkout()
                    })
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

// MARK: - Day Selector (Final Fixed Version)
struct DaySelectorView: View {
    @Binding var selectedDayIndex: Int
    let userCycle: UserCycle?
    
    private let weekDays = ["M", "T", "W", "T", "F", "S", "S"]
    //private let todayIndex = Calendar.current.component(.weekday, from: Date()) - 1 // 0-based
    private let calendar = Calendar.current
    
    private var weekDates: [Date] {
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysToMonday = weekday == 1 ? -6 : -(weekday - 2)
        
        guard let monday = calendar.date(byAdding: .day, value: daysToMonday, to: today) else {
            return []
        }
        
        return (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: monday)
        }
    }
        
    private var todayIndex: Int {
        let weekday = calendar.component(.weekday, from: Date())
        return weekday == 1 ? 6 : weekday - 2
    }
        
    private func dayNumber(for index: Int) -> Int {
        guard index < weekDates.count else { return index + 1 }
        return calendar.component(.day, from: weekDates[index])
    }
        // Get phase for a specific index
    private func phaseForIndex(_ index: Int) -> MenstrualPhase? {
        guard let cycle = userCycle, index < weekDates.count else { return nil }
        
        let date = weekDates[index]
        let startOfDate = calendar.startOfDay(for: date)
        let startOfLastPeriod = calendar.startOfDay(for: cycle.cycleStartDate)
        
        let daysSinceStart = calendar.dateComponents([.day], from: startOfLastPeriod, to: startOfDate).day ?? 0
        let currentDayInCycle = (daysSinceStart % cycle.cycleLength) + 1
        
        return CyclePhaseCalculator.phaseForDay(
            currentDayInCycle,
            cycleLength: cycle.cycleLength,
            periodDuration: cycle.menstrualDuration
        )
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<7) { index in
                let isPastDay = index < todayIndex
                let isToday = index == todayIndex
                let isSelected = selectedDayIndex == index
                
                VStack(spacing: 6) {
                    // Label hari
                    Text(weekDays[index])
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.black)
                    
                    // Tombol hari
                    Button {
                        guard !isPastDay else { return }
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedDayIndex = index
                        }
                    } label: {
                        ZStack {
                            // Warna background
                            Circle()
                                .fill(
                                    isPastDay
                                        ? Color.gray.opacity(0.3) // abu
                                        : (
                                            isSelected
                                            ? Color("pinkTextPrimary") // pink tua kalau dipilih
                                            : (
                                                isToday
                                                ? Color("pinkTextTertiary") // pink muda kalau hari ini tapi tdk dipilih
                                                : Color("pinkTextTertiary") // pink muda default
                                            )
                                        )
                                )
                                .frame(width: 44, height: 44)
                            
                            // Angka
                            Text("\(dayNumber(for: index))")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(
                                    isPastDay
                                        ? .gray.opacity(0.6)
                                        : (isSelected ? .white : .black.opacity(0.8))
                                )
                        }
                    }
                    .disabled(isPastDay)
                }
                .opacity(isPastDay ? 0.6 : 1)
            }
        }
        .padding(.horizontal)
        .onAppear {
            selectedDayIndex = todayIndex // default pilih hari ini
        }
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
    }
}

// MARK: - Streak Card
struct StreakCardView: View {
    @State private var progressAnim: CGFloat = 0
    let currentStreak: Int = 7
    let targetStreak: Int = 20
    
    var progress: CGFloat {
        return CGFloat(currentStreak) / CGFloat(targetStreak)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Character on the Left
            Image("charStreak")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            // Card on the Right
            VStack(spacing: 8) {
                // Streak Counter
                HStack(spacing: 4) {
                    Text("\(currentStreak) / \(targetStreak)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color("pinkTextPrimary"))
                    
                    Spacer()
                }
                
                Text("Day Streak")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.15))
                            .frame(width: geometry.size.width, height: 20)
                        
                        // Progress Fill with Fire Icon
                        ZStack(alignment: .trailing) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [Color("pinkTextPrimary"), Color("pinkTextPrimary").opacity(0.85)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(20, progressAnim * geometry.size.width), height: 20)
                            
                            // Fire Icon at the end
                            if progressAnim > 0 {
                                Image("fireStreakRed")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 26, height: 26)
                                    .offset(x: 8)
                            }
                        }
                        .frame(width: max(20, progressAnim * geometry.size.width), height: 20, alignment: .leading)
                    }
                }
                .frame(height: 20)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
            )
        }
        .padding(.horizontal, 20)
        .onAppear {
            // Animate progress bar with smooth easing
            withAnimation(.easeOut(duration: 1.2)) {
                progressAnim = progress
            }
        }
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

