import Foundation
import FirebaseStorage
import FirebaseFirestore
import UIKit

class FirebaseManager {

    static let shared = FirebaseManager()
    private init() {}

    let storage = Storage.storage()
    let firestore = Firestore.firestore()

    func uploadImage(image: UIImage, imageName: String, completion: @escaping (Result<(String, String), Error>) -> Void) {

        let storagePath = "images/\(imageName).jpg"
        let storageRef = storage.reference().child(storagePath)

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
                    completion(.success((url.absoluteString, storagePath)))
                }
            }
        }
    }

    func saveImageMetadata(name: String, url: String, storagePath: String, completion: @escaping (Error?) -> Void) {
        firestore.collection("images").addDocument(data: [
            "name": name,
            "url": url,
            "storagePath": storagePath,
            "timestamp": Timestamp()
        ], completion: completion)
    }
    
    func fetchAllImages(completion: @escaping ([UploadedImage]) -> Void) {
        print("🔍 Fetching images from Firestore...")
        firestore.collection("images").order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            var images: [UploadedImage] = []
            
            if let error = error {
                print("❌ Error fetching images: \(error)")
                completion([])
                return
            }
            
            if let documents = snapshot?.documents {
                print("📄 Found \(documents.count) documents in Firestore")
                for doc in documents {
                    let data = doc.data()
                    if let name = data["name"] as? String,
                       let url = data["url"] as? String {
                        let storagePath = data["storagePath"] as? String ?? "images/\(name).jpg"
                        images.append(UploadedImage(id: doc.documentID, name: name, url: url, storagePath: storagePath))
                        print("✅ Added image: \(name)")
                    }
                }
            } else {
                print("📭 No documents found in collection")
            }
            
            print("🎯 Returning \(images.count) images")
            completion(images)
        }
    }
    
    func deleteImage(imageItem: UploadedImage, completion: @escaping (Error?) -> Void) {
        // First delete from Storage
        let storageRef = storage.reference().child(imageItem.storagePath)
        storageRef.delete { storageError in
            if let storageError = storageError {
                print("Error deleting from storage: \(storageError)")
                // Even if storage deletion fails, try to delete Firestore document
            }
            
            // Then delete Firestore document
            self.firestore.collection("images").document(imageItem.id).delete { firestoreError in
                if let firestoreError = firestoreError {
                    completion(firestoreError)
                } else if let storageError = storageError {
                    completion(storageError)
                } else {
                    completion(nil)
                }
            }
        }
    }

    
}
