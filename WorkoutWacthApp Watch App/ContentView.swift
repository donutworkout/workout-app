//
//  ContentView.swift
//  WorkoutWacthApp Watch App
//
//  Created by Nadaa Shafa Nadhifa on 14/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Watch App")
            Button("Send Ping") {
                WatchConnectivityManager.shared.sendMessage(["event": "ping"])
            }
        }
    }
}


#Preview {
    ContentView()
}
