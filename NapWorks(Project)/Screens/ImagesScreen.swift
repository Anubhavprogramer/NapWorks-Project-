import SwiftUI

struct ImagesScreen: View {
   
    @State private var images: [UploadedImage] = []
    @State private var isLoading: Bool = true
    @State private var showDeleteAlert = false
    @State private var imageToDelete: UploadedImage?
    
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else if images.isEmpty {
                    ContentUnavailableView("No Images", 
                                         systemImage: "photo.on.rectangle.angled",
                                         description: Text("Upload your first image to get started"))
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(images) { imageItem in
                                CardView(imageItem: imageItem, deleteAction: {
                                    imageToDelete = imageItem
                                    showDeleteAlert = true
                                })
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    .refreshable {
                        loadImages()
                    }
                }
            }
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadImages()
            }
            .alert("Delete Image", isPresented: $showDeleteAlert, presenting: imageToDelete) { imageItem in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteImage(imageItem)
                }
            } message: { imageItem in
                Text("Are you sure you want to delete \"\(imageItem.name)\"?")
            }
        }
    }
    
    private func loadImages() {
        isLoading = true
        FirebaseManager.shared.fetchAllImages { fetchedImages in
            DispatchQueue.main.async {
                self.images = fetchedImages
                self.isLoading = false
            }
        }
    }
    
    private func deleteImage(_ imageItem: UploadedImage) {
        // Remove from UI immediately
        if let index = images.firstIndex(where: { $0.id == imageItem.id }) {
            images.remove(at: index)
        }
        
        // Delete from Firebase (both Storage and Firestore)
        FirebaseManager.shared.deleteImage(imageItem: imageItem) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error deleting image: \(error)")
                    // Add back to UI if deletion failed
                    self.images.append(imageItem)
                } else {
                    print("Image deleted successfully from both Storage and Firestore")
                }
            }
        }
    }
}

struct CardView: View {
    let imageItem: UploadedImage
    let deleteAction: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: imageItem.url)) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 150)
                            .redacted(reason: .placeholder)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 150)
                            .clipped()
                            .cornerRadius(12)
                    case .failure:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 150)
                            .overlay(
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                
                Button(action: deleteAction) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(.white, .red)
                        .font(.title2)
                }
                .padding(8)
            }
            
            Text(imageItem.name)
                .font(.footnote)
                .lineLimit(1)
                .foregroundColor(.primary)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
