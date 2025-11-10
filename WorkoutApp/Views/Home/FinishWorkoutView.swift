//
//  FinishWorkoutView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 05/11/25.
//

import SwiftUI

struct FinishWorkoutView: View {
    @EnvironmentObject var router: Router
    
    var characterImage: String = "buttercup"
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // MARK: - Character
            Image(characterImage)
                .resizable()
                .scaledToFit()
                .frame(width: 280, height: 280)
            
            // MARK: - Title
            VStack(spacing: 6) {
                Text("Congratulations!")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Color("pinkTextPrimary"))
                
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            
            // MARK: - Summary Card
            VStack(spacing: 12) {
                HStack {
                    summaryItem(title: "Workout Time", value: "0:15:18")
                    Divider()
                    summaryItem(title: "Active Calories", value: "100 kcal")
                }
                Divider()
                HStack {
                    summaryItem(title: "Total Calories", value: "130 kcal")
                    Divider()
                    summaryItem(title: "Avg. Heart Rate", value: "118 bpm")
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
            )
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            Spacer()
            
            // MARK: - Done Button
            PrimaryGlassButton(title: "Done") {
                router.navigateTo(.menu)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Reusable Summary Item
    @ViewBuilder
    func summaryItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
            Text(value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        FinishWorkoutView()
            .environmentObject(Router())
    }
}
