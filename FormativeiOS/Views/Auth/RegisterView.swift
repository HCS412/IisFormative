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

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedUserType: UserType = .creator
    @State private var passwordStrength: Double = 0

    private var passwordsMatch: Bool {
        password == confirmPassword && !password.isEmpty
    }

    private var hasUppercase: Bool {
        password.rangeOfCharacter(from: .uppercaseLetters) != nil
    }

    private var hasSpecialCharacter: Bool {
        password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")) != nil
    }

    private var passwordMeetsRequirements: Bool {
        password.count >= 8 && hasUppercase && hasSpecialCharacter
    }

    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        email.isValidEmail &&
        !password.isEmpty &&
        passwordsMatch &&
        passwordMeetsRequirements
    }

    var body: some View {
        ZStack {
            LiquidBlobBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: .spacingXL) {
                    // Header
                    VStack(spacing: .spacingM) {
                        Text("Create Account")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.adaptiveTextPrimary())

                        Text("Join the Formative community")
                            .font(.callout)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.top, .spacingL)

                    // Form
                    GlassCard {
                        VStack(spacing: .spacingXL) {
                            FormTextField(
                                title: "Full Name",
                                text: $name,
                                placeholder: "Enter your name",
                                icon: "person.fill"
                            )

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

                                if !password.isEmpty {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 4) {
                                            Image(systemName: password.count >= 8 ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(password.count >= 8 ? .success : .textSecondary)
                                            Text("At least 8 characters")
                                        }
                                        HStack(spacing: 4) {
                                            Image(systemName: hasUppercase ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(hasUppercase ? .success : .textSecondary)
                                            Text("One uppercase letter")
                                        }
                                        HStack(spacing: 4) {
                                            Image(systemName: hasSpecialCharacter ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(hasSpecialCharacter ? .success : .textSecondary)
                                            Text("One special character (!@#$%...)")
                                        }
                                    }
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
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

                            // User Type Selection
                            VStack(alignment: .leading, spacing: .spacingM) {
                                Text("I am a...")
                                    .font(.subhead)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.adaptiveTextPrimary())

                                HStack(spacing: .spacingM) {
                                    ForEach(UserType.allCases, id: \.self) { userType in
                                        UserTypeButton(
                                            userType: userType,
                                            isSelected: selectedUserType == userType,
                                            action: {
                                                withAnimation(.springSmooth) {
                                                    selectedUserType = userType
                                                }
                                                Haptics.selection()
                                            }
                                        )
                                    }
                                }
                            }

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
                                            name: name,
                                            email: email,
                                            password: password,
                                            userType: selectedUserType
                                        )
                                    }
                                },
                                isLoading: authViewModel.isLoading
                            )
                            .disabled(!isFormValid)
                        }
                    }
                    .padding(.horizontal, .spacingL)
                    .padding(.bottom, .spacingL)
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

// MARK: - User Type Button
struct UserTypeButton: View {
    let userType: UserType
    let isSelected: Bool
    let action: () -> Void

    private var icon: String {
        switch userType {
        case .creator: return "person.crop.circle"
        case .brand: return "building.2"
        case .agency: return "person.3"
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: .spacingS) {
                Image(systemName: icon)
                    .font(.title2)

                Text(userType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.spacingM)
            .background(
                RoundedRectangle(cornerRadius: .radiusMedium)
                    .fill(isSelected ? Color.brandPrimary.opacity(0.15) : Color.adaptiveSurface())
            )
            .overlay(
                RoundedRectangle(cornerRadius: .radiusMedium)
                    .stroke(isSelected ? Color.brandPrimary : Color.clear, lineWidth: 2)
            )
            .foregroundColor(isSelected ? .brandPrimary : .textSecondary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthViewModel())
}
