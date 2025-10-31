//
//  EditMotivationView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 30/10/25.
//

import SwiftUI

struct EditMotivationView: View {
    @EnvironmentObject var router: Router
    @State private var selectedMotivation: String? = nil
    
    var body: some View {
        VStack(spacing: 32) {
            HStack {
                Button {
                    router.goBack(to: .tabBar)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            Text("Your Motivation")
                .font(.system(.title, weight: .semibold))
                .foregroundColor(Color("pinkTextPrimary"))
            
            VStack(spacing: 16) {
                ForEach(["Build Muscle", "Lose Weight", "Keep Fit"], id: \.self) { goal in
                    Button {
                        selectedMotivation = goal
                    } label: {
                        Text(goal)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(selectedMotivation == goal ? .white : .black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(selectedMotivation == goal ? Color("pinkTextPrimary") : Color.white)
                                    .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 3)
                            )
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            PrimaryGlassButton(title: "Finish") {
                router.navigateTo(.profile)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.white.ignoresSafeArea())
    }
}


#Preview {
    EditMotivationView()
        .environmentObject(Router())
}
