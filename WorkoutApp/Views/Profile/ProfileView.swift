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
    
    // User & cycle data
    private var currentProfile: UserProfile? { profiles.first }
    private var userName: String { currentProfile?.name ?? "User" }
    private var cycle: UserCycle? { currentProfile?.userCycle?.first }
    
    private var currentCycleDay: Int {
        guard let cycle = cycle else { return 1 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startOfLastPeriod = calendar.startOfDay(for: cycle.cycleStartDate)
        let daysSinceStart = calendar.dateComponents([.day], from: startOfLastPeriod, to: today).day ?? 0
        return (daysSinceStart % cycle.cycleLength) + 1
    }
    
    private var currentPhase: MenstrualPhase {
        guard let cycle = cycle else { return .menstruation }
        return CyclePhaseCalculator.calculateCurrentPhase(
            lastPeriodStart: cycle.cycleStartDate,
            cycleLength: cycle.cycleLength,
            menstrualDuration: cycle.menstrualDuration
        )
    }
    
    private var cyclePhaseText: String {
        switch currentPhase {
        case .menstruation: return "Menstrual phase"
        case .follicular:   return "Follicular phase"
        case .ovulation:    return "Ovulation phase"
        case .luteal:       return "Luteal phase"
        }
    }
    
    private var nextPeriodDate: String {
        guard let cycle = cycle else { return "Not available" }
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

    // Calendar state
    @State private var isEditing: Bool = false
    @State private var tempMenstrualDates: Set<Date> = []
    @State private var menstrualDates: Set<Date> = []
    @State private var ovulationDates: Set<Date> = []
    @State private var currentMonth: Date = Date()
    @State private var isFirstClick: Bool = true
    private let calendar = Calendar.current

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // MARK: - Header
                Text("Profile")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 32)
                    .padding(.horizontal, 20)
                    .animateHeader(forTab: 2, currentTab: $router.selectedTab, delay: 0.1)
                
                // MARK: - User Profile Card
                Button {
                    router.navigateTo(.aboutMe)
                } label: {
                    HStack(spacing: 14) {
                        Image("profile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                        
                        Text(userName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                }
                .padding(.horizontal, 20)
                .animateHeader(forTab: 2, currentTab: $router.selectedTab, delay: 0.2)

                
                // MARK: - Main Cycle Card
                VStack(spacing: 0) {
                    // Info banner
                    VStack(alignment: .leading, spacing: 3) {
                        Text("You're on Day \(currentCycleDay) - \(cyclePhaseText)")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("Next period predicted: \(nextPeriodDate)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
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
                    
                    Image("menuCardio")
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .clipped()
                    
                    // MARK: - Calendar Section
                    VStack(spacing: 12) {
                        // Month navigation
                        HStack {
                            Text(monthYearString)
                                .font(.system(size: 18, weight: .semibold))
                            
                            Spacer()
                            
                            HStack(spacing: 16) {
                                Button {
                                    if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
                                        currentMonth = newMonth
                                    }
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color("pinkTextPrimary"))
                                }
                                
                                Button {
                                    if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
                                        currentMonth = newMonth
                                    }
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color("pinkTextPrimary"))
                                }
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 12)
                        
                        // Days of week
                        HStack(spacing: 0) {
                            ForEach(["SUN","MON","TUE","WED","THU","FRI","SAT"], id: \.self) { day in
                                Text(day)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 18)
                        
                        // Calendar grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                            ForEach(0..<42, id: \.self) { index in
                                if index < daysInMonth.count, let date = daysInMonth[index] {
                                    DayCell(
                                        date: date,
                                        isMenstrual: isMenstrualDate(date),
                                        isOvulation: isOvulationDate(date),
                                        isToday: calendar.isDateInToday(date),
                                        isEditing: isEditing,
                                        onTap: {
                                            toggleMenstrualDate(date)
                                        }
                                    )
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 36)
                                } else {
                                    Color.clear.frame(height: 36)
                                }
                            }
                        }
                        .frame(height: 252)
                        .padding(.horizontal, 18)
                        .padding(.bottom, 10)
                        
                        // Legend
                        HStack(spacing: 18) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color("pinkTextPrimary").opacity(0.3))
                                    .frame(width: 14, height: 14)
                                Text("Menstruation")
                                    .font(.system(size: 12))
                                    .foregroundColor(.black)
                            }
                            
                            HStack(spacing: 6) {
                                Circle()
                                    .stroke(Color.blue, lineWidth: 2)
                                    .frame(width: 14, height: 14)
                                Text("Follicular")
                                    .font(.system(size: 12))
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 6)
                        
                        // Edit Button
                        PrimaryGlassButton(title: isEditing ? "Save Changes" : "Edit Calendar") {
                            withAnimation(.spring()) {
                                if isEditing {
                                    menstrualDates = tempMenstrualDates
                                    saveCycleDates()
                                    calculateOvulationDates()
                                    isEditing = false
                                } else {
                                    tempMenstrualDates = menstrualDates
                                    isEditing = true
                                    isFirstClick = true
                                }
                            }
                        }
                        .frame(height: 50)
                        .padding(.horizontal, 18)
                        .padding(.bottom, 16)
                    }
                }
                .background(Color.white)
                .cornerRadius(17)
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .animateHeader(forTab: 2, currentTab: $router.selectedTab, delay: 0.3)

            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            loadCycleDates()
        }
    }

    // MARK: - Calendar Logic
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var daysInMonth: [Date?] {
        var days: [Date?] = []
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday else {
            return days
        }
        for _ in 1..<firstWeekday { days.append(nil) }
        var currentDate = monthInterval.start
        while currentDate < monthInterval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return days
    }
    
    private func isMenstrualDate(_ date: Date) -> Bool {
        let datesToCheck = isEditing ? tempMenstrualDates : menstrualDates
        return datesToCheck.contains { calendar.isDate($0, inSameDayAs: date) }
    }
    
    private func isOvulationDate(_ date: Date) -> Bool {
        ovulationDates.contains { calendar.isDate($0, inSameDayAs: date) }
    }
    
    private func toggleMenstrualDate(_ date: Date) {
        if !isEditing { return }
        if let existingDate = tempMenstrualDates.first(where: { calendar.isDate($0, inSameDayAs: date) }) {
            tempMenstrualDates.remove(existingDate)
        } else {
            tempMenstrualDates.insert(date)
            if isFirstClick {
                for i in 1...4 {
                    if let nextDay = calendar.date(byAdding: .day, value: i, to: date) {
                        tempMenstrualDates.insert(nextDay)
                    }
                }
                isFirstClick = false
            }
        }
    }
    
    private func loadCycleDates() {
        guard let cycle = cycle else { return }
        let daysBetween = calendar.dateComponents([.day], from: cycle.cycleStartDate, to: cycle.cycleEndDate).day ?? 0
        for i in 0...daysBetween {
            if let date = calendar.date(byAdding: .day, value: i, to: cycle.cycleStartDate) {
                menstrualDates.insert(date)
            }
        }
        calculateOvulationDates()
    }
    
    private func saveCycleDates() {
        guard let cycle = cycle else { return }
        let sortedDates = menstrualDates.sorted()
        if let firstDate = sortedDates.first, let lastDate = sortedDates.last {
            cycle.cycleStartDate = firstDate
            cycle.cycleEndDate = lastDate
            cycle.menstrualDuration = menstrualDates.count
            do {
                try modelContext.save()
            } catch {
                print("❌ Error saving cycle: \(error.localizedDescription)")
            }
        }
    }
    
    private func calculateOvulationDates() {
        ovulationDates.removeAll()
        guard !menstrualDates.isEmpty else { return }
        let firstMenstrualDate = menstrualDates.sorted().first!
        if let ovulationStart = calendar.date(byAdding: .day, value: 5, to: firstMenstrualDate) {
            for i in 0..<6 {
                if let ovulationDay = calendar.date(byAdding: .day, value: i, to: ovulationStart) {
                    ovulationDates.insert(ovulationDay)
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
