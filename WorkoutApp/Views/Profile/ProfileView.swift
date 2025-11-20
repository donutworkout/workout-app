//
//  ProfileView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 20/10/25.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @EnvironmentObject var router: Router
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \UserProfile.createdAt, order: .reverse)
    private var profiles: [UserProfile]
    
    @State private var path: [String] = []
    
    // Current user profile
    private var currentProfile: UserProfile? {
        profiles.first
    }
    
    // Computed properties for display
    private var userName: String {
        currentProfile?.name ?? "User"
    }
    
    // ✅ Calculate current cycle day using CyclePhaseCalculator
    private var currentCycleDay: Int {
        guard let cycle = currentProfile?.userCycle?.first else { return 1 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startOfLastPeriod = calendar.startOfDay(for: cycle.cycleStartDate)
        
        let daysSinceStart = calendar.dateComponents([.day], from: startOfLastPeriod, to: today).day ?? 0
        return (daysSinceStart % cycle.cycleLength) + 1
    }
    
    // ✅ Get current phase using CyclePhaseCalculator
    private var currentPhase: MenstrualPhase {
        guard let cycle = currentProfile?.userCycle?.first else {
            return .menstruation
        }
        
        return CyclePhaseCalculator.calculateCurrentPhase(
            lastPeriodStart: cycle.cycleStartDate,
            cycleLength: cycle.cycleLength,
            menstrualDuration: cycle.menstrualDuration
        )
    }
    
    // ✅ Get phase display name
    private var cyclePhaseText: String {
        switch currentPhase {
        case .menstruation:
            return "Menstrual Phase"
        case .follicular:
            return "Follicular Phase"
        case .ovulation:
            return "Ovulation Phase"
        case .luteal:
            return "Luteal Phase"
        }
    }
    
    // ✅ Predict next period using CyclePhaseCalculator
    private var nextPeriodDate: String {
        guard let cycle = currentProfile?.userCycle?.first else {
            return "Not available"
        }
        
        if let nextPeriod = CyclePhaseCalculator.predictNextPeriod(
            lastPeriodStart: cycle.cycleStartDate,
            cycleLength: cycle.cycleLength
        ) {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM yyyy"
            return formatter.string(from: nextPeriod)
        }
        
        return "Not available"
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Header
                    Text("Profile")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 32)
                    
                    // MARK: - Profile Info
                    HStack(alignment: .center, spacing: 12) {
                        Image("profile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                        
                        Text(userName)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    
                    // MARK: - Personalize Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PERSONALIZE")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.leading, 4)
                        
                        VStack(spacing: 0) {
                            NavigationLink {
                                EditBodyInfoView()
                            } label: {
                                ProfileRow(icon: "figure.arms.open", title: "Body Measurement")
                            }
                            
                            NavigationLink {
                                EditWorkoutLevelView()
                            } label: {
                                ProfileRow(icon: "face.smiling", title: "Change Level")
                            }

                            NavigationLink {
                                EditProfileView()
                            } label: {
                                ProfileRow(icon: "person.crop.circle", title: "About Me")
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                        )
                    }
                    
                    // MARK: - Menstrual Cycle Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MENSTRUAL CYCLE")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.leading, 4)
                        
                        NavigationLink {
                            MenstrualCycleView()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("You're on Day \(currentCycleDay) - \(cyclePhaseText)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                    Text("Next period predicted: \(nextPeriodDate)")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                            )
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
            
            // MARK: - Navigation destinations
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "editBodyInfo":
                    EditBodyInfoView()
                case "editWorkoutLevel":
                    EditWorkoutLevelView()
                case "editProfile":
                    EditProfileView()
                case "menstrualCycle":
                    MenstrualCycleView()
                default:
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(Router())
        .modelContainer(for: [UserProfile.self, UserWorkout.self, UserCycle.self])
}
