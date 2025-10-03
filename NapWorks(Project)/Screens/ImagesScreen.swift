import SwiftUI

struct ImagesScreen: View {
   
    @StateObject private var firebaseManager = FirebaseManager.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var showDeleteAlert = false
    @State private var imageToDelete: UploadedImage?
    @State private var showLogoutAlert = false
    
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        NavigationView {
            Group {
                if firebaseManager.isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else if firebaseManager.images.isEmpty {
                    ContentUnavailableView("No Images", 
                                         systemImage: "photo.on.rectangle.angled",
                                         description: Text("Upload your first image to get started"))
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(firebaseManager.images) { imageItem in
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
                        // Manual refresh if needed (though real-time updates make this less necessary)
                        firebaseManager.stopListeningToImages()
                        firebaseManager.startListeningToImages()
                    }
                }
            }
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(leading: Button(action: {
                showLogoutAlert = true
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Logout")
                }
                .foregroundColor(.red)
            })
            .onAppear {
                firebaseManager.startListeningToImages()
            }
            .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
                if isAuthenticated {
                    firebaseManager.startListeningToImages()
                } else {
                    firebaseManager.stopListeningToImages()
                }
            }
            .onDisappear {
                // Don't stop listener on disappear to maintain real-time updates
                // Only stop when app is truly done with this data
            }
            .alert("Delete Image", isPresented: $showDeleteAlert, presenting: imageToDelete) { imageItem in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteImage(imageItem)
                }
            } message: { imageItem in
                Text("Are you sure you want to delete \"\(imageItem.name)\"?")
            }
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    logout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
    }
    
    private func deleteImage(_ imageItem: UploadedImage) {
        FirebaseManager.shared.deleteImage(imageItem: imageItem) { error in
            if let error = error {
                print("❌ Error deleting image: \(error)")
            }
        }
    }
    
    private func logout() {
        authManager.signOut { success in
            if success {
                // Stop listening to images when user logs out
                firebaseManager.stopListeningToImages()
            }
        }
    }
}

struct CardView: View {
    let imageItem: UploadedImage
    let deleteAction: () -> Void
    @State private var loadedImage: UIImage?
    @State private var isLoading = false
    @State private var hasError = false
    @State private var retryCount = 0
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Group {
                    if let loadedImage = loadedImage {
                        Image(uiImage: loadedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 150)
                            .clipped()
                            .cornerRadius(12)
                    } else if isLoading {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 150)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(0.8)
                            )
                    } else if hasError {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 150)
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "photo")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                    Text("Tap to retry")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            )
                            .onTapGesture {
                                loadImage()
                            }
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 150)
                            .redacted(reason: .placeholder)
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
        .onAppear {
            if loadedImage == nil && !isLoading {
                loadImage()
            }
        }
    }
    
    private func loadImage() {
        guard let url = URL(string: imageItem.url) else {
            hasError = true
            return
        }
        
        isLoading = true
        hasError = false
        retryCount += 1
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    if retryCount < 3 {
                        // Auto-retry with exponential backoff
                        let delay = Double(retryCount) * 1.0
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            self.loadImage()
                        }
                    } else {
                        self.hasError = true
                    }
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    self.hasError = true
                    return
                }
                
                self.loadedImage = image
                self.hasError = false
                self.retryCount = 0
            }
        }.resume()
    }
}
