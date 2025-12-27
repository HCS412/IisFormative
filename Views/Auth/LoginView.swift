//
//  LoginView.swift
//  FormativeiOS
//
//  Login View with Design System
//

import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var showRegister = false
    @State private var showBiometric = false
    
    var body: some View {
        ZStack {
            // Liquid blob background
            LiquidBlobBackground()
                .ignoresSafeArea()
            
            ScrollView {
                    VStack(spacing: .spacing5XL) {
                    Spacer(minLength: 60)
                    
                    // Logo/Header
                    VStack(spacing: .spacingM) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 60))
                            .foregroundStyle(LinearGradient.brand)
                            .symbolEffect(.bounce, value: showBiometric)
                        
                        Text("Welcome to Formative")
                            .font(.display)
                            .fontWeight(.bold)
                            .foregroundColor(.adaptiveTextPrimary())
                        
                        Text("Sign in to continue")
                            .font(.callout)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.top, .spacing5XL)
                    
                    // Glass card with form
                    GlassCard {
                        VStack(spacing: .spacingXL) {
                            FormTextField(
                                title: "Email",
                                text: $email,
                                placeholder: "Enter your email",
                                icon: "envelope.fill",
                                keyboardType: .emailAddress
                            )
                            
                            FormTextField(
                                title: "Password",
                                text: $password,
                                placeholder: "Enter your password",
                                icon: "lock.fill",
                                isSecure: true
                            )
                            
                            Toggle("Remember Me", isOn: $rememberMe)
                                .toggleStyle(.switch)
                                .tint(.brandPrimary)
                            
                            if let errorMessage = authViewModel.errorMessage {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.error)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            PrimaryButton(
                                title: "Sign In",
                                action: {
                                    Task {
                                        await authViewModel.login(
                                            email: email,
                                            password: password,
                                            rememberMe: rememberMe
                                        )
                                    }
                                },
                                isLoading: authViewModel.isLoading
                            )
                            .disabled(email.isEmpty || password.isEmpty)
                            
                            // Biometric login
                            if showBiometric {
                                Button(action: authenticateWithBiometrics) {
                                    HStack {
                                        Image(systemName: "faceid")
                                        Text("Sign in with Face ID")
                                    }
                                    .font(.subhead)
                                    .foregroundColor(.brandPrimary)
                                }
                                .padding(.top, .spacingS)
                            }
                            
                            Divider()
                                .padding(.vertical, .spacingM)
                            
                            // Social login (placeholder)
                            VStack(spacing: .spacingM) {
                                Button(action: {}) {
                                    HStack {
                                        Image(systemName: "apple.logo")
                                        Text("Continue with Apple")
                                    }
                                    .font(.subhead)
                                    .fontWeight(.medium)
                                    .foregroundColor(.adaptiveTextPrimary())
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.adaptiveSurface())
                                    .cornerRadius(.radiusSmall)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: .radiusSmall)
                                            .stroke(Color.separator, lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, .spacingL)
                    
                    // Register link
                    HStack {
                        Text("Don't have an account?")
                            .font(.subhead)
                            .foregroundColor(.textSecondary)
                        Button("Register") {
                            Haptics.selection()
                            showRegister = true
                        }
                        .font(.subhead)
                        .fontWeight(.semibold)
                        .foregroundColor(.brandPrimary)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
        }
        .onAppear {
            checkBiometricAvailability()
        }
    }
    
    private func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // Check if we have a saved token (user has logged in before)
            if KeychainService.shared.getToken() != nil {
                showBiometric = true
            }
        }
    }
    
    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return
        }
        
        let reason = "Sign in to your Formative account"
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    // Biometric auth successful, verify token is still valid
                    Task {
                        await authViewModel.loadProfile()
                    }
                }
            }
        }
    }
}

// MARK: - Liquid Blob Background
struct LiquidBlobBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Animated gradient blobs
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.brandPrimary.opacity(0.3),
                            Color.brandSecondary.opacity(0.2)
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: animate ? -100 : 100, y: animate ? -150 : -100)
                .blur(radius: 60)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.brandSecondary.opacity(0.3),
                            Color.brandPrimary.opacity(0.2)
                        ],
                        center: .bottomTrailing,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .frame(width: 500, height: 500)
                .offset(x: animate ? 150 : -150, y: animate ? 200 : 150)
                .blur(radius: 80)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}

