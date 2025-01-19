import SwiftUI
import PhotosUI

struct SignUpScreen: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var phoneNumber: String = ""
    
    @State private var emailError: String = ""
    @State private var passwordError: String = ""
    @State private var phoneNoEror: String = ""
    
    @State private var isShowingImagePicker = false
    @State private var isCameraSelected = false
    @State private var selectedImage: UIImage? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("topGrayBlob")
                    .resizable()
                    .scaledToFit()
                    .position(x: 30, y: 20)
                
                Image("centerBlueBlob")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.2)
                    .position(x: geometry.size.width * 1, y: geometry.size.height * 0.2)
                
                VStack(alignment: .leading, spacing: 24) {
                    Spacer()
                    Text("Create\nAccount")
                        .font(.system(size: 40, weight: .bold))
                        .padding(.top, 60)
                    
                    ZStack {
                        Circle()
                            .strokeBorder(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [5]))
                            .frame(width: 100, height: 100)
                        
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Button(action: showImageSourceAlert) {
                                Image(systemName: "camera")
                                    .font(.system(size: 30))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                    
                    VStack(spacing: 16) {
                        InputComponent(
                            placeholder: "Enter your email",
                            inputText: $email,
                            error: emailError,
                            keyboardType: .emailAddress
                        )
                        InputComponent(
                            placeholder: "Enter your password",
                            imageName: "eye.slash", inputText: $password,
                            isSecure: true,
                            error: passwordError,
                            keyboardType: .numberPad
                        )
                        InputComponent(
                            placeholder: "Enter your phone no",
                            inputText: $phoneNumber,
                            error: phoneNoEror,
                            keyboardType: .numberPad
                        )
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        ButtonComponent(
                            title: "Done",
                            action: {}
                        )
                        
                        ButtonComponent(
                            title: "Cancel",
                            action: { dismiss() },
                            backgroundColor: Color.clear,
                            textColor: Color.black
                        )
                    }
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
            }
            .navigationBarBackButtonHidden(true)
            .edgesIgnoringSafeArea(.all)
            .sheet(isPresented: $isShowingImagePicker) {
                if isCameraSelected {
                    ImagePicker(sourceType: .camera, selectedImage: $selectedImage)
                } else {
                    ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
                }
            }
        }
    }
    
    private func showImageSourceAlert() {
        let alert = UIAlertController(title: "Select Image Source", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            isCameraSelected = true
            isShowingImagePicker = true
        })
        alert.addAction(UIAlertAction(title: "Gallery", style: .default) { _ in
            isCameraSelected = false
            isShowingImagePicker = true
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(alert, animated: true, completion: nil)
        }
    }
}

#Preview {
    SignUpScreen()
}
