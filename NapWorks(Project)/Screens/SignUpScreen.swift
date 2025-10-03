import SwiftUI

struct SignUpScreen: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authManager = AuthManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                
                Spacer()
                
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Join NapWorks Gallery today")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
                
                // Sign Up Form
                VStack(spacing: 20) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        SecureField("Create a password", text: $password)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    // Confirm Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        SecureField("Confirm your password", text: $confirmPassword)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    // Password Requirements
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Password Requirements:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("• At least 6 characters")
                            .font(.caption2)
                            .foregroundColor(password.count >= 6 ? .green : .secondary)
                        Text("• Passwords must match")
                            .font(.caption2)
                            .foregroundColor(password == confirmPassword && !password.isEmpty ? .green : .secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                
                // Sign Up Button
                Button(action: {
                    signUpUser()
                }) {
                    HStack {
                        if authManager.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        } else {
                            Text("Create Account")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isFormValid ? Color.green : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .disabled(!isFormValid || authManager.isLoading)
                .padding(.horizontal, 20)
                
                // Back to Login
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.secondary)
                    Button("Sign In") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                }
                
                Spacer()
                
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(authManager.errorMessage)
        }
        .onChange(of: authManager.errorMessage) { _, errorMessage in
            if !errorMessage.isEmpty {
                showAlert = true
            }
        }
        .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                dismiss()
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        !confirmPassword.isEmpty &&
        email.contains("@") &&
        password.count >= 6 &&
        password == confirmPassword
    }
    
    private func signUpUser() {
        authManager.signUp(email: email, password: password) { success in
            if success {
                // Success is handled by the onChange modifier
            }
        }
    }
}

#Preview {
    SignUpScreen()
}
