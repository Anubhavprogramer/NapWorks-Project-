//
//  FirebaseStorageManager.swift
//  NapWorks(Project)
//
//  Created by Anubhav Dubey on 03/10/25.
//
import FirebaseStorage
import UIKit
import FirebaseCore
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func uploadImage(_ image: UIImage, name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "Image conversion failed", code: -1)))
            return
        }
        
        let storageRef = storage.reference().child("images/\(name).jpg")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    let imageData = ImageData(name: name, url: url.absoluteString, timestamp: Date())
                    
                    // Save to Firestore
                    self.db.collection("images").addDocument(data: [
                        "name": imageData.name,
                        "url": imageData.url,
                        "timestamp": imageData.timestamp
                    ]) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
            }
        }
    }
    
    func fetchImages(completion: @escaping (Result<[ImageData], Error>) -> Void) {
        db.collection("images").order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let images = snapshot?.documents.compactMap { doc -> ImageData? in
                    let data = doc.data()
                    guard let name = data["name"] as? String,
                          let url = data["url"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp else { return nil }
                    return ImageData(name: name, url: url, timestamp: timestamp.dateValue())
                } ?? []
                completion(.success(images))
            }
        }
    }
}
