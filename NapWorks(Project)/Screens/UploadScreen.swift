//
//  Upload.swift
//  NapWorks(Project)
//
//  Created by Anubhav Dubey on 03/10/25.
//

import Foundation
import SwiftUICore
import SwiftUI

struct UploadScreen: View {
    
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: Image? = nil
    
    var body: some View {
        VStack(spacing: 20) {
                    if selectedImage != nil {
                        selectedImage?
                            .resizable()
                            .scaledToFit()
                            .frame(width: 500, height: 400)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    } else {
                        Text("Select an image")
                            .padding()
                            .frame(width: 340, height: 200)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                                    .foregroundColor(.blue)
                            )

                    }

                    Button(action: {
                        self.sourceType = .photoLibrary
                        self.showingImagePicker = true
                    }) {
                        Text("Browser Gallery")
                    }

                    Button(action: {
                        self.sourceType = .camera
                        self.showingImagePicker = true
                    }) {
                        Text("Open camera")
                    }
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(sourceType: self.sourceType) { image in
                        self.selectedImage = Image(uiImage: image)
                    }
                }
    }
}

