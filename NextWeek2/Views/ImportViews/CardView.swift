//
//  CardView.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 6/5/25.
//

import SwiftUI

struct CardView: View {
    @Environment(\.colorScheme) private var colorScheme
    let date: Date
    let shift: String
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(date.formatted(date: .long, time: .omitted))
                .font(.callout)
                .foregroundColor(.secondary)
            Spacer()
            Text(shift)
                .font(.system(size: 32, weight: .black, design: .rounded))
        }
        .padding(.horizontal)
    }
}

#Preview {
    CardView(date: .now, shift: "3")
}
