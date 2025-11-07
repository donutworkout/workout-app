//
//  SummaryView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 20/10/25.
//

import SwiftUI

struct SummaryView: View {
    let weekDays = ["M", "T", "W", "T", "F", "S", "S"]
    let progress: [Double] = [1.0, 0.9, 0.3, 0.6, 0.2, 0.4, 0.7]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Title
                Text("Summary")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 32)
                
                // MARK: - Week Progress Circles
                HStack(spacing: 8) {
                    ForEach(0..<weekDays.count, id: \.self) { index in
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(Color("pinkTextTertiary").opacity(0.44))
                                    .frame(width: 44, height: 44)
                                GeometryReader { geo in
                                    let height = geo.size.height
                                    Circle()
                                        .fill(Color("pinkTextPrimary"))
                                        .frame(width: 44, height: 44)
                                        .mask(
                                            Rectangle()
                                                .frame(height: height * progress[index])
                                                .offset(y: height * (1 - progress[index]))
                                        )
                                }
                                .frame(width: 44, height: 44)
                            }
                            Text(weekDays[index])
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                }

                // MARK: - Character
                VStack {
                    LottieView(name: "characterAnimation", loopMode: .loop)
                        .frame(width: 300, height: 300)
                        .scaleEffect(0.3)
                        .padding(.vertical, 8)
                }
                .frame(maxWidth: .infinity)

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
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.white.ignoresSafeArea())
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

#Preview {
    SummaryView()
}
