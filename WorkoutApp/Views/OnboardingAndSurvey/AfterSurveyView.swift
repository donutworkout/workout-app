//
//  AfterSurveyView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 17/11/25.
//

import SwiftUI
import SwiftData

struct AfterSurveyView: View {
    @EnvironmentObject var router: Router
    @Environment(\.modelContext) private var modelContext
    @State private var bgBreath = false
    @State private var charBounce = false
    
    @Query(sort: \UserProfile.createdAt, order: .reverse)
    private var profiles: [UserProfile]
    
    // Computed properties untuk data dari survey
    private var userName: String {
        profiles.first?.name ?? "User"
    }
    
    private var phaseText: String {
        guard let userCycle = profiles.first?.userCycle?.first else {
            return "Menstrual Phase"
        }
        return getCurrentCyclePhase(from: userCycle)
    }
    
    private var levelText: String {
        guard let workoutLevel = profiles.first?.userWorkouts?.first?.workoutLevel else {
            return "Beginner"
        }
        return workoutLevel.displayName
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundPink()
                    .scaleEffect(bgBreath ? 1.09 : 1)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                            bgBreath = true
                        }
                    }

                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // MARK: - Character
                    CharLogin()
                        .frame(height: 300)
                        .offset(y: charBounce ? -12 : 0)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                charBounce = true
                            }
                        }
                    
                    // MARK: - Title Section
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text("Hey, \(userName)!")
                            .font(.largeTitle.bold())
                            .foregroundColor(Color("pinkTextPrimary"))
                        
                        (
                            Text("You're in your ")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                            +
                            Text(phaseText)
                                .foregroundColor(Color("pinkTextPrimary"))
                                .fontWeight(.bold)
                            +
                            Text(", you're starting at the ")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                            +
                            Text(levelText)
                                .foregroundColor(Color("pinkTextPrimary"))
                                .fontWeight(.bold)
                            +
                            Text(" Level. We'll guide you to consistency and confidence!")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                        )
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding(.trailing, 12)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // MARK: - Button
                    PrimaryGlassButton(title: "Okay") {
                        router.navigateTo(.menu)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
                .padding()
                .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    /// Menghitung fase siklus berdasarkan tanggal
    private func getCurrentCyclePhase(from cycle: UserCycle) -> String {
        let today = Date()
        let calendar = Calendar.current
        
        // Hitung hari ke berapa dalam siklus
        let daysSinceStart = calendar.dateComponents([.day], from: cycle.cycleStartDate, to: today).day ?? 0
        let currentDay = daysSinceStart % cycle.cycleLength
        
        // Tentukan fase berdasarkan hari
        switch currentDay {
        case 0..<cycle.menstrualDuration:
            return "Menstrual Phase"
        case cycle.menstrualDuration..<14:
            return "Follicular Phase"
        case 14..<16:
            return "Ovulation Phase"
        default:
            return "Luteal Phase"
        }
    }
}

#Preview {
    AfterSurveyView()
        .environmentObject(Router())
        .modelContainer(for: [UserProfile.self, UserWorkout.self, UserCycle.self])
}
