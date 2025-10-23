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
        VStack(alignment: .leading, spacing: 20) {
            // MARK: - Title
            Text("Summary")
                .font(.system(size: 32, weight: .bold))
                .padding(.top, 30)
                .padding(.horizontal)
            
            // MARK: - Week Progress Circles
            HStack(spacing: 16) {
                ForEach(0..<weekDays.count, id: \.self) { index in
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(Color("pinkTextTertiary").opacity(0.44))
                                .frame(width: 40, height: 40)
                            
                            GeometryReader { geo in
                                let height = geo.size.height
                                
                                Circle()
                                    .fill(Color("pinkTextPrimary"))
                                    .frame(width: 40, height: 40)
                                    .mask(
                                        Rectangle()
                                            .frame(height: height * progress[index])
                                            .offset(y: height * (1 - progress[index]))
                                    )
                            }
                            .frame(width: 40, height: 40)
                        }

                        
                        // Day label
                        Text(weekDays[index])
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(.horizontal)
            
            // MARK: - Image (Powerpuff Girl)
            Spacer()
            Image("character") // ganti dengan nama asset kamu
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .opacity(0.9)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity, alignment: .center)
            
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
            .padding(.horizontal)
            .padding(.bottom, 30)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
