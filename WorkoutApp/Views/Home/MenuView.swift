import SwiftUI
import SwiftData

struct MenuView: View {
    @EnvironmentObject var router: Router
    
    @Query private var userCycles: [UserCycle]
    
    @StateObject var cycleViewModel: CycleViewModel
    @State private var selectedDay: Int = Calendar.current.component(.weekday, from: Date()) - 1
    
    private var userCycle: UserCycle? {
        userCycles.first
    }
    
    init() {
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
    }
    
    private var currentPhase: MenstrualPhase {
        cycleViewModel.phase(for: cycleViewModel.selectedDayIndex) ?? .menstruation
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Menu")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                DaySelectorView(selectedDay: $cycleViewModel.selectedDayIndex)
                WorkoutCardView(phase: currentPhase, onStartWorkout: {
                    if currentPhase == .menstruation {
                        router.navigateTo(.adjustMenuCardio)
                    } else {
                        router.navigateTo(.adjustMenuStrength)
                    }
                })
                
                Text("Streak")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                StreakCardView()
                    //.padding(.bottom, 100)
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

// Update WorkoutCardView agar bisa terima callback
struct CombinedWorkoutCardView: View {
    let phase: MenstrualPhase

    var onStartWorkout: () -> Void
    
    private var cardInfo: (image: String, workoutTitle: String, phaseDesc: String) {
        switch phase {
        case .menstruation:
            return ("buttercup", "Today's Cardio Menu!", "Don’t worry about being perfect! just move and let your body wake up!")
        case .follicular:
            return ("bubbles", "Today's Strength Menu!", "Let's wake up those muscles just good vibes and sweat!")
        case .luteal:
            return ("bubbles", "Today's Strength Menu!", "Let's wake up those muscles just good vibes and sweat!")
        case .ovulation:
            return ("bubbles", "Today's Strength Menu!", "Let's wake up those muscles just good vibes and sweat!")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // MARK: - Phase Header
            Text(phase.rawValue)
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
                        
                        // Capsule waktu (posisi stabil)
                        Text("30 min")
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
                    
                    Text(cardInfo.phaseDesc)
                        .font(.system(size: 14))
                        .foregroundColor(.black.opacity(0.7))
                        .lineSpacing(3)
                }
                
                // Tombol
                PrimaryGlassButton(title: "Start Workout", action: onStartWorkout)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal)
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
        .padding(.horizontal)
    }
}

// MARK: - Enum
enum PhaseType: String {
    case menstrual = "Menstrual Phase"
    case follicular = "Follicular Phase"
}

#Preview {
    MenuView()
        .environmentObject(Router())
}
