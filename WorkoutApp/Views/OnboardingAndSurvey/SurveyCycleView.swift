import SwiftUI

struct SurveyCycleView: View {
    @EnvironmentObject var surveyManager: SurveyManager
    
    var onFinish: () -> Void
    
    // MARK: - States
    @State private var selectedMenstrualCycle: [String] = []
    @State private var selectedPhysicalSymptoms: [String] = []
    @State private var selectedEnergyLevel: [String] = []
    @State private var selectedMoodChanges: [String] = []
    @State private var selectedDates: Set<Date> = []
    @State private var currentMonth = Date()
    @State private var isFirstClick = true
    @State private var move = false
    
    private let noneOption = "None of the above"
    private let calendar = Calendar.current
    
    // MARK: - Options
    let menstrualCycle = ["Yes", "No"]
    let physicalSymptoms = CycleSymptoms.allCases.map { $0.displayName }
    let energyLevel = CycleEnergy.allCases.map { $0.displayName }
    let moodChanges = CycleMoodAffectsMotivation.allCases.map { $0.displayName }
    
    private func symptomFromDisplayName(_ name: String) -> CycleSymptoms? {
        CycleSymptoms.allCases.first { $0.displayName == name }
    }
    
    private func energyFromDisplayName(_ name: String) -> CycleEnergy? {
        CycleEnergy.allCases.first { $0.displayName == name }
    }
    
    private func moodFromDisplayName(_ name: String) -> CycleMoodAffectsMotivation? {
        CycleMoodAffectsMotivation.allCases.first { $0.displayName == name }
    }
    
    // MARK: - Computed property untuk Validasi
    var isAllAnswered: Bool {
        !selectedMenstrualCycle.isEmpty &&
        !selectedPhysicalSymptoms.isEmpty &&
        !selectedEnergyLevel.isEmpty &&
        !selectedMoodChanges.isEmpty &&
        !selectedDates.isEmpty &&
        selectedEnergyLevel.first != "Not selected" &&
        selectedMoodChanges.first != "Not selected"
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 32) {
                    
                    // MARK: - Title & Character
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 8) {
                            SurveyProgressText(currentPage: 5, totalPages: 5)
                            Text("Menstrual \nCycle")
                                .font(.system(.title, weight: .semibold))
                                .foregroundColor(Color("pinkTextPrimary"))
                        }
                        Spacer()
                        Image("characterSurvey")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)
                            .offset(x: move ? 9 : -54)
                    }
                    .padding(.horizontal)
