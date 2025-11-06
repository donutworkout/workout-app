import SwiftUI

struct MenuView: View {
    @EnvironmentObject var router: Router
    @State private var selectedDay: Int = Calendar.current.component(.weekday, from: Date()) - 1
    
    private var currentPhase: PhaseType {
        switch selectedDay {
        case 0, 2, 4, 6: return .menstrual
        default: return .follicular
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Menu")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                DaySelectorView(selectedDay: $selectedDay)
                
                // Combined Phase + Workout Card
                CombinedWorkoutCardView(phase: currentPhase, onStartWorkout: {
                    if currentPhase == .menstrual {
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
                
                StreakCardView(phase: currentPhase)
                    .padding(.bottom, 100)
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

struct CombinedWorkoutCardView: View {
    let phase: PhaseType
    var onStartWorkout: () -> Void
    
    private var cardInfo: (image: String, workoutTitle: String, phaseDesc: String) {
        switch phase {
        case .menstrual:
            return ("buttercup", "Today's Cardio Menu!", "Take it slow today 🌙 It's okay to rest or move gently.")
        case .follicular:
            return ("bubbles", "Today's Strength Menu!", "You're glowing, girl! Perfect time to try new moves or push a little more.")
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

// MARK: - Streak Card
struct StreakCardView: View {
    let phase: PhaseType
    
    private var streakInfo: (title: String, desc: String) {
        switch phase {
        case .menstrual:
            return ("You're on a roll!", "Another checkmark for the consistency queen!")
        case .follicular:
            return ("Go Girl!", "Don't break it, bestie! You're killing it!")
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Text("🔥")
                .font(.system(size: 48))
            
            VStack(alignment: .leading, spacing: 6) {
                Text(streakInfo.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                Text(streakInfo.desc)
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
