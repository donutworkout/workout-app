//
//  StreakView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 23/11/25.
//

import SwiftUI

struct StreakView: View {
    @EnvironmentObject var router: Router
    
    // Streak data
    let currentStreak: Int = 7
    let targetStreak: Int = 20
    
    var progress: CGFloat {
        return CGFloat(currentStreak) / CGFloat(targetStreak)
    }
    
    // Animation states
    @State private var characterScale: CGFloat = 0.5
    @State private var characterOpacity: Double = 0
    @State private var characterRotation: Double = -15
    
    @State private var cardScale: CGFloat = 0.7
    @State private var cardOpacity: Double = 0
    @State private var cardRotation: Double = 20
    
    @State private var progressAnim: CGFloat = 0
    
    @State private var bubbleStates: [Bool] = [false, false, false, false]
    @State private var characterSmallOpacity: Double = 0
    @State private var linesOpacity: Double = 0
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                // MARK: - Character (dengan animasi heboh)
                Image("charStreak")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 240)
                    .padding(.top, 20)
                    .scaleEffect(characterScale)
                    .opacity(characterOpacity)
                    .rotation3DEffect(
                        .degrees(characterRotation),
                        axis: (x: 0.3, y: 1, z: 0),
                        perspective: 0.5
                    )
                
                // MARK: - Day Streak Card (dengan animasi heboh)
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(currentStreak)")
                            .font(.system(size: 56, weight: .bold))
                            .foregroundColor(Color("pinkTextPrimary"))
                        
                        Text("/ \(targetStreak)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color("pinkTextPrimary"))
                    }
                    
                    Text("Day Streak")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.black)
                    
                    // Progress Bar with Fire
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            Capsule()
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 20)
                            
                            // Progress Fill
                            ZStack(alignment: .trailing) {
                                Capsule()
                                    .fill(Color("pinkTextPrimary"))
                                    .frame(width: max(20, progressAnim * geometry.size.width), height: 20)
                                
                                // Fire Icon at the end
                                if progressAnim > 0 {
                                    Image("fireStreakRed")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 26, height: 26)
                                        .offset(x: 8)
                                }
                            }
                        }
                    }
                    .frame(height: 20)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal, 20)
                .scaleEffect(cardScale)
                .opacity(cardOpacity)
                .rotation3DEffect(
                    .degrees(cardRotation),
                    axis: (x: 0.3, y: 1, z: 0),
                    perspective: 0.5
                )
                
                // MARK: - Monthly Progress Path
                ZStack {
                    // Layer 1: Lines (dengan animasi fade in)
                    Canvas { context, size in
                        var path = Path()
                        let bubbleRadius: CGFloat = 47.5
                        
                        // Line 1->2
                        path.move(to: CGPoint(x: 97, y: bubbleRadius))
                        path.addLine(to: CGPoint(x: size.width - 97, y: 110 + bubbleRadius))
                        
                        // Line 2->3
                        path.move(to: CGPoint(x: size.width - 97, y: 110 + bubbleRadius))
                        path.addLine(to: CGPoint(x: 97, y: 220 + bubbleRadius))
                        
                        // Line 3->4
                        path.move(to: CGPoint(x: 97, y: 220 + bubbleRadius))
                        path.addLine(to: CGPoint(x: size.width - 97, y: 330 + bubbleRadius))
                        
                        context.stroke(path, with: .color(.black), lineWidth: 2.5)
                    }
                    .frame(height: 400)
                    .opacity(linesOpacity)
                    
                    // Layer 2: Character di tengah line 1 (dengan animasi)
                    GeometryReader { geometry in
                        Image("charStreakSmall")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .position(
                                x: geometry.size.width / 2,
                                y: 80
                            )
                            .opacity(characterSmallOpacity)
                            .scaleEffect(characterSmallOpacity) // Scale dari 0 ke 1
                    }
                    .frame(height: 400)
                    
                    // Layer 3: Bubbles (dengan animasi muncul satu per satu)
                    VStack(spacing: 15) {
                        // Month 1
                        HStack {
                            MonthBubble(month: 1, isCompleted: true, hasCharacter: false)
                                .scaleEffect(bubbleStates[0] ? 1 : 0.5)
                                .opacity(bubbleStates[0] ? 1 : 0)
                            Spacer()
                        }
                        .padding(.horizontal, 50)
                        
                        // Month 2
                        HStack {
                            Spacer()
                            MonthBubble(month: 2, isCompleted: false, hasCharacter: false)
                                .scaleEffect(bubbleStates[1] ? 1 : 0.5)
                                .opacity(bubbleStates[1] ? 1 : 0)
                        }
                        .padding(.horizontal, 50)
                        
                        // Month 3
                        HStack {
                            MonthBubble(month: 3, isCompleted: false, hasCharacter: false)
                                .scaleEffect(bubbleStates[2] ? 1 : 0.5)
                                .opacity(bubbleStates[2] ? 1 : 0)
                            Spacer()
                        }
                        .padding(.horizontal, 50)
                        
                        // Month 4
                        HStack {
                            Spacer()
                            MonthBubble(month: 4, isCompleted: false, hasCharacter: false)
                                .scaleEffect(bubbleStates[3] ? 1 : 0.5)
                                .opacity(bubbleStates[3] ? 1 : 0)
                        }
                        .padding(.horizontal, 50)
                    }
                }
                .frame(height: 400)
                .padding(.top, 10)
                .padding(.bottom, 40)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Streak")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Back", systemImage: "chevron.left") {
                    router.selectedTab = 0
                    router.navigateTo(.menu)
                }
            }
        }
        .onAppear {
            startEntranceAnimation()
        }
    }
    
    private func startEntranceAnimation() {
        print("🎬 StreakView - Starting entrance animation!")
        
        // Step 1: Character muncul dengan bounce (0.2s)
        withAnimation(.spring(response: 0.8, dampingFraction: 0.65).delay(0.2)) {
            characterScale = 1.0
            characterOpacity = 1.0
            characterRotation = 0
        }
        
        // Step 2: Card streak muncul dengan bounce (0.4s)
        withAnimation(.spring(response: 0.8, dampingFraction: 0.65).delay(0.4)) {
            cardScale = 1.0
            cardOpacity = 1.0
            cardRotation = 0
        }
        
        // Step 3: Progress bar fill (0.7s)
        withAnimation(.easeOut(duration: 1.2).delay(0.7)) {
            progressAnim = progress
        }
        
        // Step 4: Lines fade in (0.9s)
        withAnimation(.easeOut(duration: 0.6).delay(0.9)) {
            linesOpacity = 1.0
        }
        
        // Step 5: Bubbles muncul satu per satu dengan bounce
        for (index, _) in bubbleStates.enumerated() {
            let delay = 1.1 + Double(index) * 0.15
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(delay)) {
                bubbleStates[index] = true
            }
        }
        
        // Step 6: Character kecil muncul terakhir (1.8s)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(1.8)) {
            characterSmallOpacity = 1.0
        }
    }
}

// MARK: - Month Bubble Component
struct MonthBubble: View {
    let month: Int
    let isCompleted: Bool
    let hasCharacter: Bool
    
    var body: some View {
        ZStack {
            // White background circle untuk menutupi line
            Circle()
                .fill(Color.white)
                .frame(width: 100, height: 100)
            
            // Bubble utama
            Circle()
                .fill(isCompleted ? Color("pinkTextPrimary") : Color.gray.opacity(0.25))
                .frame(width: 95, height: 95)
            
            VStack(spacing: 2) {
                Text("Month")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isCompleted ? .white : Color.gray.opacity(0.6))
                
                Text("\(month)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(isCompleted ? .white : Color.gray.opacity(0.6))
            }
        }
    }
}

// MARK: - Short Diagonal Line Shape
struct ShortDiagonalLine: Shape {
    enum Direction {
        case downRight, downLeft
    }
    
    let direction: Direction
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        switch direction {
        case .downRight:
            path.move(to: CGPoint(x: rect.minX + 20, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - 20, y: rect.maxY))
        case .downLeft:
            path.move(to: CGPoint(x: rect.maxX - 20, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + 20, y: rect.maxY))
        }
        
        return path
    }
}

#Preview {
    StreakView()
        .environmentObject(Router())
}
