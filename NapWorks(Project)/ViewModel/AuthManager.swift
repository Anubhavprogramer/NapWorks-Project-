import Foundation
import FirebaseAuth
import SwiftUI

class AuthManager: ObservableObject {
    
    static let shared = AuthManager()
    private init() {
        // Check if user is already logged in
        self.currentUser = Auth.auth().currentUser
        self.isAuthenticated = Auth.auth().currentUser != nil
    }
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    // MARK: - Authentication State Management
    
    func checkAuthenticationState() {
        DispatchQueue.main.async {
            self.currentUser = Auth.auth().currentUser
            self.isAuthenticated = Auth.auth().currentUser != nil
        }
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = ""
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self?.currentUser = result?.user
                    self?.isAuthenticated = true
                    print("✅ User signed up successfully: \(result?.user.email ?? "")")
                    completion(true)
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = ""
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self?.currentUser = result?.user
                    self?.isAuthenticated = true
                    print("✅ User signed in successfully: \(result?.user.email ?? "")")
                    completion(true)
                }
            }
        }
    }
    
    func signOut(completion: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isAuthenticated = false
                self.errorMessage = ""
                print("✅ User signed out successfully")
                completion(true)
            }
        } catch {
            print("❌ Error signing out: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                completion(false)
            }
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    var userEmail: String {
        return currentUser?.email ?? ""
    }
    
    var userId: String {
        return currentUser?.uid ?? ""
    }
}
