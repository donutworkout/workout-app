import SwiftUI

struct WorkoutDayView: View {
    @EnvironmentObject var surveyManager: SurveyManager
    
    var onNext: () -> Void
    
    @State private var selectedDays: [String] = []
    @State private var showCustomAlert = false
    
    let days = WorkoutDayPreference.allCases.map { $0.displayName }
    
    var workoutLevel: WorkoutLevel { surveyManager.tempWorkoutLevel }
    
    var minimumDays: Int {
        if workoutLevel == WorkoutLevel.beginner {
            return 2
        } else if workoutLevel == WorkoutLevel.intermediate {
            return 4
        } else if workoutLevel == WorkoutLevel.advanced {
            return 5
        }
        return 2 // Default value for unexpected cases
    }
    
    private func saveAndNext() {
        let preferences: [WorkoutDayPreference] = selectedDays.compactMap { WorkoutDayPreference(rawValue: $0) }
        surveyManager.updateTempWorkoutDaysPreference(preferences)
        
        surveyManager.finalizeUserWorkout()
        onNext()
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                
                // MARK: - Title
                VStack(spacing: 16) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            SurveyProgressText(currentPage: 5, totalPages: 6)
                            Text("Which days do you usually have time to work out?")
                                .font(.system(.title, weight: .semibold))
                                .foregroundColor(Color("pinkTextPrimary"))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .layoutPriority(1)
                        }
                        Spacer()
                        Image("characterSurvey")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                            .minimumScaleFactor(0.5)
                            .layoutPriority(0)
                    }
                }
                .padding(.horizontal)
                
                // MARK: - Days Grid
                VStack(spacing: 12) {
                    let gridItems = [GridItem(.flexible()), GridItem(.flexible())]
                    LazyVGrid(columns: gridItems, spacing: 12) {
                        ForEach(days, id: \.self) { day in
                            SelectableButton(
                                title: day,
                                isSelected: selectedDays.contains(day)
                            ) {
                                handleSelection(for: day)
                            }
                            .frame(maxWidth: 160)
                        }
                    }
                }
                .padding(16)
                .glassEffect(in: .rect(cornerRadius: 25.0))
                .padding(.horizontal)
                
                // MARK: - Note
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                    Text("Pick at least \(String(minimumDays)) days to stay active each week")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.top, -4)
                
                Spacer()
                
                // MARK: - Next Button
                PrimaryGlassButton(title: "Next") {
                    if selectedDays.contains("Flexible") {
                        saveAndNext()
                    } else if selectedDays.count < minimumDays {
                        showCustomAlert = true
                    } else {
                        saveAndNext()
                    }
                }
                .padding(.horizontal)
                .padding(.vertical)
                .opacity(isButtonEnabled ? 1 : 0.5)
            }
            .animation(.easeInOut, value: selectedDays)
            .background(Color.white.ignoresSafeArea())
            
            // MARK: - Custom Alert (HIG Style + Glass Button)
            if showCustomAlert {
                Color.white.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) { showCustomAlert = false }
                    }
                
                VStack(spacing: 20) {
                    Text("Too chill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text("Pick at least \(String(minimumDays)) days so we can get that streak going!")
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 15))
                        .foregroundColor(.black.opacity(0.8))
                        .padding(.horizontal)
                    
                    PrimaryGlassButton(title: "OK") {
                        withAnimation(.spring()) {
                            showCustomAlert = false
                        }
                    }
                    .frame(height: 54)
                    .padding(.horizontal)
                }
                .padding(.vertical, 24)
                .frame(maxWidth: 300)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 26))
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Logic
    private func handleSelection(for day: String) {
        if day == "Flexible" {
            if selectedDays.contains("Flexible") {
                selectedDays.removeAll { $0 == "Flexible" }
            } else {
                selectedDays = ["Flexible"]
            }
        } else {
            if selectedDays.contains("Flexible") {
                selectedDays.removeAll { $0 == "Flexible" }
            }
            if selectedDays.contains(day) {
                selectedDays.removeAll { $0 == day }
            } else {
                selectedDays.append(day)
            }
        }
    }
    
    private var isButtonEnabled: Bool {
        !selectedDays.isEmpty
    }
}

#Preview {
    WorkoutDayView(onNext: {})
}
