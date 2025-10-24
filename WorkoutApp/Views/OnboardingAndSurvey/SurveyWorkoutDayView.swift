import SwiftUI

struct WorkoutDayView: View {
    var onNext: () -> Void
    @State private var selectedDays: [String] = []
    @State private var showCustomAlert = false
    
    let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday", "Flexible"]
    
    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                // MARK: - Header
                Text("Survey")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.top, 8)
                
                // MARK: - Title
                VStack(spacing: 16) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            SurveyProgressText(currentPage: 5, totalPages: 6)
                            Text("Which days do you usually have time to work out?")
                                .font(.system(.title, weight: .semibold))
                                .foregroundColor(Color("pinkTextPrimary"))
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
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
                
                // MARK: - Days
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
                    Text("Pick at least two days to stay active each week")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.top, -4)
                
                Spacer()
                
                // MARK: - Next Button
                PrimaryGlassButton(title: "Next") {
                    if selectedDays.contains("Flexible") {
                        onNext()
                    } else if selectedDays.count < 2 {
                        showCustomAlert = true
                    } else {
                        onNext()
                    }
                }
                .padding(.horizontal)
                .padding(.vertical)
                .opacity(isButtonEnabled ? 1 : 0.5)
                

            }
            .animation(.easeInOut, value: selectedDays)
            .background(Color.white.ignoresSafeArea())
            
            // MARK: - Custom Alert Overlay
            if showCustomAlert {
                Color.white.opacity(0.5)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation { showCustomAlert = false }
                    }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Too chill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    
                    Text("Pick at least 2 days so we can get that streak going!")
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 15))
                        .foregroundColor(.black.opacity(0.8))
                        .padding(.horizontal)
                    
                    Button {
                        withAnimation { showCustomAlert = false }
                    } label: {
                        Text("Okay")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color("pinkTextPrimary"))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 24)
                .frame(maxWidth: 280)
                .background(.ultraThinMaterial)
                .cornerRadius(28)
                .shadow(radius: 10)
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
