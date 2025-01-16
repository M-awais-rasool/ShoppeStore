//
//  ContentView.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 16/01/2025.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    var body: some View {
        Group {
            if isLoggedIn {
                BottomTabView()
            } else {
                NavigationStack {
                    LandingScreen()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