//                    .padding(.top, 10)
                    
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
                                                isFutureDate: isFutureDate(date),
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
                            selectedOptions: Binding(
                                get: { selectedPhysicalSymptoms },
                                set: { newValue in
                                    let none = "None of the above"

                                    // CASE 1 → user memilih None sekarang
                                    if newValue.contains(none) && !selectedPhysicalSymptoms.contains(none) {
                                        selectedPhysicalSymptoms = [none]
                                        return
                                    }

                                    // CASE 2 → user sebelumnya pilih None, lalu klik opsi lain
                                    if selectedPhysicalSymptoms.contains(none) && !newValue.contains(none) {
                                        // remove none, allow the new selection
                                        selectedPhysicalSymptoms = newValue.filter { $0 != none }
                                        return
                                    }

                                    // CASE 3 → normal multi-select behavior (tanpa None)
                                    selectedPhysicalSymptoms = newValue.filter { $0 != none }
                                }
                            ),
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
            PrimaryGlassButton(title: "Finish", action: saveAndFinish)
                .padding(.horizontal)
                .padding(.vertical)
                .disabled(!isAllAnswered) // Disable jika belum semua section terisi
                .opacity(isAllAnswered ? 1 : 0.5)
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                move = true
            }
        }
        .onAppear {
            loadExistingSelections()
        }
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
    
    // Check if date is in the future
    private func isFutureDate(_ date: Date) -> Bool {
        let today = calendar.startOfDay(for: Date())
        let checkDate = calendar.startOfDay(for: date)
        return checkDate > today
    }
    
    private func toggleDate(_ date: Date) {
        // Prevent selecting future dates
        if isFutureDate(date) {
            return
        }
        
        if let existingDate = selectedDates.first(where: { calendar.isDate($0, inSameDayAs: date) }) {
            // Unselect - delete this date
            selectedDates.remove(existingDate)
        } else {
            // Select this date
            selectedDates.insert(date)
            
            // Auto-select 5 days only on first click
            if isFirstClick {
                for i in 1...4 {
                    if let nextDay = calendar.date(byAdding: .day, value: i, to: date),
                       !isFutureDate(nextDay) {
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
    let isFutureDate: Bool
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
                    .foregroundColor(
                        isFutureDate ? .gray.opacity(0.3) :
                        (isSelected ? .white : (isToday ? Color("pinkTextPrimary") : .black))
                    )
            }
            .frame(height: 40)
        }
        .disabled(isFutureDate)
    }
}

extension SurveyCycleView {
    
    private func loadExistingSelections() {
        // 1. Load menstrual cycle regularity HANYA jika ada nilai valid
        if selectedMenstrualCycle.isEmpty {
            if let isRegular = surveyManager.tempIsCycleRegular {
                selectedMenstrualCycle = [isRegular ? "Yes" : "No"]
            }
        }
        
        // 2. Load dates (only if they're not the default Date())
        if selectedDates.isEmpty && surveyManager.tempCycleLength > 0 {
            let startDate = surveyManager.tempCycleStartDate
            let endDate = surveyManager.tempCycleEndDate
            
            // Calculate days between start and end
            let daysBetween = calendar.dateComponents([.day],
                                                      from: startDate,
                                                      to: endDate).day ?? 0
            
            // Add all dates in the range
            for i in 0...daysBetween {
                if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                    selectedDates.insert(date)
                }
            }
            
            // Set current month to the start date's month
            if !selectedDates.isEmpty {
                currentMonth = startDate
            }
        }
        
        // 3. Load symptoms (enum -> String conversion) HANYA jika ada
        if selectedPhysicalSymptoms.isEmpty {
            let symptoms = surveyManager.tempCycleSymptoms.map { $0.displayName }
            if !symptoms.isEmpty {
                selectedPhysicalSymptoms = symptoms
            }
        }
        
        // 4. Load energy level HANYA jika ada nilai valid
        if selectedEnergyLevel.isEmpty {
            if let energy = surveyManager.tempCycleEnergy {
                selectedEnergyLevel = [energy.displayName]
            }
        }
        
        // 5. Load mood HANYA jika ada nilai valid
        if selectedMoodChanges.isEmpty {
            if let mood = surveyManager.tempCycleMoodAffectsMotivation {
                selectedMoodChanges = [mood.displayName]
            }
        }
    }
    
    private func saveAndFinish() {
        // 1. Save regularity
        if let regularityString = selectedMenstrualCycle.first {
            let isRegular = regularityString == "Yes"
            surveyManager.updateTempIsCycleRegular(isRegular)
            print("✅ Cycle regularity saved: \(isRegular)")
        }
        
        // 2. Save dates (start and end)
        if let firstPeriodDate = selectedDates.sorted().first {
            surveyManager.updateTempCycleStartDate(firstPeriodDate)
            print("✅ Start date saved: \(firstPeriodDate)")
        }
        
        if let lastPeriodDate = selectedDates.sorted().last {
            surveyManager.updateTempCycleEndDate(lastPeriodDate)
            print("✅ End date saved: \(lastPeriodDate)")
        }
        
        // Calculate cycle length
        let menstrualDuration = selectedDates.count
        surveyManager.updateTempMenstrualDuration(menstrualDuration)
        print("✅ Cycle length saved: \(menstrualDuration) days")
        
        
        if surveyManager.tempCycleLength == 0 {
            surveyManager.updateTempCycleLength(28) // Default cycle length
            print("✅ Cycle length set to default: 28 days")
        } else {
            print("✅ Using existing cycle length: \(surveyManager.tempCycleLength) days")
        }
        
        // 3. Save symptoms (handle multiple selections if needed)
        let selectedSymptoms: [CycleSymptoms] = selectedPhysicalSymptoms.compactMap { name in
            symptomFromDisplayName(name)
        }
        surveyManager.updateTempCycleSymptoms(selectedSymptoms)
        print("✅ Symptoms saved: \(selectedSymptoms.map { $0.displayName }.joined(separator: ", "))")
        
        // 4. Save energy level
        if let energyString = selectedEnergyLevel.first,
           let energy = energyFromDisplayName(energyString) {
            surveyManager.updateTempCycleEnergy(energy)
            print("✅ Energy level saved: \(energy.rawValue) - Display: \(energy.displayName)")
        }
        
        // 5. Save mood affects motivation
        if let moodString = selectedMoodChanges.first,
           let mood = moodFromDisplayName(moodString) {
            surveyManager.updateTempCycleMoodAffectsMotivation(mood)
            print("✅ Mood affects motivation saved: \(mood.rawValue) - Display: \(mood.displayName)")
        }
        
        // Finalize cycle data
        surveyManager.finalizeUserCycle()
        surveyManager.verifyLatestData()
        
        onFinish()
    }
}

#Preview {
    SurveyCycleView(onFinish: {})
}
