import SwiftUI
import SwiftData
import HealthKit

struct MenuView: View {
    @EnvironmentObject var router: Router
    @Environment(\.modelContext) private var modelContext
    
    @Query private var menus: [DailyMenu]
    @Query private var userCycles: [UserCycle]
    @Query private var userProfiles: [UserProfile]
    @Query private var userWorkouts: [UserWorkout]
    
    @StateObject var cycleViewModel: CycleViewModel
    @StateObject var menuViewModel: MenuViewModel
    
    @State private var cardioSpecs: CardioDetails?
    @State private var vigorousDuration: Int = 0
    @State private var moderateDuration: Int = 0
    
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
                    .animateHeader(forTab: 0, currentTab: $router.selectedTab, delay: 0.1)
                
                // MARK: - Day Selector
                DaySelectorView(
                    selectedDayIndex: $cycleViewModel.selectedDayIndex,
                    userCycle: userCycle)
                .animateHeader(forTab: 0, currentTab: $router.selectedTab, delay: 0.2)
                
                // MARK: - Workout Card
                CombinedWorkoutCardView(
                    phase: selectedPhase,
                    menu: selectedDayMenu,
                    vigorousDuration: vigorousDuration,
                    moderateDuration: moderateDuration,
                    workoutLevel: userWorkout?.workoutLevel ?? .beginner,
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
                .animateCard(forTab: 0, currentTab: $router.selectedTab, delay: 0.3)
                
                // MARK: - Streak Section
                VStack(spacing: 8) {
                    StreakCardView()
                }
                .animateCard(forTab: 0, currentTab: $router.selectedTab, delay: 0.4)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            if let cycle = userCycle {
                cycleViewModel.updateCycle(cycle)
                print("USERCYCLE ON MENUVIEW UPDATED")
            }
            
            cycleViewModel.selectedDayIndex = todayIndex()
            
            if router.isEditingFromProfile == true {
                loadWeeklyMenu(forceCheckProfile: true)
                router.isEditingFromProfile = false
            } else {
                loadWeeklyMenu(forceCheckProfile: false)
            }
                
            calculateCardioSpecs()
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
        
        let cardioDays = menus.filter {
            if case .cardio = $0.category { return true }
            return false
        }.count
        
        if let specs = cardioSpecs, cardioDays > 0 {
            vigorousDuration = specs.vigorousDuration / cardioDays
            moderateDuration = specs.moderateDuration / cardioDays
        }
    }
    
}

struct CombinedWorkoutCardView: View {
    @State private var showHealthNotConnectedModal = false
    @State private var isHealthConnected = false
    @State private var isWatchConnected = false
    @EnvironmentObject var router: Router
    
    let phase: MenstrualPhase
    let menu: DailyMenu?
    let vigorousDuration: Int
    let moderateDuration: Int
    let workoutLevel: WorkoutLevel
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
        
        let imageName: String
        let title: String
        let description: String
        
