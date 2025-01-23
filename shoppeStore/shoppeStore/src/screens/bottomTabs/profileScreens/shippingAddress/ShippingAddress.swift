//
//  ShippingAddress.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 18/01/2025.
//

import SwiftUI

struct ShippingAddress: View {
    @State private var addressData :Address? = nil
    
    func getData() async {
        do {
            let addressRes = try await GetAddres()
            guard addressRes.status == "success" else {
                return
            }
            addressData = addressRes.data
        } catch {
            print("An error occurred: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        VStack {
            if let _ = addressData {
                AddressEditSheet(address: $addressData, isProfile: true)
            }
        }
        .onAppear{
            Task{
                await getData()
            }
        }
    }
}

#Preview {
    ShippingAddress()
}
