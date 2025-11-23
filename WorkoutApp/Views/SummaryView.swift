//
//  SummaryView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 20/10/25.
//

import SwiftUI
import SwiftData

struct SummaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dailyMenus: [DailyMenu]
        
    @StateObject private var summaryManager = WorkoutSummaryManager()
    @State private var selectedDay: Int = Calendar.current.component(.weekday, from: Date()) - 1

    let weekDays = ["M", "T", "W", "T", "F", "S", "S"]
    //let progress: [Double] = [1.0, 0.9, 0.3, 0.6, 0.2, 0.4, 0.7]
    
    var weekDates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let mondayOffset = weekday == 1 ? -6 : -(weekday - 2)
        
        let startOfWeek = calendar.date(byAdding: .day, value: mondayOffset, to: today)!

        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startOfWeek)
        }
    }

    
    // Animation states
        @State private var showContent: Bool = false
        @State private var characterScale: CGFloat = 0.5
        @State private var characterOpacity: Double = 0
        
        // Computed progress based on actual workout data
        var progress: [Double] {
            var progressArray: [Double] = []
            for dayIndex in 0..<7 {
                guard let summary = summaryManager.weeklySummaries[dayIndex] else {
                    progressArray.append(0.0)
                    continue
                }
                
                // Calculate progress based on workout completion
                // If there's a workout, show progress based on duration
                // 30+ minutes = 100%, scale down from there
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
    
    // Animation states
    @State private var showContent: Bool = false
    @State private var characterScale: CGFloat = 0.5
    @State private var characterOpacity: Double = 0
    
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
                
                // MARK: - Character (Static)
                
//                VStack {
//                    Image("charLogin")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 300, height: 300)
//                        .padding(.vertical, 8)
//                }
//                .frame(maxWidth: .infinity)

                // MARK: - Character with Progress Fill
                if summaryManager.isLoading {
                    ProgressView()
                        .frame(width: 300, height: 300)
                        .frame(maxWidth: .infinity)
                } else {
                    ProgressCharacterView(progress: progress[selectedDay])
                        .frame(width: 300, height: 300)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .scaleEffect(characterScale)
                        .opacity(characterOpacity)
                        .rotation3DEffect(
                            .degrees(showContent ? 0 : 15),
                            axis: (x: 0, y: 1, z: 0)
                        )
                }
                
                // MARK: - Stats Card
                VStack(spacing: 12) {
                    HStack {
                        summaryItem(title: "Workout Time", value: summaryManager.formatDuration(currentDaySummary.totalDuration))
                        Divider()
                        summaryItem(title: "Active Calories", value: "\(Int(currentDaySummary.activeCalories)) kcal")
                    }
                    Divider()
                    HStack {
                        summaryItem(title: "Total Kilocalories", value: "\(Int(currentDaySummary.totalCalories)) kcal")
                        Divider()
                        summaryItem(title: "Avg. Heart Rate", value: currentDaySummary.avgHeartRate > 0
                                    ? "\(Int(currentDaySummary.avgHeartRate)) bpm"
                                    : "-- bpm")
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
                
                Spacer()
            }
            .padding(.bottom, 40)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
        }
        .refreshable {
            await summaryManager.fetchWeeklySummary(dailyMenus: dailyMenus)
        }
        .background(Color.white.ignoresSafeArea())
        .task {
            startEntranceAnimation()
            await summaryManager.fetchWeeklySummary(dailyMenus: dailyMenus)
        }
        .onChange(of: selectedDay) { _, _ in
            // Could refresh if needed
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
            // Base layer: Black & White character (always visible)
            Image("charCongratsBnw")
                .resizable()
                .scaledToFit()
            
            // Top layer: Colored character with animated mask (fills from bottom)
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
            // Fill animation when character first appears
            withAnimation(.easeInOut(duration: 1.2).delay(0.8)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            // Smooth fill when switching days
            withAnimation(.easeInOut(duration: 0.6)) {
                animatedProgress = newValue
            }
        }
    }
}

//
//  DaySelectorSummaryView.swift
//  WorkoutApp
//

import SwiftUI

struct DaySelectorSummaryView: View {
    @Binding var selectedDay: Int
        var weekDates: [Date]
        var progress: [Double]
        let weekDays: [String]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<7, id: \.self) { index in
                VStack(spacing: 6) {
                    // Day label (M, T, W...) di atas
                    Text(weekDays[index])
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.black)
                    
                    // Lingkaran dengan progress dan angka
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedDay = index
                        }
                    } label: {
                        ZStack {
                            // Base circle (abu/pink lembut)
                            Circle()
                                .fill(Color("pinkTextTertiary").opacity(0.25))
                                .frame(width: 44, height: 44)
                            
                            // Progress fill naik dari bawah
                            Circle()
                                .fill(Color("pinkTextPrimary"))
                                .frame(width: 44, height: 44)
                                .mask(
                                    Rectangle()
                                        .frame(height: 44 * progress[index])
                                        .offset(y: 44 * (1 - progress[index]))
                                )
                                .clipShape(Circle())
                            
                            // Border kalau hari ini terpilih
                            if selectedDay == index {
                                Circle()
                                    .stroke(Color("pinkTextPrimary"), lineWidth: 3)
                                    .frame(width: 46, height: 46)
                            }
                            
                            // Angka hari (1–7)
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

#Preview {
    SummaryView()
}
