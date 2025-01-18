//
//  LinkButton.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 15/01/2025.
//

import SwiftUI

struct LinkButton: View {
    var title: String
    var backgroundColor: Color?
    var textColor: Color?
    var destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            Text(title)
                .font(.headline)
                .foregroundColor(textColor)
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(backgroundColor)
                .cornerRadius(15)
        }
    }
}

