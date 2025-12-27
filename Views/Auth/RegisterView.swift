//
//  RegisterView.swift
//  FormativeiOS
//
//  Registration View with Design System
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var passwordStrength: Double = 0
    
    private var passwordsMatch: Bool {
        password == confirmPassword && !password.isEmpty
    }
    
    private var isFormValid: Bool {
        !email.isEmpty &&
        email.isValidEmail &&
        !password.isEmpty &&
        passwordsMatch &&
        password.count >= 8
    }
    
    var body: some View {
        ZStack {
            LiquidBlobBackground()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: .spacing2XL) {
                    Spacer(minLength: 40)
                    
                    // Header
                    VStack(spacing: .spacingM) {
                        Text("Create Account")
                            .font(.display)
                            .fontWeight(.bold)
                            .foregroundColor(.adaptiveTextPrimary())
                        
                        Text("Join the Formative community")
                            .font(.callout)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.top, .spacing5XL)
                    
                    // Form
                    GlassCard {
                        VStack(spacing: .spacingXL) {
                            FormTextField(
                                title: "Email",
                                text: $email,
                                placeholder: "Enter your email",
                                icon: "envelope.fill",
                                keyboardType: .emailAddress,
                                errorMessage: email.isEmpty ? nil : (email.isValidEmail ? nil : "Please enter a valid email")
                            )
                            
                            VStack(alignment: .leading, spacing: .spacingS) {
                                FormTextField(
                                    title: "Password",
                                    text: $password,
                                    placeholder: "Enter your password",
                                    icon: "lock.fill",
                                    isSecure: true
                                )
                                
                                // Password strength indicator
                                if !password.isEmpty {
                                    VStack(alignment: .leading, spacing: 4) {
                                        GeometryReader { geometry in
                                            ZStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 2)
                                                    .fill(Color.gray.opacity(0.2))
                                                    .frame(height: 4)
                                                
                                                RoundedRectangle(cornerRadius: 2)
                                                    .fill(
                                                        LinearGradient(
                                                            colors: passwordStrength < 0.5 ? [.error] : passwordStrength < 0.75 ? [.warning] : [.success],
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        )
                                                    )
                                                    .frame(width: geometry.size.width * passwordStrength, height: 4)
                                                    .animation(.springSmooth, value: passwordStrength)
                                            }
                                        }
                                        .frame(height: 4)
                                        
                                        Text(passwordStrengthText)
                                            .font(.caption)
                                            .foregroundColor(passwordStrengthColor)
                                    }
                                }
                                
                                if !password.isEmpty && password.count < 8 {
                                    Text("Password must be at least 8 characters")
                                        .font(.caption)
                                        .foregroundColor(.error)
                                }
                            }
                            
                            FormTextField(
                                title: "Confirm Password",
                                text: $confirmPassword,
                                placeholder: "Confirm your password",
                                icon: "lock.fill",
                                isSecure: true,
                                errorMessage: confirmPassword.isEmpty ? nil : (passwordsMatch ? nil : "Passwords do not match")
                            )
                            
                            Divider()
                                .padding(.vertical, .spacingS)
                            
                            Text("Profile Information (Optional)")
                                .font(.subhead)
                                .fontWeight(.semibold)
                                .foregroundColor(.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            FormTextField(
                                title: "Username",
                                text: $username,
                                placeholder: "Choose a username",
                                icon: "person.fill"
                            )
                            
                            FormTextField(
                                title: "First Name",
                                text: $firstName,
                                placeholder: "Enter your first name",
                                icon: "person.fill"
                            )
                            
                            FormTextField(
                                title: "Last Name",
                                text: $lastName,
                                placeholder: "Enter your last name",
                                icon: "person.fill"
                            )
                            
                            if let errorMessage = authViewModel.errorMessage {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.error)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            PrimaryButton(
                                title: "Create Account",
                                action: {
                                    Task {
                                        await authViewModel.register(
                                            email: email,
                                            password: password,
                                            username: username.isEmpty ? nil : username,
                                            firstName: firstName.isEmpty ? nil : firstName,
                                            lastName: lastName.isEmpty ? nil : lastName
                                        )
                                    }
                                },
                                isLoading: authViewModel.isLoading
                            )
                            .disabled(!isFormValid)
                        }
                    }
                    .padding(.horizontal, .spacingL)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    Haptics.selection()
                    dismiss()
                }
            }
        }
        .onChange(of: password) { _, newValue in
            calculatePasswordStrength(newValue)
        }
    }
    
    private var passwordStrengthText: String {
        if passwordStrength < 0.3 {
            return "Weak"
        } else if passwordStrength < 0.7 {
            return "Medium"
        } else {
            return "Strong"
        }
    }
    
    private var passwordStrengthColor: Color {
        if passwordStrength < 0.3 {
            return .error
        } else if passwordStrength < 0.7 {
            return .warning
        } else {
            return .success
        }
    }
    
    private func calculatePasswordStrength(_ password: String) {
        var strength: Double = 0
        
        // Length factor
        if password.count >= 8 {
            strength += 0.2
        }
        if password.count >= 12 {
            strength += 0.1
        }
        
        // Character variety
        if password.rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil {
            strength += 0.15
        }
        if password.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil {
            strength += 0.15
        }
        if password.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
            strength += 0.15
        }
        if password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")) != nil {
            strength += 0.15
        }
        
        withAnimation(.springSmooth) {
            passwordStrength = min(strength, 1.0)
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthViewModel())
}

