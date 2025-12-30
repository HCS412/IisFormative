//
//  LoginView.swift
//  FormativeiOS
//
//  Login View with Design System
//

import SwiftUI
import LocalAuthentication
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var showRegister = false
    @State private var showBiometric = false
    @State private var isAppleSignInLoading = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Liquid blob background
            LiquidBlobBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: .spacing2XL) {
                    // Logo/Header
                    VStack(spacing: .spacingM) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 50))
                            .foregroundStyle(LinearGradient.brand)
                            .symbolEffect(.bounce, value: showBiometric)

                        Text("Welcome to Formative")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.adaptiveTextPrimary())

                        Text("Sign in to continue")
                            .font(.callout)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.top, .spacing2XL)
                    .frame(maxWidth: .infinity)

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
                                            password: password
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

                            // NOTE: Sign in with Apple requires a paid Apple Developer Program membership
                            // Uncomment the code below once enrolled in the program and entitlements are configured
                            /*
                            Divider()
                                .padding(.vertical, .spacingM)

                            // Sign in with Apple
                            VStack(spacing: .spacingM) {
                                if isAppleSignInLoading {
                                    ProgressView()
                                        .frame(height: 50)
                                } else {
                                    SignInWithAppleButton(
                                        onRequest: { request in
                                            request.requestedScopes = [.fullName, .email]
                                        },
                                        onCompletion: { result in
                                            handleAppleSignIn(result: result)
                                        }
                                    )
                                    .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                                    .frame(height: 50)
                                    .cornerRadius(.radiusSmall)
                                }
                            }
                            */
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

                    // Legal links
                    LegalLinksView()
                        .padding(.top, .spacingM)
                        .padding(.bottom, .spacingL)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
        }
        .sheet(isPresented: $authViewModel.requires2FA) {
            TwoFactorView()
        }
        .onAppear {
            checkBiometricAvailability()
        }
    }

    private func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
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
                    Task {
                        await authViewModel.loadProfile()
                    }
                }
            }
        }
    }

    private func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                return
            }

            // Get user info
            let userIdentifier = appleIDCredential.user
            let email = appleIDCredential.email
            let fullName = appleIDCredential.fullName

            // Get identity token
            guard let identityTokenData = appleIDCredential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8) else {
                authViewModel.errorMessage = "Failed to get Apple ID token"
                return
            }

            // Build name from components
            var name: String? = nil
            if let givenName = fullName?.givenName, let familyName = fullName?.familyName {
                name = "\(givenName) \(familyName)"
            } else if let givenName = fullName?.givenName {
                name = givenName
            }

            isAppleSignInLoading = true

            Task {
                await authViewModel.signInWithApple(
                    identityToken: identityToken,
                    userIdentifier: userIdentifier,
                    email: email,
                    name: name
                )
                isAppleSignInLoading = false
            }

        case .failure(let error):
            // User cancelled or other error
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                authViewModel.errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Two Factor Authentication View
struct TwoFactorView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var code = ""
    @FocusState private var isCodeFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color.adaptiveBackground()
                    .ignoresSafeArea()

                VStack(spacing: .spacing2XL) {
                    // Icon
                    Image(systemName: "lock.shield")
                        .font(.system(size: 60))
                        .foregroundStyle(LinearGradient.brand)

                    // Title
                    VStack(spacing: .spacingS) {
                        Text("Two-Factor Authentication")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.adaptiveTextPrimary())

                        Text("Enter the 6-digit code from your authenticator app")
                            .font(.subhead)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    // Code input
                    TextField("000000", text: $code)
                        .keyboardType(.numberPad)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 200)
                        .padding(.spacingL)
                        .background(Color.adaptiveSurface())
                        .cornerRadius(.radiusMedium)
                        .focused($isCodeFocused)
                        .onChange(of: code) { _, newValue in
                            // Limit to 6 digits
                            if newValue.count > 6 {
                                code = String(newValue.prefix(6))
                            }
                            // Auto-submit when 6 digits entered
                            if newValue.count == 6 {
                                Task {
                                    await authViewModel.verify2FA(code: newValue)
                                }
                            }
                        }

                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.error)
                    }

                    PrimaryButton(
                        title: "Verify",
                        action: {
                            Task {
                                await authViewModel.verify2FA(code: code)
                            }
                        },
                        isLoading: authViewModel.isLoading
                    )
                    .disabled(code.count != 6)
                    .padding(.horizontal, .spacingL)

                    Spacer()
                }
                .padding(.top, .spacing3XL)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        authViewModel.cancel2FA()
                    }
                }
            }
            .onAppear {
                isCodeFocused = true
            }
        }
    }
}

// MARK: - Liquid Blob Background
struct LiquidBlobBackground: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
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
                    .frame(width: 300, height: 300)
                    .position(x: animate ? geometry.size.width * 0.2 : geometry.size.width * 0.8,
                              y: animate ? geometry.size.height * 0.1 : geometry.size.height * 0.2)
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
                    .frame(width: 350, height: 350)
                    .position(x: animate ? geometry.size.width * 0.8 : geometry.size.width * 0.2,
                              y: animate ? geometry.size.height * 0.7 : geometry.size.height * 0.8)
                    .blur(radius: 80)
            }
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
