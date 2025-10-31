//
//  EditBodyInfoView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 30/10/25.
//

import SwiftUI

struct EditBodyInfoView: View {
    @EnvironmentObject var router: Router
    @State private var selectedHeight = 160
    @State private var selectedWeight = 50

    var body: some View {
        VStack(spacing: 32) {
            // MARK: - Header
            HStack {
                Button {
                    router.navigateTo(.profile)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            Text("Body Measurement")
                .font(.system(.title, weight: .semibold))
                .foregroundColor(Color("pinkTextPrimary"))
            
            VStack(spacing: 20) {
                HStack {
                    Text("Height:")
                    Spacer()
                    Text("\(selectedHeight) cm")
                }
                HStack {
                    Text("Weight:")
                    Spacer()
                    Text("\(selectedWeight) kg")
                }
            }
            .padding()
            .glassEffect(in: .rect(cornerRadius: 20))
            
            Spacer()
            
            PrimaryGlassButton(title: "Finish") {
                router.goBack(to: .tabBar)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.white.ignoresSafeArea())
    }
}


#Preview {
    EditBodyInfoView()
        .environmentObject(Router())
}