        switch (isCardioDay, isStrengthDay) {
        case (true, _):
            imageName = "menuCardio"
            title = "Today's Cardio Day!"
            
            switch phase {
            case .menstruation:
                switch workoutLevel {
                case .beginner:
                    description = "Soft steps today, lovely 💗 Your body’s in recharge mode, so we’ll keep things light with gentle cardio to loosen up without stress."
                case .intermediate:
                    description = "Your inner world’s doing its work 🌙 Let’s move slow and steady with low-impact cardio that supports your flow, not fights it."
                case .advanced:
                    description = "You’re powerful even in softness 💪✨ This phase calls for ease, so think light, rhythmic cardio to refresh your body without overloading it."
                }
            case .follicular:
                switch workoutLevel {
                case .beginner:
                    description = "Your spark is returning 🌞 Let’s ease into fun beginner cardio with light, bouncy movements to wake your energy gently."
                case .intermediate:
                    description = "Hello boost phase ⚡ Your stamina’s rising, so we’ll build momentum with steady, feel-good cardio sessions."
                case .advanced:
                    description = "Time to fire up 🔥 Your energy’s climbing fast, so dynamic intervals and playful intensity will feel amazing right now."
                }
            case .ovulation:
                switch workoutLevel {
                case .beginner:
                    description = "You’re glowing today 🌷 Let’s channel that brightness with short, energetic cardio bursts that are joyful, not overwhelming."
                case .intermediate:
                    description = "Peak energy mode ✨ Time for fun, empowering cardio that lets you feel your confidence in motion."
                case .advanced:
                    description = "This is your go-time 🔥 High-intensity cardio or power intervals fit your body’s natural high, let’s ride the momentum!"
                }
            case .luteal:
                switch workoutLevel {
                case .beginner:
                    description = "It’s okay to slow the pace 🌙 Gentle, steady cardio will keep you balanced while your body prepares for the next cycle."
                case .intermediate:
                    description = "Your energy may shift, and that’s normal 💕 We’ll go for mindful, moderate cardio that keeps you moving without draining you."
                case .advanced:
                    description = "Honor the rhythm 🌾 Mix strong days with softer cardio flows, staying consistent without burning out is your strength."
                }
            }
            
        case (_, true):
            imageName = "menuStrength"
            title = "Today's Strength Day!"
            
            switch phase {
            case .menstruation:
                switch workoutLevel {
                case .beginner:
                    description = "Hey gentle warrior 🫶 Let’s focus on mobility and soft strength today! Tiny movements that feel good, nothing heavy."
                case .intermediate:
                    description = "Your body’s asking for kindness 🌸 We’ll keep strength training low-intensity with controlled reps and restorative transitions."
                case .advanced:
                    description = "Strong doesn’t always mean pushing hard 🌙 Try slow, mindful strength drills and deep mobility, perfect for recovery and alignment."
                }
            case .follicular:
                switch workoutLevel {
                case .beginner:
                    description = "Fresh start vibes ✨ Simple strength moves will help you build confidence and reconnect with your body."
                case .intermediate:
                    description = "You’re ready to grow stronger 🌼 Let’s build stable foundations with moderate reps and progressive challenges."
                case .advanced:
                    description = "Your power’s coming alive 💥 Perfect moment for strength sets that push you!"
                }
            case .ovulation:
                switch workoutLevel {
                case .beginner:
                    description = "Feeling that spark? 🌸 Light, upbeat strength moves will help you enjoy the extra confidence this phase brings."
                case .intermediate:
                    description = "You’re at your strongest 💫 Let’s embrace it with empowering, medium-intensity strength flows."
                case .advanced:
                    description = "You’re unstoppable today 🔥 This is the perfect window for tougher strength sets with explosive reps, powerful sequences, full expression."
                }
            case .luteal:
                switch workoutLevel {
                case .beginner:
                    description = "Soft and steady wins here 🌼 Light strength work with longer rest will keep your body supported"
                case .intermediate:
                    description = "Consistency is your quiet power ✨ Controlled reps and balanced pacing will help you stay steady through this phase."
                case .advanced:
                    description = "Your strength is adaptable 🌺 Alternate challenges with restorative strength work, listen in and train with intention."
                }
            }
            
        default: // Rest day
            imageName = "menuRest"
            title = "Time to Rest"
            switch phase {
            case .menstruation:
                description = "Full permission to slow down—rest supports your body’s work today."
            case .follicular, .ovulation:
                description = "A pause so muscles can rebuild and your next sessions feel stronger."
            case .luteal:
                description = "Let your body reset, lower stress, and gently prepare for a new cycle."
            }
        }
        
        return (imageName, title, description, duration)
        
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
            
            // MARK: - Image
            Image(cardInfo.image)
                .resizable()
                .frame(maxWidth: .infinity)
                .clipped()
            
            // MARK: - Content Section
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
                
