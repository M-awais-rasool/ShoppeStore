import SwiftUI
import PhotosUI
import AVFoundation

struct SignUpScreen: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var name: String = ""
    
    @State private var emailError: String = ""
    @State private var passwordError: String = ""
    @State private var nameError: String = ""
    @State private var imageError: String = ""
    
    @State private var isShowingImagePicker = false
    @State private var isCameraSelected = false
    @State private var selectedImage: UIImage? = nil
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
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
                    
                    VStack(alignment: .leading) {
                        ZStack {
                            Circle()
                                .strokeBorder(imageError.isEmpty ? Color.blue : Color.red, style: StrokeStyle(lineWidth: 2, dash: [5]))
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
                                        .foregroundColor(imageError.isEmpty ? Color.blue : Color.red)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20)
                    
                    VStack(spacing: 16) {
                        InputComponent(
                            placeholder: "Enter your name",
                            inputText: $name,
                            error: nameError,
                            keyboardType: .numberPad
                        )
                        
                        InputComponent(
                            placeholder: "Enter your email",
                            inputText: $email,
                            error: emailError,
                            keyboardType: .emailAddress
                        )
                        
                        InputComponent(
                            placeholder: "Enter your password",
                            imageName: "eye.slash",
                            inputText: $password,
                            isSecure: true,
                            error: passwordError,
                            keyboardType: .default
                        )
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        ButtonComponent(
                            title: isLoading ? "Loading..." : "Done",
                            action: {
                                if validateAll() {
                                    isLoading = true
                                    Task {
                                        await signUp()
                                        isLoading = false
                                    }
                                }
                            }
                        )
                        .disabled(isLoading)
                        
                        ButtonComponent(
                            title: "Cancel",
                            action: { dismiss() },
                            backgroundColor: Color.clear,
                            textColor: Color.black
                        )
                        .disabled(isLoading)
                    }
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
            }
            .navigationBarBackButtonHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Message"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $isShowingImagePicker) {
                if isCameraSelected {
                    ImagePicker(sourceType: .camera, selectedImage: $selectedImage)
                } else {
                    ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
                }
            }
        }
    }
    
    private func validateEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        let isValid = emailPredicate.evaluate(with: email)
        emailError = isValid ? "" : "Please enter a valid email address"
        return isValid
    }
    
    private func validatePassword() -> Bool {
        let isValid = password.count >= 6
        passwordError = isValid ? "" : "Password must be at least 8 characters"
        return isValid
    }
    
    private func validateName() -> Bool {
        let isValid = !name.isEmpty
        nameError = isValid ? "" : "Please enter a valid 10-digit phone number"
        return isValid
    }
    
    private func validateImage() -> Bool {
        let isValid = selectedImage != nil
        imageError = isValid ? "" : "Please select a profile image"
        return isValid
    }
    
    private func validateAll() -> Bool {
        let isEmailValid = validateEmail()
        let isPasswordValid = validatePassword()
        let isPhoneValid = validateName()
        let isImageValid = validateImage()
        
        return isEmailValid && isPasswordValid && isPhoneValid && isImageValid
    }
    
    private func signUp() async {
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.5) else { return }
        
        let signUpData = [
            "name": name,
            "email": email,
            "password": password,
            "image": imageData.base64EncodedString()
        ]
        
        do {
            let response = try await createAccount(body: signUpData)
            print(response)
            DispatchQueue.main.async {
                alertMessage = "Sign up successful!"
                showAlert = true
                dismiss()
            }
        } catch {
            DispatchQueue.main.async {
                alertMessage = "Sign up failed: \(error.localizedDescription)"
                showAlert = true
                isLoading = false
            }
        }
    }
    
    private func showImageSourceAlert() {
        let alert = UIAlertController(title: "Select Image Source", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            requestCameraPermission()
        })
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default) { _ in
            requestPhotoLibraryPermission()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(alert, animated: true, completion: nil)
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { response in
            if response {
                DispatchQueue.main.async {
                    isCameraSelected = true
                    isShowingImagePicker = true
                }
            } else {
                showPermissionDeniedAlert(for: "camera")
            }
        }
    }
    
    private func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    isCameraSelected = false
                    isShowingImagePicker = true
                case .denied, .restricted:
                    showPermissionDeniedAlert(for: "photo library")
                default:
                    break
                }
            }
        }
    }
    
    private func showPermissionDeniedAlert(for resource: String) {
        let alertController = UIAlertController(
            title: "Permission Denied",
            message: "You need to allow access to the \(resource) in order to use this feature.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(alertController, animated: true, completion: nil)
        }
    }
}

#Preview {
    SignUpScreen()
}

