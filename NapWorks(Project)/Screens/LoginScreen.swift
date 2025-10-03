import SwiftUI

struct LoginScreen: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showForgotPassword = false
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                
                Spacer()
                
                // App Logo and Title
                VStack(spacing: 16) {
                    Image(systemName: "photo.stack.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text("NapWorks Gallery")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Your personal photo collection")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
                
                // Login Form
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
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    // Forgot Password
                    HStack {
                        Spacer()
                        Button("Forgot Password?") {
                            showForgotPassword = true
                        }
                        .font(.footnote)
                        .foregroundColor(.green)
                    }
                }
                .padding(.horizontal, 20)
                
                // Login Button
                Button(action: {
                    loginUser()
                }) {
                    HStack {
                        if authManager.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        } else {
                            Text("Sign In")
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
                
                // Sign Up Link
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    Button("Sign Up") {
                        showSignUp = true
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                }
                
                Spacer()
                
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showSignUp) {
            SignUpScreen()
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordScreen()
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
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
    
    private func loginUser() {
        authManager.signIn(email: email, password: password) { success in
            if !success {
                // Error handling is done through the error message and alert
            }
        }
    }
}

#Preview {
    LoginScreen()
}
