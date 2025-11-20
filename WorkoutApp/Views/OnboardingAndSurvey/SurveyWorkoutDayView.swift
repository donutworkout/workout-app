import SwiftUI

struct WorkoutDayView: View {
    @EnvironmentObject var surveyManager: SurveyManager
    
    var onNext: () -> Void
    
    @State private var selectedDays: [String] = []
    @State private var showCustomAlert = false
    @State private var move = false
    
    let days = WorkoutDayPreference.allCases.map { $0.displayName }
    
    var workoutLevel: WorkoutLevel { surveyManager.tempWorkoutLevel }
    
    var minimumDays: Int {
        if workoutLevel == WorkoutLevel.beginner {
            return 3
        } else if workoutLevel == WorkoutLevel.intermediate {
            return 4
        } else if workoutLevel == WorkoutLevel.advanced {
            return 5
        }
        return 3 // Default value for unexpected cases
    }
    
    private func saveAndNext() {
        let preferences: [WorkoutDayPreference] = selectedDays.compactMap { dayName in
            WorkoutDayPreference.allCases.first { $0.displayName == dayName }
        }
        surveyManager.updateTempWorkoutDaysPreference(preferences)
        
        surveyManager.finalizeUserWorkout()
        onNext()
    }
    
    var body: some View {
        ZStack {
            // MARK: - Main Content
            VStack(spacing: 32) {
                
                // MARK: - Title
                VStack(spacing: 16) {
                    HStack(alignment: .bottom, spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            SurveyProgressText(currentPage: 4, totalPages: 5)
                            Text("When do you have time to work out?")
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
                            .frame(width: 120)
                            .minimumScaleFactor(0.5)
                            .layoutPriority(0)
                            .offset(x: move ? 9 : -54)
                    }
                }
                .padding(.horizontal)
//                .padding(.top, 10)
                
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
                .padding(.leading, -16)
                
                Spacer()
                
                // MARK: - Next Button
                PrimaryGlassButton(title: "Next") {
                    if selectedDays.contains("Flexible") {
                        saveAndNext()
                    } else if selectedDays.count < minimumDays {
                        withAnimation(.spring()) {
                            showCustomAlert = true
                        }
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
            .blur(radius: showCustomAlert ? 3 : 0) // ✅ Blur background saat alert muncul
            .allowsHitTesting(!showCustomAlert) // ✅ Disable interaction saat alert muncul
            .onAppear {
                withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                    move = true
                }
            }
            .onAppear {
                if selectedDays.isEmpty {
                    let savedDays = surveyManager.tempWorkoutDaysPreference
                    
                    if !savedDays.isEmpty {
                        selectedDays = savedDays.map { $0.displayName }
                        print("✅ Loaded existing workout days: \(selectedDays)")
                    }
                }
            }
            
            // MARK: - Custom Alert Overlay (FULL COVER)
            if showCustomAlert {
                ZStack {
                    // ✅ Full screen overlay
                    Color.white.opacity(0.5)
                        .ignoresSafeArea(.all) // ✅ Cover everything including safe areas
                        .onTapGesture {
                            withAnimation(.spring()) {
                                showCustomAlert = false
                            }
                        }
                    
                    // ✅ Alert Dialog
                    VStack(spacing: 0) {
                        // MARK: - Content Area
                        VStack(spacing: 12) {
                            // Title
                            Text("Too Chill")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            // Message
                            Text("Pick at least \(minimumDays) days so we can get that streak going!")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        
                        Divider()
                        
                        // MARK: - Button
                        Button(action: {
                            withAnimation(.spring()) {
                                showCustomAlert = false
                            }
                        }) {
                            Text("OK")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color("pinkTextPrimary"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .contentShape(Rectangle())
                        }
                    }
                    .frame(width: 270)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                }
                .transition(.opacity.combined(with: .scale(scale: 1.1)))
                .zIndex(999) // ✅ Ensure it's on top
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
