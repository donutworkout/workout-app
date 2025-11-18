//
//  MenstrualCycleView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 22/10/25.
//

import SwiftUI
import SwiftData

struct MenstrualCycleView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \UserProfile.createdAt, order: .reverse)
    private var profiles: [UserProfile]
    
    private var currentProfile: UserProfile? {
        profiles.first
    }
    
    private var cycle: UserCycle? {
        currentProfile?.userCycle?.first
    }
    
    @State private var isEditing: Bool = false
    @State private var tempMenstrualDates: Set<Date> = []
    @State private var menstrualDates: Set<Date> = []
    @State private var ovulationDates: Set<Date> = []
    @State private var currentMonth: Date = Date()
    @State private var isFirstClick: Bool = true
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderButton(
                title: "Menstrual Cycle",
                isEditing: isEditing,
                onClose: {
                    dismiss()
                },
                onEditToggle: {
                    withAnimation(.spring()) {
                        if isEditing {
                            // SAVE CHANGES
                            menstrualDates = tempMenstrualDates
                            saveCycleDates()
                            calculateOvulationDates()
                            isEditing = false
                        } else {
                            // ENTER EDIT MODE
                            tempMenstrualDates = menstrualDates
                            isEditing = true
                            isFirstClick = true
                        }
                    }
                }
            )
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // MARK: - Single Month Calendar
                    VStack(spacing: 16) {
                        // Month header with navigation
                        HStack {
                            Text(monthYearString)
                                .font(.system(size: 22, weight: .semibold))
                            
                            Spacer()
                            
                            HStack(spacing: 20) {
                                Button {
                                    if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
                                        currentMonth = newMonth
                                    }
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color("pinkTextPrimary"))
                                }
                                
                                Button {
                                    if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
                                        currentMonth = newMonth
                                    }
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color("pinkTextPrimary"))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        // Days of week
                        HStack(spacing: 0) {
                            ForEach(["SUN","MON","TUE","WED","THU","FRI","SAT"], id: \.self) { day in
                                Text(day)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Calendar grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                            ForEach(0..<daysInMonth.count, id: \.self) { index in
                                if let date = daysInMonth[index] {
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
                                    .aspectRatio(1, contentMode: .fit)
                                } else {
                                    Color.clear
                                        .frame(maxWidth: .infinity)
                                        .aspectRatio(1, contentMode: .fit)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .frame(height: 7 * 44 + 6 * 8)
                        .padding(.bottom, 16)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.1), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal, 16)
                    
                    // MARK: - Legend or Info
                    if isEditing {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Tap any date to edit your period")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.black)
                                
                                Text("Ovulation days are fixed and can't be adjusted")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .gray.opacity(0.1), radius: 6, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                    } else {
                        HStack(spacing: 24) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color("pinkTextPrimary").opacity(0.3))
                                    .frame(width: 20, height: 20)
                                Text("Menstruation")
                                    .font(.system(size: 15))
                                    .foregroundColor(.black)
                            }
                            
                            HStack(spacing: 8) {
                                Circle()
                                    .stroke(Color.blue, lineWidth: 2)
                                    .frame(width: 20, height: 20)
                                Text("Ovulation")
                                    .font(.system(size: 15))
                                    .foregroundColor(.black)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.top, 16)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadCycleDates()
        }
    }
    
    // MARK: - Calendar helpers
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
        
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
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
        return ovulationDates.contains { calendar.isDate($0, inSameDayAs: date) }
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
    
    // MARK: - Backend Functions
    
    private func loadCycleDates() {
        guard let cycle = cycle else {
            print("⚠️ No cycle data found")
            return
        }
        
        // Load menstrual dates from cycle
        let daysBetween = calendar.dateComponents([.day], from: cycle.cycleStartDate, to: cycle.cycleEndDate).day ?? 0
        
        for i in 0...daysBetween {
            if let date = calendar.date(byAdding: .day, value: i, to: cycle.cycleStartDate) {
                menstrualDates.insert(date)
            }
        }
        
        calculateOvulationDates()
        print("✅ Cycle dates loaded: \(menstrualDates.count) days")
    }
    
    private func saveCycleDates() {
        guard let cycle = cycle else {
            print("❌ Cannot save: No cycle found")
            return
        }
        
        let sortedDates = menstrualDates.sorted()
        
        if let firstDate = sortedDates.first,
           let lastDate = sortedDates.last {
            cycle.cycleStartDate = firstDate
            cycle.cycleEndDate = lastDate
            cycle.menstrualDuration = menstrualDates.count
            
            do {
                try modelContext.save()
                print("✅ Cycle dates saved successfully")
            } catch {
                print("❌ Error saving cycle: \(error.localizedDescription)")
            }
        }
    }
    
    private func calculateOvulationDates() {
        ovulationDates.removeAll()
        guard !menstrualDates.isEmpty else { return }
        let lastMenstrualDate = menstrualDates.sorted().last!
        if let ovulationStart = calendar.date(byAdding: .day, value: 7, to: lastMenstrualDate) {
            for i in 0..<14 {
                if let ovulationDay = calendar.date(byAdding: .day, value: i, to: ovulationStart) {
                    ovulationDates.insert(ovulationDay)
                }
            }
        }
    }
}

struct DayCell: View {
    let date: Date
    let isMenstrual: Bool
    let isOvulation: Bool
    let isToday: Bool
    let isEditing: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var dayNumber: String {
        let day = calendar.component(.day, from: date)
        return "\(day)"
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                if isMenstrual {
                    Circle()
                        .fill(Color("pinkTextPrimary").opacity(0.3))
                }
                
                if isToday && !isMenstrual {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                }
                
                if isOvulation && !isMenstrual {
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                }
                
                Text(dayNumber)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor((isToday && !isMenstrual) ? .blue : .black)
                
                if isEditing {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                    
                    if isMenstrual {
                        Circle()
                            .fill(Color("pinkTextPrimary"))
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(6)
            .contentShape(Rectangle())
        }
        .frame(width: 44, height: 44)
    }
}

#Preview {
    NavigationStack {
        MenstrualCycleView()
            .modelContainer(for: [UserProfile.self, UserWorkout.self, UserCycle.self])
    }
}
