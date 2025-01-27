import SwiftUI
import Vision
import CoreML

struct ImageLens: View {
    @State var imageUrl: String = ""
    @State var productID: String = ""
    @State private var uiImage: UIImage?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var products: [Product] = []
    @State private var isBottomSheetPresented: Bool = false
    @State private var analysisProgress: CGFloat = 0
    @State private var timeRemaining: Int = 5
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    func getData(name:String)async{
        do {
            let res = try await GetSimilarProducts(name:name,id:productID)
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
        VStack{
            ZStack {
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack{
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .shadow(radius: 10)
                            .frame(height: 250)
                        
                        if let url = URL(string: imageUrl), UIApplication.shared.canOpenURL(url) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .scaleEffect(1.5)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .frame(height: 250)
                                        .cornerRadius(15)
                                    
                                        .onAppear {
                                            image.asUIImage { loadedImage in
                                                guard let loadedImage = loadedImage else {
                                                    errorMessage = "Image Loading Failed"
                                                    return
                                                }
                                                self.uiImage = loadedImage
                                                self.isLoading = true
                                                startAnalysis(loadedImage)
                                            }
                                        }
                                case .failure(_):
                                    Text("Failed to load image")
                                        .foregroundColor(.red)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            VStack(spacing: 10) {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("Invalid Image URL")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom,10)
                    
                    if isLoading {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 4)
                                
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * analysisProgress, height: 4)
                                    .animation(.linear, value: analysisProgress)
                            }
                            .cornerRadius(2)
                        }
                        .frame(height: 4)
                        .padding(.horizontal)
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.red.opacity(0.1))
                            )
                            .padding(.horizontal)
                    }
                    LensBottomSheet(product: $products, isLoading: $isLoading)
                        .transition(.move(edge: .bottom))
                }
            }
        }
        .onReceive(timer) { _ in
            if isLoading && timeRemaining > 0 {
                timeRemaining -= 1
                analysisProgress = CGFloat(5 - timeRemaining) / 5.0
            }
        }
    }
    
    private func startAnalysis(_ image: UIImage) {
        timeRemaining = 5
        analysisProgress = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            classifyImage(image)
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
                
                if let results = request.results as? [VNClassificationObservation] {
                    if let topResult = results.sorted(by: { $0.confidence > $1.confidence }).first {
                        Task {
                            print(topResult.identifier)
                            await getData(name: topResult.identifier)
                        }
                        self.isLoading = false
                    } else {
                        self.errorMessage = "No Classification Results"
                        self.isLoading = false
                    }
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

#Preview {
    ImageLens(imageUrl: "https://gratisography.com/wp-content/uploads/2024/11/gratisography-augmented-reality-800x525.jpg")
}
