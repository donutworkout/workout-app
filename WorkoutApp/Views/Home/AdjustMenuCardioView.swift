//
//  AdjustMenuCardioView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 24/10/25.
//

import SwiftUI

struct AdjustMenuCardioView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMenu: String? = nil
    @State private var showCustomAlert = false
    
    // MARK: - Cardio Menu
    private let cardioMenu = [
        "Outdoor Walk", "Indoor Walk",
        "Cycling", "Swimming",
        "Badminton", "Basketball",
        "Volleyball", "Tennis",
        "Padel", "Soccer"
    ]
    
    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                
                // MARK: - Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                            )
                    }
                    
                    Spacer()
                    
                    Text("Today’s Cardio Menu!")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color("pinkTextPrimary"))
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                // MARK: - Menu Grid
                VStack(spacing: 12) {
                    let gridItems = [GridItem(.flexible()), GridItem(.flexible())]
                    LazyVGrid(columns: gridItems, spacing: 16) {
                        ForEach(cardioMenu, id: \.self) { activity in
                            Button(action: {
                                handleSelection(for: activity)
                            }) {
                                Text(activity)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(selectedMenu == activity ? .white : .black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 70)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedMenu == activity ? Color("pinkTextPrimary") : Color.white)
                                            .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 3)
                                    )
                            }
                            .buttonStyle(ScaleButtonStyle()) // efek ditekan kecil
                            .animation(.easeInOut(duration: 0.2), value: selectedMenu)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                Spacer()
                
                // MARK: - Start Button (Disabled if no selection)
                PrimaryGlassButton(title: "Start Now") {
                    if selectedMenu == nil {
                        showCustomAlert = true
                    } else {
                        print("Cardio started: \(selectedMenu ?? "")")
                    }
                }
                .padding(.horizontal)
                .padding(.vertical)
                .opacity(isButtonEnabled ? 1 : 0.5)
                .disabled(!isButtonEnabled) // 🔒 disable kalau belum pilih
            }
            .animation(.easeInOut, value: selectedMenu)
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
                    Text("Oops!")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    
                    Text("Please pick one cardio activity to begin.")
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
    private func handleSelection(for activity: String) {
        if selectedMenu == activity {
            selectedMenu = nil
        } else {
            selectedMenu = activity
        }
    }
    
    private var isButtonEnabled: Bool {
        selectedMenu != nil
    }
}

// MARK: - Small Scale Effect on Tap
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    AdjustMenuCardioView()
}
