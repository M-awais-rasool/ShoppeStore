import SwiftUI

struct SuccessPopup: View {
    @Binding var isPresented: Bool
    @Binding var navigateToNextScreen:Bool
    @State private var checkmarkOffset: CGFloat = 30
    @State private var checkmarkScale: CGFloat = 0
    @State private var textOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 25) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 90, height: 90)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 3)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: checkmarkScale)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: "checkmark")
                    .font(.system(size: 35, weight: .bold))
                    .foregroundColor(.blue)
                    .offset(y: checkmarkOffset)
                    .scaleEffect(checkmarkScale)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    checkmarkOffset = 0
                    checkmarkScale = 1
                }
                withAnimation(.easeOut.delay(0.4)) {
                    textOpacity = 1
                }
                withAnimation(.easeOut.delay(0.6)) {
                    buttonOpacity = 1
                }
            }
            
            VStack(spacing: 12) {
                Text("Done!")
                    .font(.system(size: 28, weight: .bold))
                
                Text("Your card has been\nsuccessfully charged")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .opacity(textOpacity)
            Button(action: {
                withAnimation(.spring(response: 0.5)) {
                    isPresented = false
                    navigateToNextScreen = true
                }
            }) {
                Text("Track My Order")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal)
            .opacity(buttonOpacity)
        }
        .padding(.vertical, 30)
        .padding(.horizontal, 20)
        .frame(width: UIScreen.main.bounds.width - 60)
        .background(
            Color.white
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 10)
        )
    }
}

struct SuccessPopup_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            SuccessPopup(isPresented: .constant(true),navigateToNextScreen: .constant(false))
        }
    }
}
