import SwiftUI

struct ToastView: View {
    @Binding var isShowing: Bool
    let message: String
    
    var body: some View {
        GeometryReader { geometry in
            if isShowing {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(message)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.8))
                                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                            )
                        Spacer()
                    }
                    .padding(.bottom, geometry.safeAreaInsets.bottom )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .zIndex(1)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isShowing = false
                        }
                    }
                }
            }
        }
    }
}

struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            ToastView(isShowing: $isShowing, message: message)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isShowing)
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, message: String) -> some View {
        modifier(ToastModifier(isShowing: isShowing, message: message))
    }
}
