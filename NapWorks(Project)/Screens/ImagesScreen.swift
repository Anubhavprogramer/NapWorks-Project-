import SwiftUI

struct ImagesScreen: View {
   
    @State private var images: [UploadedImage] = []
    @State private var isLoading: Bool = true
    
    // 2 flexible columns for dynamic height
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                if isLoading {
                    ProgressView("Loading Images...")
                        .padding()
                } else if images.isEmpty {
                    Text("No images uploaded yet")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(images) { imageItem in
                            ZStack(alignment: .topTrailing) {
                                VStack(alignment: .leading, spacing: 5) {
                                    AsyncImage(url: URL(string: imageItem.url)) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(maxWidth: .infinity)
                                        case .success(let image):
                                            GeometryReader { geo in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: geo.size.width, height: geo.size.width * 1) // placeholder, dynamic below
                                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                                    .clipped()
                                            }
                                            .aspectRatio(1, contentMode: .fit)
                                        case .failure:
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxWidth: .infinity)
                                                .foregroundColor(.red)
                                        @unknown default:
                                            EmptyView()
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
                                
                                // Delete button
                                Button(action: {
                                    deleteImage(imageItem)
                                }) {
                                    Image(systemName: "trash.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                        .padding(5)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
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
