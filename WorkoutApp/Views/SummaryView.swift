//
//  SummaryView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 20/10/25.
//

import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var router: Router
    @State private var selectedDay: Int = Calendar.current.component(.weekday, from: Date()) - 1
    let weekDays = ["M", "T", "W", "T", "F", "S", "S"]
    let progress: [Double] = [1.0, 0.9, 0.3, 0.6, 0.2, 0.4, 0.7]
    
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
                DaySelectorSummaryView(selectedDay: $selectedDay, weekDays: weekDays, progress: progress)
                    .padding(.horizontal, 20)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : -20)
                
                // MARK: - Character with Progress Fill
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

                // MARK: - Stats Card
                VStack(spacing: 12) {
                    HStack {
                        summaryItem(title: "Workout Time", value: "0:15:18")
                        Divider()
                        summaryItem(title: "Active Calories", value: "100 kcal")
                    }
                    Divider()
                    HStack {
                        summaryItem(title: "Total Kilocalories", value: "130 kcal")
                        Divider()
                        summaryItem(title: "Avg. Heart Rate", value: "118 bpm")
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
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            startEntranceAnimation()
        }
        .onChange(of: router.selectedTab) { oldValue, newValue in
            if newValue == 1 {
                showContent = false
                characterScale = 0.5
                characterOpacity = 0
                
                withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
                    showContent = true
                    characterScale = 1.0
                    characterOpacity = 1.0
                }
            }
        }

    }
    
    // MARK: - Entrance Animation Sequence
    private func startEntranceAnimation() {
        // Step 1: Show title and day selector (0.3s delay)
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            showContent = true
        }
        
        // Step 2: Character pop in with bounce (0.5s delay)
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
    var weekDays: [String]
    var progress: [Double]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<weekDays.count, id: \.self) { index in
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
                            Text("\(index + 1)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SummaryView()
}
