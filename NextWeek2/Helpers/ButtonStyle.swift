//
//  ButtonStyle.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 5/5/25.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3)
            .fontWeight(.semibold)
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.text)
            .background(Color.accentColor)
            .clipShape(.rect(cornerRadius: 12))
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var myAppPrimaryButton: PrimaryButtonStyle { .init() }
}
