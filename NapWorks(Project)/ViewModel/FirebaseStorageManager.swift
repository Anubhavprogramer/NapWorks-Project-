import Foundation
import FirebaseStorage
import FirebaseFirestore
import UIKit

class FirebaseManager {

    static let shared = FirebaseManager()
    private init() {}

    let storage = Storage.storage()
    let firestore = Firestore.firestore()

    func uploadImage(image: UIImage, imageName: String, completion: @escaping (Result<String, Error>) -> Void) {

        let storageRef = storage.reference().child("images/\(imageName).jpg")

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageConversion", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])))
            return
        }

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        storageRef.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url.absoluteString))
                }
            }
        }
    }

    func saveImageMetadata(name: String, url: String, completion: @escaping (Error?) -> Void) {
        firestore.collection("images").addDocument(data: [
            "name": name,
            "url": url,
            "timestamp": Timestamp()
        ], completion: completion)
    }
    
    func fetchAllImages(completion: @escaping ([UploadedImage]) -> Void) {
        firestore.collection("images").order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            var images: [UploadedImage] = []
            if let documents = snapshot?.documents {
                for doc in documents {
                    let data = doc.data()
                    if let name = data["name"] as? String,
                       let url = data["url"] as? String {
                        images.append(UploadedImage(id: doc.documentID, name: name, url: url))
                    }
                }
            }
            completion(images)
        }
    }
    
    func deleteImage(imageId: String, completion: @escaping (Error?) -> Void) {
        // Delete Firestore document
        firestore.collection("images").document(imageId).delete { error in
            if let error = error {
                completion(error)
                return
            }
            
            // Optionally delete from Storage
            let storageRef = self.storage.reference().child("images/\(imageId).jpg")
            storageRef.delete { error in
                completion(error)
            }
        }
    }

    
}
