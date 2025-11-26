////
////  WatchNotConnectedView.swift
////  WorkoutApp
////
////  Created by Jennifer Evelyn on 25/11/25.
////
//
//import SwiftUI
//
//struct WatchNotConnectedView: View {
//    @Environment(\.dismiss) private var dismiss
//    @EnvironmentObject var router: Router
//    @State private var jump = false
//    
//    var onConnect: () -> Void = {}
//    
//    private func startJumping() {
//        // Lompat ke atas
//        withAnimation(.easeOut(duration: 0.35)) {
//            jump = true
//        }
//        
//        // Turun lagi setelah 0.35 detik
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
//            withAnimation(.easeIn(duration: 0.35)) {
//                jump = false
//            }
//            
//            // Jeda 0.5 detik, lalu ulangi
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                startJumping()
//            }
//        }
//    }
//    
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 32) {
//                // MARK: - Title Text
//                Text("Watch Connect")
//                    .font(.system(size: 28, weight: .semibold))
//                    .foregroundColor(Color("pinkTextPrimary"))
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//                
//                Spacer()
//                
//                // MARK: - Watch Character
//                Image("charConnectWatch")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 200, height: 200)
//                    .offset(y: jump ? -35 : 0)
//                    .onAppear {
//                        startJumping()
//                    }
//                
//                Spacer()
//                
//                // MARK: - Description Text
//                Text("Connect your Apple Watch to track workouts and health data in real-time")
//                    .font(.system(size: 16, weight: .regular))
//                    .foregroundColor(.gray)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 32)
//                    .padding(.bottom, 16)
//                
//                // MARK: - Instructions Text
//                Text("Make sure your Apple Watch is paired with this iPhone via the Watch app")
//                    .font(.system(size: 14, weight: .regular))
//                    .foregroundColor(.gray)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 32)
//                    .padding(.bottom, 24)
//                
//                // MARK: - Open Watch App Button
//                PrimaryGlassButton(title: "Open Watch App") {
//                    if let url = URL(string: "itms-watch://") {
//                        UIApplication.shared.open(url)
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.bottom, 40)
//            }
//            .background(Color.white.ignoresSafeArea())
//            // MARK: - Navigation Title & Toolbar
//            .navigationTitle("Settings")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    Button(action: { dismiss() }) {
//                        Image(systemName: "xmark")
//                            .font(.system(size: 16, weight: .semibold))
//                            .foregroundColor(.black)
//                    }
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    WatchNotConnectedView()
//}
