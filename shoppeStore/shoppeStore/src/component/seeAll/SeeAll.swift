//
//  SeeAll.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 16/01/2025.
//

import SwiftUI

struct SeeAll: View {
    var title: String
    var destination: AnyView 
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black)
            
            Spacer()
            
            NavigationLink(destination: destination) {
                HStack(spacing: 4) {
                    Text("See All")
                        .foregroundColor(.black)
                        .font(.system(size: 14, weight: .medium))
                    
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundColor(.black)
                        
                }
            }
        }
    }
}

