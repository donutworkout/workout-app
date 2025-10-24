import SwiftUI

struct SurveyCycleView: View {
    var onFinish: () -> Void
    
    // MARK: - States
    @State private var selectedMenstrualCycle: [String] = []
    @State private var selectedPhysicalSymptoms: [String] = []
    @State private var selectedEnergyLevel: [String] = []
    @State private var selectedMoodChanges: [String] = []
    @State private var selectedDates: Set<Date> = []
    @State private var currentMonth = Date()
    @State private var isFirstClick = true
    
    private let calendar = Calendar.current
    
    // MARK: - Options
    let menstrualCycle = ["Yes", "No"]
    let physicalSymptoms = ["Cramps", "Back Pain", "Fatigue / Low Energy", "Mood Swing", "None of the above"]
    let energyLevel = ["I feel more energetic after my period", "Drops before/during period", "Stay stable"]
    let moodChanges = ["Often", "Sometime", "Never"]
    
    // MARK: - Computed property
    var isAllAnswered: Bool {
        !selectedMenstrualCycle.isEmpty &&
        !selectedPhysicalSymptoms.isEmpty &&
        !selectedEnergyLevel.isEmpty &&
        !selectedMoodChanges.isEmpty &&
        !selectedDates.isEmpty
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 32) {
                    
                    // MARK: - Header
//                    Text("Survey")
//                        .font(.headline)
//                        .foregroundColor(.black)
//                        .padding(.top, 20)
                    
                    // MARK: - Title & Character
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            SurveyProgressText(currentPage: 6, totalPages: 6)
                            Text("Menstrual \nCycle")
                                .font(.system(.title, weight: .semibold))
                                .foregroundColor(Color("pinkTextPrimary"))
                        }
                        Spacer()
                        Image("characterSurvey")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // MARK: - Question Sections
                    Group {
                        // 1. Regularity Question
                        SurveySection(
                            title: "Is your menstrual cycle regular?",
                            subtitle: "The variation of cycle length is less than 7 days",
                            options: menstrualCycle,
                            selectedOptions: $selectedMenstrualCycle,
                            allowsMultipleSelection: false
                        )
                        
                        // 2. Period Start Date - Custom Calendar
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("When did your period start?")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.black)
                                Text("Tap to select your period dates")
                                    .font(.body)
                                    .foregroundColor(Color.black)
                            }
                            .padding(.horizontal)
                            
                            // Custom Calendar View
                            VStack(spacing: 16) {
                                // Month Navigation
                                HStack {
                                    Button(action: {
                                        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
                                            currentMonth = newMonth
                                        }
                                    }) {
                                        Image(systemName: "chevron.left")
                                            .foregroundColor(Color("pinkTextPrimary"))
                                    }
                                    
                                    Spacer()
                                    
                                    Text(monthYearString)
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
                                            currentMonth = newMonth
                                        }
                                    }) {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(Color("pinkTextPrimary"))
                                    }
                                }
                                .padding(.horizontal)
                                
                                // Days of Week
                                HStack(spacing: 0) {
                                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                                        Text(day)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.gray)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.horizontal)
                                
                                // Calendar Grid
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 8) {
                                    ForEach(0..<daysInMonth.count, id: \.self) { index in
                                        if let date = daysInMonth[index] {
                                            CalendarDayButton(
                                                date: date,
                                                isSelected: isDateSelected(date),
                                                onTap: {
                                                    toggleDate(date)
                                                }
                                            )
                                        } else {
                                            Color.clear
                                                .frame(height: 40)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .padding(.horizontal)
                        }
                        
                        // 3. Physical Symptoms
                        SurveySection(
                            title: "What you feel when menstrual?",
                            subtitle: "Physical symptoms before or during",
                            options: physicalSymptoms,
                            selectedOptions: $selectedPhysicalSymptoms,
                            allowsMultipleSelection: true
                        )
                        
                        // 4. Energy Levels
                        SurveySection(
                            title: "How do your energy levels?",
                            subtitle: "Energy pattern during cycle",
                            options: energyLevel,
                            selectedOptions: $selectedEnergyLevel,
                            allowsMultipleSelection: false
                        )
                        
                        // 5. Mood Changes
                        SurveySection(
                            title: "Do mood changes affect workouts?",
                            subtitle: "It affects your motivation to exercise",
                            options: moodChanges,
                            selectedOptions: $selectedMoodChanges,
                            allowsMultipleSelection: false
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 100)
            }
            
            // MARK: - Finish Button
            PrimaryGlassButton(title: "Finish", action: onFinish)
                .padding(.horizontal)
                .padding(.vertical)
                .disabled(!isAllAnswered)
                .opacity(isAllAnswered ? 1 : 0.5)
            

        }
        .background(Color.white.ignoresSafeArea())
    }
    
    // MARK: - Helper Functions
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
    
    private func isDateSelected(_ date: Date) -> Bool {
        selectedDates.contains { calendar.isDate($0, inSameDayAs: date) }
    }
    
    private func toggleDate(_ date: Date) {
        if let existingDate = selectedDates.first(where: { calendar.isDate($0, inSameDayAs: date) }) {
            // Unselect - delete this date
            selectedDates.remove(existingDate)
        } else {
            // Select this date
            selectedDates.insert(date)
            
            // Auto-select 5 days only on first click
            if isFirstClick {
                for i in 1...4 {
                    if let nextDay = calendar.date(byAdding: .day, value: i, to: date) {
                        selectedDates.insert(nextDay)
                    }
                }
                isFirstClick = false
            }
        }
    }
}

// MARK: - Calendar Day Button
struct CalendarDayButton: View {
    let date: Date
    let isSelected: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var dayNumber: String {
        let day = calendar.component(.day, from: date)
        return "\(day)"
    }
    
    var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color("pinkTextPrimary"))
                        .frame(width: 40, height: 40)
                } else if isToday {
                    Circle()
                        .stroke(Color("pinkTextPrimary"), lineWidth: 1.5)
                        .frame(width: 40, height: 40)
                }
                
                Text(dayNumber)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : (isToday ? Color("pinkTextPrimary") : .black))
            }
            .frame(height: 40)
        }
    }
}

#Preview {
    SurveyCycleView(onFinish: {})
}
