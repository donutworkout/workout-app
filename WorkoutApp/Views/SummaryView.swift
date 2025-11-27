//
//  SummaryView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 20/10/25.
//

import SwiftUI
import SwiftData

struct SummaryView: View {
    @EnvironmentObject var router: Router
    @Environment(\.modelContext) private var modelContext
    @Query private var dailyMenus: [DailyMenu]
        
    @StateObject private var summaryManager = WorkoutSummaryManager()
    @State private var selectedDay: Int = 0

    let weekDays = ["M", "T", "W", "T", "F", "S", "S"]
    
    var weekDates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let mondayOffset = weekday == 1 ? -6 : -(weekday - 2)
        let startOfWeek = calendar.date(byAdding: .day, value: mondayOffset, to: today)!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
  
    // Animation states
    @State private var showContent: Bool = false
    @State private var characterScale: CGFloat = 0.5
    @State private var characterOpacity: Double = 0
    @State private var showNoWorkoutText: Bool = false

    // Computed progress based on actual workout data
    var progress: [Double] {
        var progressArray: [Double] = []
        for dayIndex in 0..<7 {
            guard let summary = summaryManager.weeklySummaries[dayIndex] else {
                progressArray.append(0.0)
                continue
            }
            if summary.workoutCount > 0 {
                let minutes = summary.totalDuration / 60
                let progress = min(minutes / 30.0, 1.0)
                progressArray.append(progress)
            } else {
                progressArray.append(0.0)
            }
        }
        return progressArray
    }

    var currentDaySummary: DaySummary {
        summaryManager.weeklySummaries[selectedDay] ?? DaySummary()
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Title
                Text("Summary")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 32)
                    .padding(.horizontal, 20)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : -20)
                    .animateHeader(forTab: 1, currentTab: $router.selectedTab, delay: 0.1)
                
                // MARK: - Day Selector with Progress
                DaySelectorSummaryView(
                    selectedDay: $selectedDay,
                    weekDates: weekDates,
                    progress: progress,
                    weekDays: weekDays
                )
                .padding(.horizontal, 20)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : -20)
                .animateHeader(forTab: 1, currentTab: $router.selectedTab, delay: 0.2)
                
                // MARK: - Character with Progress Fill
                if summaryManager.isLoading {
                    ProgressView()
                        .frame(width: 300, height: 300)
                        .frame(maxWidth: .infinity)
                } else {
                    ProgressCharacterView(progress: progress.indices.contains(selectedDay) ? progress[selectedDay] : 0)
                        .frame(width: 300, height: 300)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .animateHeader(forTab: 1, currentTab: $router.selectedTab, delay: 0.3)
                }

                if let menu = dailyMenus.first(where: { Calendar.current.isDate($0.date, inSameDayAs: weekDates[selectedDay]) }) {
                    if menu.category == .rest {
                        Text("It's your rest day!")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                            .padding(.horizontal, 20)
                            .opacity(showNoWorkoutText ? 1 : 0)
                            .offset(y: showNoWorkoutText ? 0 : 10)
                            .animation(.easeOut(duration: 0.6).delay(0.4), value: showNoWorkoutText)
                    } else if currentDaySummary.workoutCount == 0 {
                        Text("No workout data yet.")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                            .padding(.horizontal, 20)
                            .opacity(showNoWorkoutText ? 1 : 0)
                            .offset(y: showNoWorkoutText ? 0 : 10)
                            .animation(.easeOut(duration: 0.6).delay(0.4), value: showNoWorkoutText)
                    } else {
                        VStack(spacing: 12) {
                            HStack {
                                summaryItem(title: "Workout Time", value: summaryManager.formatDuration(currentDaySummary.totalDuration))
                                Divider()
                                summaryItem(title: "Active Kilocalories", value: "\(Int(currentDaySummary.activeCalories)) kcal")
                            }
                            Divider()
                            HStack {
                                summaryItem(title: "Total Kilocalories", value: "\(Int(currentDaySummary.totalCalories)) kcal")
                                Divider()
                                summaryItem(title: "Avg. Heart Rate", value: currentDaySummary.avgHeartRate > 0 ? "\(Int(currentDaySummary.avgHeartRate)) bpm" : "-- bpm")
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal, 20)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animateHeader(forTab: 1, currentTab: $router.selectedTab, delay: 0.5)
                        
                        Spacer()
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .refreshable {
            await summaryManager.fetchWeeklySummary(dailyMenus: dailyMenus)
        }
        .background(Color.white.ignoresSafeArea())
        .task {
            startEntranceAnimation()
            summaryManager.setupService(modelContext: modelContext)
            await summaryManager.fetchWeeklySummary(dailyMenus: dailyMenus)
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())

            if let index = weekDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
                selectedDay = index
            }
            
            // Trigger animasi no workout text
            withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
                showNoWorkoutText = true
            }
        }
        .onChange(of: selectedDay) { _, _ in
            // Reset animasi saat ganti hari
            showNoWorkoutText = false
            withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
                showNoWorkoutText = true
            }
        }
    }

    // MARK: - Entrance Animation Sequence
    private func startEntranceAnimation() {
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            showContent = true
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5)) {
            characterScale = 1.0
            characterOpacity = 1.0
        }
    }

    // MARK: - Reusable Summary Item
    @ViewBuilder
    func summaryItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.body)
                .foregroundColor(.black)
            Text(value)
                .font(.title2)
                .foregroundColor(.black)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Progress Character View Component with Fill Animation
struct ProgressCharacterView: View {
    let progress: Double
    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            Image("charCongratsBnw")
                .resizable()
                .scaledToFit()

            Image("charCongrats")
                .resizable()
                .scaledToFit()
                .mask(
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: geometry.size.height * animatedProgress)
                            .offset(y: geometry.size.height * (1 - animatedProgress))
                    }
                )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).delay(0.8)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeInOut(duration: 0.6)) {
                animatedProgress = newValue
            }
        }
    }
}

struct DaySelectorSummaryView: View {
    @Binding var selectedDay: Int
    var weekDates: [Date]
    var progress: [Double]
    let weekDays: [String]
    
    // ✅ Detect hari ini
    private var todayIndex: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Cari index dari weekDates yang match dengan hari ini
        if let index = weekDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
            return index
        }
        return -1 // Jika tidak ditemukan
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<7, id: \.self) { index in
                let isToday = index == todayIndex  // ✅ Check apakah hari ini
                
                VStack(spacing: 6) {
                    Text(weekDays[index])
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.black)

                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedDay = index
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color("pinkTextTertiary").opacity(0.25))
                                .frame(width: 44, height: 44)

                            Circle()
                                .fill(Color("pinkTextSecondary"))
                                .frame(width: 44, height: 44)
                                .mask(
                                    Rectangle()
                                        .frame(height: 44 * (progress.indices.contains(index) ? progress[index] : 0))
                                        .offset(y: 44 * (1 - (progress.indices.contains(index) ? progress[index] : 0)))
                                )
                                .clipShape(Circle())

                            if selectedDay == index {
                                Circle()
                                    .stroke(
                                        isToday
                                        ? Color("pinkTextPrimary")  // Pink untuk hari ini
                                        : Color("grayTextPrimary"),  // Abu untuk bukan hari ini
                                        lineWidth: 3
                                    )
                                    .frame(width: 46, height: 46)
                            }

                            Text(formattedDate(weekDates[index]))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                }
            }
        }
    }

    func formattedDate(_ date: Date) -> String {
        let day = Calendar.current.component(.day, from: date)
        return "\(day)"
    }
}

#Preview {
    SummaryView()
        .modelContainer(for: DailyMenu.self, inMemory: true)
}
