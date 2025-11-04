//
//  MetricsView.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 30/10/25.
//
import SwiftUI

struct MetricView: View {
    let icon: String
    let value: String
    let unit: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    MetricView(icon: "heart.fill", value: "132", unit: "bpm")
}
