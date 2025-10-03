import SwiftUI

struct ForgotPasswordScreen: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authManager = AuthManager.shared
    @State private var email = ""
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                
                Spacer()
                
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "envelope.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Reset Password")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Enter your email to receive reset instructions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
                
                // Email Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                    }
                }
                .padding(.horizontal, 20)
                
                // Reset Password Button
                Button(action: {
                    resetPassword()
                }) {
                    HStack {
                        if authManager.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        } else {
                            Text("Send Reset Link")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isEmailValid ? Color.green : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .disabled(!isEmailValid || authManager.isLoading)
                .padding(.horizontal, 20)
                
                // Back to Login
                Button("Back to Login") {
                    dismiss()
                }
                .fontWeight(.semibold)
                .foregroundColor(.green)
                
                Spacer()
                
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK") {
                if alertTitle == "Success" {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var isEmailValid: Bool {
        !email.isEmpty && email.contains("@") && email.contains(".")
    }
    
    private func resetPassword() {
        authManager.resetPassword(email: email) { success in
            if success {
                alertTitle = "Success"
                alertMessage = "Password reset email sent! Check your inbox and follow the instructions to reset your password."
            } else {
                alertTitle = "Error"
                alertMessage = authManager.errorMessage
            }
            showAlert = true
        }
    }
}

#Preview {
    ForgotPasswordScreen()
}
