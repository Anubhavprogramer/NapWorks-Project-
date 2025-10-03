import SwiftUI

struct ImagesScreen: View {
   
    @State private var images: [UploadedImage] = []
    @State private var isLoading: Bool = true
    
    // 2 flexible columns
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading Images...")
                        .padding()
                } else if images.isEmpty {
                    Text("No images uploaded yet")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(images) { imageItem in
                                CardView(imageItem: imageItem, deleteAction: {
                                    deleteImage(imageItem)
                                })
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                }
            }
            .navigationTitle("Uploaded Images")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadImages()
            }
        }
    }
    
    private func loadImages() {
        isLoading = true
        FirebaseManager.shared.fetchAllImages { fetchedImages in
            self.images = fetchedImages
            self.isLoading = false
        }
    }
    
    private func deleteImage(_ imageItem: UploadedImage) {
        if let index = images.firstIndex(where: { $0.id == imageItem.id }) {
            images.remove(at: index)
        }
        FirebaseManager.shared.deleteImage(imageId: imageItem.id) { error in
            if let error = error {
                print("Error deleting image: \(error)")
            } else {
                print("Image deleted successfully")
            }
        }
    }
}

struct CardView: View {
    let imageItem: UploadedImage
    let deleteAction: () -> Void
    
    var body: some View {
        VStack(spacing: 5) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: imageItem.url)) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.2)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.red)
                    @unknown default:
                        EmptyView()
                    }
                }
                
                Button(action: deleteAction) {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                        .padding(5)
                }
            }
            
            Text(imageItem.name)
                .font(.caption)
                .lineLimit(1)
                .padding(.horizontal, 5)
                .padding(.bottom, 5)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
