//
//  ProfileScreen.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 16/01/2025.
//

import SwiftUI

struct ProfileScreen: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    var body: some View {
        ButtonComponent(title: "Cancel", action: {
            isLoggedIn = false
        },backgroundColor: Color.clear,textColor:  Color.black)
    }
}

#Preview {
    ProfileScreen()
}
