import SwiftUI


struct OrderTracking: View {
    @State var OrderId :String = ""
    @State private var appearSteps = false
    @State private var currentStatus: OrderStatus = .pending
    @Environment(\.presentationMode) var presentationMode
    
    var steps: [TrackingStep] {
        OrderStatus.allCases.map { status in
            TrackingStep(
                status: status,
                isCompleted: isStepCompleted(status),
                isActive: status == currentStatus
            )
        }
    }
    
    func isStepCompleted(_ status: OrderStatus) -> Bool {
        let statusIndex = OrderStatus.allCases.firstIndex(of: status)!
        let currentIndex = OrderStatus.allCases.firstIndex(of: currentStatus)!
        return statusIndex < currentIndex
    }
    
    func GetData()async{
        do{
            let orderReq = OrderStatusRequest(orderID: OrderId)
            let res = try await GetOrderStatus(order: orderReq)
            print(res)
            if res.status == "success"{
                if let status = OrderStatus(rawValue: res.orderStatus) {
                    self.currentStatus = status
                }
            }
        }catch{
            print(error)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            header
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    trackingNumberView
                    stepsView
                }
            }
            .background(Color(.systemBackground))
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    appearSteps = true
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal,10)
        .onAppear(){
            Task{
                await GetData()
            }
        }
    }
    
    private var header: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title)
                    .foregroundColor(.black)
            }
            Circle()
                .fill(Color.pink.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: currentStatus.icon)
                        .foregroundColor(.pink)
                )
            VStack(alignment: .leading, spacing: 4) {
                Text("To Receive")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Track Your Order")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(currentStatus.rawValue)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(currentStatus == .delivered ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                )
                .foregroundColor(currentStatus == .delivered ? .green : .blue)
        }
    }
    
    private var trackingNumberView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("OrderId")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(OrderId)
                    .font(.system(.body, design: .monospaced))
            }
            Spacer()
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var stepsView: some View {
        VStack(spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 16) {
                        VStack(spacing: 0) {
                            Circle()
                                .fill(getStepColor(step))
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Group {
                                        if step.isCompleted {
                                            Image(systemName: "checkmark")
                                                .font(.caption2)
                                                .foregroundColor(.white)
                                        }
                                    }
                                )
                            
                            if index < steps.count - 1 {
                                Rectangle()
                                    .fill(step.isCompleted ? Color.blue : Color.gray.opacity(0.3))
                                    .frame(width: 2, height: 60)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack{
                                Text(step.status.rawValue)
                                    .font(.headline)
                                Spacer()
                            }
                            
                            Text(step.status.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .opacity(appearSteps ? 1 : 0)
                        .offset(x: appearSteps ? 0 : 50)
                        .animation(.easeOut(duration: 0.8).delay(Double(index) * 0.2), value: appearSteps)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
    
    private func getStepColor(_ step: TrackingStep) -> Color {
        if step.isCompleted {
            return .blue
        } else if step.isActive {
            return .green
        } else {
            return .gray.opacity(0.3)
        }
    }
}

#Preview {
    OrderTracking()
}
