//
//  ButtonComponent.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 15/01/2025.
//

import SwiftUI

struct ButtonComponent: View {
    let title: String
    let action: () -> Void
    var backgroundColor: Color = Color.blue
    var textColor: Color = Color.white
    var cornerRadius: CGFloat = 16
    var height: CGFloat = 50
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(backgroundColor)
                .cornerRadius(cornerRadius)
        }
    }
}
