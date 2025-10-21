//
//  ProfileRow.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 21/10/25.
//

import SwiftUI

struct ProfileRow: View {
    var icon: String
    var title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color("pinkTextPrimary"))
                .frame(width: 32)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.black)
                .fontWeight(.medium)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.grayTextPrimary)
        }
        .padding(.vertical, 14)
        .padding(.horizontal)
    }
}

#Preview {
    ProfileRow(icon: "person.crop.circle", title: "About Me")
}