                // MARK: - Start Workout Button
                if (menu?.isCardio ?? false) || (menu?.isStrength ?? false) {
                    PrimaryGlassButton(title: "Start Workout") {
                        HapticManager.shared.trigger(.buttonTap)
                        
                       // ✅ Update status koneksi saat tombol diklik
                       updateConnectionStatus()
                       
                       // Cek apakah KEDUANYA sudah connect
                       if isHealthConnected && isWatchConnected {
                           // Langsung start workout
                           onStartWorkout()
                       } else {
                           // Tampilkan modal jika salah satu belum connect
                           showHealthNotConnectedModal = true
                       }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        // ✅ Sheet modal
        .sheet(isPresented: $showHealthNotConnectedModal) {
            HealthNotConnectedView(
                isHealthConnected: isHealthConnected,
                isWatchConnected: isWatchConnected
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
        .onAppear {
            // ✅ Update status saat view pertama kali muncul
            updateConnectionStatus()
        }
    }
    
    // ✅ Helper function untuk update status koneksi
    private func updateConnectionStatus() {
        isHealthConnected = iPhoneHealthKitManager.shared.isAuthorized()
        isWatchConnected = WatchConnectivityManager.shared.isReachable
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
                                        ? Color("pinkTextSecondary") // pink tua kalau dipilih
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
    @EnvironmentObject var router: Router  // ✅ Tambahkan ini
    @Environment(\.modelContext) private var modelContext
    
    @State private var progressAnim: CGFloat = 0
    @State private var currentStreak: Int = 0
    @State private var targetStreak: Int = 0
    @State private var hasStreakChanged: Bool = false
    
    @State private var lastCheckedDay: Date = Calendar.current.startOfDay(for: Date())
    private var today: Date { Calendar.current.startOfDay(for: Date()) }
    
    var progress: CGFloat {
        return CGFloat(currentStreak) / CGFloat(targetStreak)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            
            if hasStreakChanged {
                Image("charStreak")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.top, -13)
                    .padding(.leading, -21)
//                    .padding(.trailing, 5)
            } else {
                Image("charHalfwayDone")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125, height: 125)
            }
            
            // Card on the Right (bisa diklik)
//            Button {
//                router.navigateTo(.streak)  // ✅ Navigasi ke StreakView
//            } label: {
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
                        .frame(width: 230, height: 125, alignment: .trailing)
                )
//            }
//            .buttonStyle(PlainButtonStyle())  // ✅ Agar tidak ada efek highlight default
        }
        .padding(.horizontal, 20)
        .onAppear {
            // Animate progress bar with smooth easing
            withAnimation(.easeOut(duration: 1.2)) {
                progressAnim = progress
            }
            
            loadStreak()
            lastCheckedDay = today
        }
        .onChange(of: currentStreak) { oldValue, newValue in
            // ✅ Triggered when currentStreak changes
            if oldValue != newValue {
                hasStreakChanged = true
                print("🔥 Streak changed from \(oldValue) to \(newValue)")
            }
        }
        .onChange(of: today) { oldValue, newValue in
            if oldValue != newValue {
                hasStreakChanged = false
                lastCheckedDay = newValue
                print("⏰ New day detected. Reset hasStreakChanged.")
            }
        }
    }
    
    private func loadStreak() {
        let progress = StreakManager.shared.getMonthlyProgress(context: modelContext)
        currentStreak = progress.completed
        targetStreak = progress.goal
        print("Current home streak: \(currentStreak)")
    }
}

// MARK: - Enum
enum PhaseType: String {
    case menstrual = "Menstrual Phase"
    case follicular = "Follicular Phase"
}

extension MenuView {
    private func loadWeeklyMenu(forceCheckProfile: Bool = false) {
        guard let cycle = userCycle else { return }
        
        // ✅ Fetch fresh UserWorkout
        let workoutFetch = FetchDescriptor<UserWorkout>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        guard let freshWorkout = try? modelContext.fetch(workoutFetch).first else {
            print("❌ No UserWorkout found")
            return
        }
        
        let chosenDays: [WorkoutDayPreference] = freshWorkout.workoutDaysPreference
        print("✅ Chosen days: \(chosenDays.map { $0.rawValue })")
        
        // ✅ Use the new conditional method
        Task {
            await menuViewModel.generateWeeklyMenuIfNeeded(
                userCycle: cycle,
                userLevel: freshWorkout.workoutLevel,
                chosenDays: chosenDays,
                forceProfileCheck: forceCheckProfile
            )
        }
    }
}

//#Preview {
//    MenuView(modelContext: ModelContext)
//        .environmentObject(Router())
//}

