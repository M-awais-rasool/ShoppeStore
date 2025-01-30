//
//  StepModel.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 30/01/2025.
//

import Foundation

enum OrderStatus: String, CaseIterable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case packed = "Packed"
    case shipped = "Shipped"
    case delivered = "Delivered"
    
    var description: String {
        switch self {
        case .pending:
            return "Your order has been received and is being processed."
        case .confirmed:
            return "Your order has been confirmed and is being prepared."
        case .packed:
            return "Your order has been packed and is ready for shipping."
        case .shipped:
            return "Your order is on its way to you."
        case .delivered:
            return "Your order has been delivered successfully."
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock"
        case .confirmed: return "checkmark.circle"
        case .packed: return "shippingbox"
        case .shipped: return "box.truck.fill"
        case .delivered: return "house.circle"
        }
    }
}

struct TrackingStep: Identifiable {
    let id = UUID()
    let status: OrderStatus
    var isCompleted: Bool
    var isActive: Bool
}

struct OrderStatusRequest: Codable {
    let orderID: String
}
