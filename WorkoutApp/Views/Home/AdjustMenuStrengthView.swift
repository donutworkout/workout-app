//
//  AdjustMenuStrengthView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 24/10/25.
//

import SwiftUI

struct AdjustMenuStrengthView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMenu: StrengthMenuType = .bodyweight
    
    let bodyweightWorkouts: [WorkoutItem] = [
        WorkoutItem(image: "bridge", name: "Bridge", detail: "2 x 30 sec"),
        WorkoutItem(image: "plank", name: "Plank", detail: "3 x 30 sec"),
        WorkoutItem(image: "kneetap", name: "Knee Tap", detail: "1 x 12"),
        WorkoutItem(image: "catcow", name: "Cat and Cow", detail: "1 x 12")
    ]
    
    let gymWorkouts: [WorkoutItem] = [
        WorkoutItem(image: "legpress", name: "Leg Press", detail: "3 x 10"),
        WorkoutItem(image: "latpulldown", name: "Lat Pulldown", detail: "3 x 8"),
        WorkoutItem(image: "cablecurl", name: "Cable Curl", detail: "3 x 12"),
        WorkoutItem(image: "shoulderpress", name: "Shoulder Press", detail: "3 x 10")
    ]
    
    init() {
        // Custom segmented control warna pink
        let pinkColor = UIColor(named: "pinkTextPrimary") ?? UIColor.systemPink
        let selectedAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white]
        let normalAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
        let appearance = UISegmentedControl.appearance()
        appearance.selectedSegmentTintColor = pinkColor
        appearance.setTitleTextAttributes(selectedAttrs, for: .selected)
        appearance.setTitleTextAttributes(normalAttrs, for: .normal)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Custom Header (inline-style)
            HStack {
                Button(action: {
                    dismiss()
                }) {
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
                
                Text("Today’s Strength Menu!")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("pinkTextPrimary"))
                
                Spacer()
                // Placeholder biar text tetap di tengah
                Circle()
                    .fill(Color.clear)
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // MARK: - Segmented Control
                    Picker("Menu Type", selection: $selectedMenu) {
                        ForEach(StrengthMenuType.allCases, id: \.self) { type in
                            Text(type.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // MARK: - Workout Cards
                    VStack(spacing: 16) {
                        ForEach(selectedMenu == .bodyweight ? bodyweightWorkouts : gymWorkouts) { workout in
                            WorkoutItemCard(workout: workout)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // MARK: - Button
                    PrimaryGlassButton(title: "Start Now") {
                        print("Workout started")
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

// MARK: - Enums & Models
enum StrengthMenuType: String, CaseIterable {
    case bodyweight = "Bodyweight"
    case gym = "Gym"
}

struct WorkoutItem: Identifiable {
    var id = UUID()
    var image: String
    var name: String
    var detail: String
}

#Preview {
    AdjustMenuStrengthView()
}
