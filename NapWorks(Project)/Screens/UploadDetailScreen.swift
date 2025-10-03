//
//  UploadDetailScreen.swift
//  NapWorks(Project)
//
//  Created by Anubhav Dubey on 03/10/25.
//
import SwiftUI

struct UploadDetailScreen: View {
    let image: UIImage
    @Environment(\.dismiss) var dismiss
    
    @State private var imageName: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
//                    .frame(maxWidth: .infinity)
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
                    Text("Submit")
                        .fontWeight(.bold)
                        .frame(width: 100, height: 50)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                
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
        print("Uploading \(imageName)...")
        dismiss()
    }
}
