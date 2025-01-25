
import SwiftUI
import Vision
import CoreML

struct ImageLens: View {
    @State  var imageUrl: String = ""
    //    @State private var detectedProductName: String = ""
    @State private var uiImage: UIImage?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var products: [Product] = []
    @State private var isBottomSheetPresented: Bool = false
    
    func getData(name:String)async{
        do {
            let res = try await GetSimilarProducts(name:name)
            if res.status == "success"{
                products = res.data ?? []
                isBottomSheetPresented = true
            }
        }
        catch{
            print(error)
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    if let url = URL(string: imageUrl), UIApplication.shared.canOpenURL(url) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: 200)
                                .cornerRadius(15)
                                .padding()
                                .onAppear {
                                    image.asUIImage { loadedImage in
                                        guard let loadedImage = loadedImage else {
                                            errorMessage = "Image Loading Failed"
                                            return
                                        }
                                        self.uiImage = loadedImage
                                        self.isLoading = true
                                        detectObjectsAndClassify(from: loadedImage)
                                    }
                                }
                        } placeholder: {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                .scaleEffect(1.5)
                                .frame(maxWidth: .infinity, maxHeight: 200)
                        }
                    } else {
                        Text("Invalid Image URL")
                            .foregroundColor(.red)
                    }
                    
                    VStack {
                        if isLoading {
                            ProgressView("Analyzing Image...")
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                .padding()
                        }
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    if !products.isEmpty {
                        LensBottomSheet(product: $products)
                    }
                    Spacer()
                }
                
            }
            
        }
        .background(Color.white)
    }
    
    
    private func detectObjectsAndClassify(from image: UIImage) {
        guard let cgImage = image.cgImage else {
            errorMessage = "Image Conversion Failed"
            return
        }
        
        do {
            let modelConfiguration = MLModelConfiguration()
            let model = try VNCoreMLModel(for: YOLOv3(configuration: modelConfiguration).model)
            
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error = error {
                    self.errorMessage = "Detection Request Error: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }
                
                if let results = request.results as? [VNRecognizedObjectObservation], !results.isEmpty {
                    if let _ = results.first {
                        classifyImage(image)
                    }
                } else {
                    self.errorMessage = "No Objects Detected"
                    self.isLoading = false
                }
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do{
                try handler.perform([request])
            }catch{
                self.errorMessage = "Detection Error: \(error.localizedDescription)"
                self.isLoading = false
            }
        } catch {
            self.errorMessage = "Model Initialization Error: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    private func classifyImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else {
            errorMessage = "Image Conversion Failed"
            return
        }
        
        do {
            let coreMLModel = try MobileNetV2(configuration: MLModelConfiguration()).model
            let model = try VNCoreMLModel(for: coreMLModel)
            
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error = error {
                    self.errorMessage = "Classification Request Error: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }
                
                if let results = request.results as? [VNClassificationObservation],
                   let firstResult = results.first {
                    //                    self.detectedProductName = firstResult.identifier
                    Task{
                        print("identifier",firstResult.identifier)
                        await getData(name:firstResult.identifier)
                    }
                    self.isLoading = false
                } else {
                    self.errorMessage = "No Classification Results"
                    self.isLoading = false
                }
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try handler.perform([request])
        } catch {
            self.errorMessage = "Classification Error: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
}

extension Image {
    func asUIImage(completion: @escaping (UIImage?) -> Void) {
        Task { @MainActor in
            let renderer = ImageRenderer(content: self)
            renderer.scale = UIScreen.main.scale
            if let uiImage = renderer.uiImage {
                completion(uiImage)
            } else {
                completion(nil)
            }
        }
    }
}

struct LensView_Previews: PreviewProvider {
    static var previews: some View {
        ImageLens(imageUrl: "https://example.com/sample-image.jpg")
    }
}


