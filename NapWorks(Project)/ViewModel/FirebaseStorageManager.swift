import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import UIKit

class FirebaseManager: ObservableObject {

    static let shared = FirebaseManager()
    private init() {}

    let storage = Storage.storage()
    let firestore = Firestore.firestore()
    
    // Real-time listener for images
    private var imagesListener: ListenerRegistration?
    @Published var images: [UploadedImage] = []
    @Published var isLoading: Bool = true

    func uploadImage(image: UIImage, imageName: String, completion: @escaping (Result<(String, String), Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        print("📤 Starting upload for: \(imageName) for user: \(userId)")
        
        let storagePath = "users/\(userId)/images/\(imageName).jpg"
        let storageRef = storage.reference().child(storagePath)

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageConversion", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])))
            return
        }

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        storageRef.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                print("❌ Upload failed: \(error)")
                completion(.failure(error))
                return
            }
            
            print("✅ File uploaded successfully, getting download URL...")

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("❌ Failed to get download URL: \(error)")
                    completion(.failure(error))
                } else if let url = url {
                    print("🔗 Download URL obtained: \(url.absoluteString)")
                    // Complete immediately - Firebase URLs are always valid
                    completion(.success((url.absoluteString, storagePath)))
                }
            }
        }
    }

    func saveImageMetadata(name: String, url: String, storagePath: String, completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        firestore.collection("images").addDocument(data: [
            "name": name,
            "url": url,
            "storagePath": storagePath,
            "userId": userId,
            "timestamp": Timestamp()
        ], completion: completion)
    }
    
    // MARK: - Real-time Image Listening (like messaging apps)
    func startListeningToImages() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ Cannot start listening - user not authenticated")
            DispatchQueue.main.async {
                self.images = []
                self.isLoading = false
            }
            return
        }
        
        // Stop existing listener if any
        if imagesListener != nil {
            stopListeningToImages()
        }
        
        print("🎧 Starting real-time listener for images for user: \(userId)")
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        imagesListener = firestore.collection("images")
            .whereField("userId", isEqualTo: userId)
            // Temporarily remove ordering to avoid index requirement
            // .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Real-time listener error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                    return
                }
                
                guard let snapshot = snapshot else {
                    DispatchQueue.main.async {
                        self.images = []
                        self.isLoading = false
                    }
                    return
                }
                
                var newImages: [UploadedImage] = []
                
                for doc in snapshot.documents {
                    let data = doc.data()
                    
                    if let name = data["name"] as? String,
                       let url = data["url"] as? String {
                        let storagePath = data["storagePath"] as? String ?? "users/\(userId)/images/\(name).jpg"
                        let imageItem = UploadedImage(id: doc.documentID, name: name, url: url, storagePath: storagePath)
                        newImages.append(imageItem)
                    }
                }
                
                // Sort by name on client side (you can change this to any sorting you prefer)
                newImages.sort { $0.name < $1.name }
                
                DispatchQueue.main.async {
                    print("🔄 Loaded \(newImages.count) images")
                    self.images = newImages
                    self.isLoading = false
                }
            }
    }
    
    func stopListeningToImages() {
        imagesListener?.remove()
        imagesListener = nil
    }
    
    // MARK: - Legacy fetch method (for fallback if needed)
    func fetchAllImages(completion: @escaping ([UploadedImage]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ Cannot fetch images - user not authenticated")
            completion([])
            return
        }
        
        print("🔍 Fetching images from Firestore for user: \(userId)...")
        firestore.collection("images")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                var images: [UploadedImage] = []
                
                if let error = error {
                    print("❌ Error fetching images: \(error)")
                    completion([])
                    return
                }
                
                if let documents = snapshot?.documents {
                    print("📄 Found \(documents.count) documents in Firestore for user")
                    for doc in documents {
                        let data = doc.data()
                        if let name = data["name"] as? String,
                           let url = data["url"] as? String {
                            let storagePath = data["storagePath"] as? String ?? "users/\(userId)/images/\(name).jpg"
                            images.append(UploadedImage(id: doc.documentID, name: name, url: url, storagePath: storagePath))
                            print("✅ Added image: \(name)")
                        }
                    }
                } else {
                    print("📭 No documents found in collection for user")
                }
                
                print("🎯 Returning \(images.count) images for user")
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

    // MARK: - Cleanup
    deinit {
        stopListeningToImages()
    }
    
}
