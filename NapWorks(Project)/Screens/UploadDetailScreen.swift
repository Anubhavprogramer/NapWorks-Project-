import SwiftUI

struct UploadDetailScreen: View {
    let image: UIImage
    @Environment(\.dismiss) var dismiss
    
    @State private var imageName: String = ""
    @State private var isUploading: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
                TextField("Reference Name", text: $imageName)
                    .padding()
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .frame(width: 340)
                
                Button(action: {
                    uploadImage()
                }) {
                    if isUploading {
                        ProgressView()
                            .frame(width: 100, height: 50)
                    } else {
                        Text("Submit")
                            .fontWeight(.bold)
                            .frame(width: 100, height: 50)
                            .background(imageName.isEmpty ? Color.gray : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                }
                .disabled(imageName.isEmpty || isUploading) // disable if name is empty or uploading
                
                Spacer()
            }
            .padding()
            .navigationTitle("Upload Image")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
    }
    
    private func uploadImage() {
        print("📤 Starting image upload: \(imageName)")
        isUploading = true
        FirebaseManager.shared.uploadImage(image: image, imageName: imageName) { result in
            switch result {
            case .success(let (url, storagePath)):
                print("✅ Image uploaded to storage, saving metadata...")
                FirebaseManager.shared.saveImageMetadata(name: imageName, url: url, storagePath: storagePath) { error in
                    DispatchQueue.main.async {
                        self.isUploading = false
                        if let error = error {
                            print("❌ Firestore error: \(error.localizedDescription)")
                        } else {
                            print("🎉 Upload successful! Metadata saved.")
                            // Force refresh the images list
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                FirebaseManager.shared.startListeningToImages()
                            }
                            dismiss()
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isUploading = false
                    print("❌ Upload error: \(error.localizedDescription)")
                }
            }
        }
    }
}
