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
    @State private var selectedUIImage: UIImage? = nil   // Store real UIImage
    @State private var showDetailScreen = false  // Controls modal
    @State private var selectedImage: IdentifiableImage? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Image or Placeholder
           
            Button(action: {
                sourceType = .photoLibrary
                showingImagePicker = true
            }) {
                VStack(spacing: 10) {
                    Image(systemName: "photo")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    Text("Select an image")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .frame(width: 340, height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                        .foregroundColor(.green)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            
            // Divider with OR
            HStack {
                Divider().frame(height: 1).background(Color.black)
                Text("OR").font(.body).foregroundColor(.gray).padding(.horizontal, 8)
                Divider().frame(height: 1).background(Color.black)
            }
            .padding(.vertical, 10)

            // Button to open the Gallery directly
            Button(action: {
                sourceType = .photoLibrary
                showingImagePicker = true
            }) {
                HStack {
                    Image(systemName: "camera.fill")
                        .foregroundColor(.green)
                    Text("Browse Gallery")
                        .foregroundColor(.green)
                }
            }
            .frame(width: 340, height: 50)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                    .foregroundColor(.green)
            )
        }
        .padding()
        // First sheet: Image Picker
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: sourceType) { image in
                self.selectedImage = IdentifiableImage(image: image)
            }

        }
        // Second sheet: Detail screen
        .sheet(item: $selectedImage) { item in
            UploadDetailScreen(image: item.image)
        }
    }
}

struct UploadScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
