//
//  ShippingAddress.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 18/01/2025.
//

import SwiftUI

struct ShippingAddress: View {
    @State private var shippingAddress = "John Doe\n26 Duong So 2 Thao Dien Ward, Apartment A\nDistrict 2, Ho Chi Minh City\nZIP: 700000\nPhone: +1234567890"
    var body: some View {
        AddressEditSheet(address: $shippingAddress,isProfile: true)
    }
}

#Preview {
    ShippingAddress()
}
