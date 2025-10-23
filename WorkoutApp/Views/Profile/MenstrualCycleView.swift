//
//  MenstrualCycleView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 22/10/25.
//

import SwiftUI

struct MenstrualCycleView: View {
    @State private var isEditing: Bool = false
    @State private var tempMenstrualDates: Set<Date> = []
    @State private var menstrualDates: Set<Date> = []
    @State private var ovulationDates: Set<Date> = []
    @State private var currentMonth: Date = Date()
    @State private var isFirstClick: Bool = true
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Use HeaderButton
            HeaderButton(
                title: "Menstrual Cycle",
                isEditing: isEditing,
                onClose: {
                    print("Closed MenstrualCycleView")
                },
                onEditToggle: {
                    withAnimation(.spring()) {
                        if isEditing {
                            // Save
                            menstrualDates = tempMenstrualDates
                            calculateOvulationDates()
                            isEditing = false
                            isFirstClick = true
                        } else {
                            // Edit
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
                                Button(action: {
                                    withAnimation {
                                        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
                                            currentMonth = newMonth
                                        }
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color("pinkTextPrimary"))
                                }
                                
                                Button(action: {
                                    withAnimation {
                                        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
                                            currentMonth = newMonth
                                        }
                                    }
                                }) {
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
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 6) {
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
                                } else {
                                    Color.clear
                                        .frame(height: 48)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
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
                        // Info box saat editing
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
                        // Legend saat tidak editing
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
        .onAppear {
            initializeDates()
        }
    }
    
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
        
        // Add empty days for alignment (Sunday = 1)
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add days of the month
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
            // Unselect this date
            tempMenstrualDates.remove(existingDate)
        } else {
            // Select this date
            tempMenstrualDates.insert(date)
            
            // Only auto-select 5 days on first click
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
    
    private func initializeDates() {
        // Initialize with some default menstrual dates
        if let date1 = createDate(year: 2025, month: 4, day: 1),
           let date2 = createDate(year: 2025, month: 4, day: 2),
           let date3 = createDate(year: 2025, month: 4, day: 3),
           let date4 = createDate(year: 2025, month: 4, day: 4),
           let date5 = createDate(year: 2025, month: 4, day: 5),
           let date6 = createDate(year: 2025, month: 4, day: 6) {
            menstrualDates = [date1, date2, date3, date4, date5, date6]
        }
        
        calculateOvulationDates()
    }
    
    private func createDate(year: Int, month: Int, day: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return calendar.date(from: components)
    }
    
    private func calculateOvulationDates() {
        ovulationDates.removeAll()
        
        guard !menstrualDates.isEmpty else { return }
        
        // Find the last menstrual date
        let lastMenstrualDate = menstrualDates.sorted().last!
        
        // Ovulation starts 7 days after the last menstrual date
        if let ovulationStart = calendar.date(byAdding: .day, value: 7, to: lastMenstrualDate) {
            // Add 14 days of ovulation
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
                // Background Circle for Menstrual days
                if isMenstrual {
                    Circle()
                        .fill(Color("pinkTextPrimary").opacity(0.3))
                        .frame(width: 44, height: 44)
                }
                
                // Today background (only when not menstrual)
                if isToday && !isMenstrual {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 44, height: 44)
                }
                
                // Ovulation Circle
                if isOvulation && !isMenstrual {
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                        .frame(width: 44, height: 44)
                }
                
                // Day Number
                Text(dayNumber)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor((isToday && !isMenstrual) ? .blue : .black)
                
                // Edit Mode Overlay
                if isEditing {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 44, height: 44)
                    
                    if isMenstrual {
                        Circle()
                            .fill(Color("pinkTextPrimary"))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(height: 48)
        }
        .disabled(!isEditing)
    }
}

#Preview {
    MenstrualCycleView()
}
