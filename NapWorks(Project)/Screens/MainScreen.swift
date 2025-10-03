//
//  Upload.swift
//  NapWorks(Project)
//
//  Created by Anubhav Dubey on 03/10/25.
//

import SwiftUI



struct MainScreen: View {
   
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: IdentifiableImage? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                
                Spacer()
                
                // App Title
                VStack(spacing: 8) {
                    Image(systemName: "photo.stack.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("NapWorks Gallery")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Upload and manage your images")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
                
                // Select from Photo Library Button
                Button(action: {
                    openPhotoLibrary()
                }) {
                    VStack(spacing: 15) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        Text("Select from Photos")
                            .font(.headline)
                            .foregroundColor(.green)
                        Text("Choose from your photo library")
                            .font(.caption)
                            .foregroundColor(.green.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .background(Color.green.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [12, 6]))
                            .foregroundColor(.green)
                    )
                    .cornerRadius(20)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Divider with OR
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.green.opacity(0.3))
                    
                    Text("OR")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                        .padding(.horizontal, 16)
                        .background(Color(.systemBackground))
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.green.opacity(0.3))
                }
                .padding(.vertical, 10)

                // Camera Button
                Button(action: {
                    openCamera()
                }) {
                    HStack(spacing: 15) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Take Photo")
                                .font(.headline)
                                .foregroundColor(.green)
                            Text("Capture with camera")
                                .font(.caption)
                                .foregroundColor(.green.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.green.opacity(0.6))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.green, lineWidth: 1.5)
                    )
                    .cornerRadius(16)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
            }
            .padding(.horizontal, 24)
            .navigationTitle("Upload")
        }
        // Image Picker Sheet
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: sourceType) { image in
                self.selectedImage = IdentifiableImage(image: image)
            }
        }
        // Upload Detail Sheet
        .sheet(item: $selectedImage) { item in
            UploadDetailScreen(image: item.image)
        }
    }
    
    // MARK: - Helper Methods
    private func openPhotoLibrary() {
        sourceType = .photoLibrary
        showingImagePicker = true
    }
    
    private func openCamera() {
        // Check if camera is available
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            return
        }
        sourceType = .camera
        showingImagePicker = true
    }
}

struct UploadScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
