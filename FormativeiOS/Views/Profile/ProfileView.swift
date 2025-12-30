//
//  ProfileView.swift
//  FormativeiOS
//
//  Profile View
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showEditProfile = false
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .spacing2XL) {
                    // Profile Header
                    profileHeader
                        .padding(.horizontal, .spacingL)
                        .padding(.top, .spacingL)
                    
                    // Stats Row
                    if let user = authViewModel.currentUser {
                        statsRow
                            .padding(.horizontal, .spacingL)
                        
                        // Profile Info
                        profileInfo
                            .padding(.horizontal, .spacingL)
                    }
                    
                    // Actions
                    actionsSection
                        .padding(.horizontal, .spacingL)
                }
                .padding(.bottom, .spacing5XL)
            }
            .background(Color.adaptiveBackground())
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: .spacingM) {
            ZStack(alignment: .bottomTrailing) {
                // Avatar
                AsyncImage(url: URL(string: authViewModel.currentUser?.avatar ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(LinearGradient.brand)
                        .overlay(
                            Text(avatarInitials)
                                .font(.title1)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(LinearGradient.brand, lineWidth: 4)
                )
                
                // Edit Button
                Button(action: {
                    Haptics.selection()
                    showEditProfile = true
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .background(Circle().fill(LinearGradient.brand))
                }
                .offset(x: 8, y: 8)
            }
            
            VStack(spacing: .spacingS) {
                Text(displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.adaptiveTextPrimary())
                
                if let userType = authViewModel.currentUser?.userType {
                    Text(userType.capitalized)
                        .font(.subhead)
                        .foregroundColor(.textSecondary)
                }
            }
        }
    }
    
    private var displayName: String {
        guard let user = authViewModel.currentUser else { return "User" }
        return user.name
    }

    private var avatarInitials: String {
        guard let user = authViewModel.currentUser else { return "U" }
        let words = user.name.split(separator: " ")
        if words.count >= 2 {
            return String(words[0].prefix(1)) + String(words[1].prefix(1))
        }
        return String(user.name.prefix(1))
    }
    
    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: 0) {
            StatItem(label: "Applications", value: "24")
            Divider()
                .frame(height: 40)
            StatItem(label: "Campaigns", value: "3")
            Divider()
                .frame(height: 40)
            StatItem(label: "Earnings", value: "$12.5k")
        }
        .padding(.spacingL)
        .background(Color.adaptiveSurface())
        .cornerRadius(.radiusMedium)
    }
    
    // MARK: - Profile Info
    private var profileInfo: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: .spacingM) {
                if let email = authViewModel.currentUser?.email {
                    InfoRow(icon: "envelope.fill", text: email)
                }

                if let userType = authViewModel.currentUser?.userType {
                    InfoRow(icon: "person.fill", text: userType.capitalized)
                }

                if let bio = authViewModel.currentUser?.profileData?.bio {
                    InfoRow(icon: "text.quote", text: bio)
                }
            }
        }
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: .spacingM) {
            NavigationLink(destination: MediaKitView()) {
                ActionRow(icon: "photo.on.rectangle.angled", title: "Media Kit", color: .brandPrimary)
            }

            NavigationLink(destination: MyApplicationsView()) {
                ActionRow(icon: "briefcase.fill", title: "My Applications", color: .brandSecondary)
            }

            NavigationLink(destination: TeamsListView()) {
                ActionRow(icon: "person.2.fill", title: "My Teams", color: .warning)
            }

            NavigationLink(destination: ShopView()) {
                ActionRow(icon: "cart.fill", title: "Creator Shop", color: .success)
            }

            Divider()
                .padding(.vertical, .spacingS)

            Button(action: {
                Haptics.impact(.medium)
                authViewModel.logout()
            }) {
                ActionRow(icon: "arrow.right.square.fill", title: "Sign Out", color: .error)
            }
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.adaptiveTextPrimary())
            
            Text(label)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: .spacingM) {
            Image(systemName: icon)
                .foregroundColor(.brandPrimary)
                .frame(width: 20)
            
            Text(text)
                .font(.subhead)
                .foregroundColor(.adaptiveTextPrimary())
        }
    }
}

// MARK: - Action Row
struct ActionRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: .spacingM) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 32)
            
            Text(title)
                .font(.subhead)
                .foregroundColor(.adaptiveTextPrimary())
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .padding(.spacingM)
        .background(Color.adaptiveSurface())
        .cornerRadius(.radiusMedium)
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var website: String = ""
    @State private var location: String = ""
    @State private var calendlyUrl: String = ""
    @State private var isSaving = false
    @State private var showSuccessAlert = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Full Name", text: $name)
                        .textContentType(.name)

                    TextField("Location", text: $location)
                        .textContentType(.addressCity)
                }

                Section("About") {
                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Links") {
                    TextField("Website", text: $website)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }

                Section {
                    TextField("Calendly URL", text: $calendlyUrl)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                } header: {
                    Text("Scheduling")
                } footer: {
                    Text("Add your Calendly link to let others book meetings with you")
                }

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.error)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(isSaving || name.isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .overlay {
                if isSaving {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            .alert("Profile Updated", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your profile has been updated successfully.")
            }
            .onAppear {
                loadCurrentValues()
            }
        }
    }

    private func loadCurrentValues() {
        if let user = authViewModel.currentUser {
            name = user.name
            bio = user.profileData?.bio ?? ""
            website = user.profileData?.website ?? ""
            location = user.profileData?.location ?? ""
            calendlyUrl = user.profileData?.calendlyUrl ?? ""
        }
    }

    private func saveProfile() {
        isSaving = true
        errorMessage = nil

        Task {
            let success = await authViewModel.updateProfile(
                name: name.isEmpty ? nil : name,
                bio: bio.isEmpty ? nil : bio,
                website: website.isEmpty ? nil : website,
                location: location.isEmpty ? nil : location,
                calendlyUrl: calendlyUrl.isEmpty ? nil : calendlyUrl
            )

            isSaving = false

            if success {
                Haptics.notification(.success)
                showSuccessAlert = true
            } else {
                Haptics.notification(.error)
                errorMessage = authViewModel.errorMessage ?? "Failed to update profile"
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showDeleteConfirmation = false
    @State private var showDeleteFinalConfirmation = false
    @State private var isDeleting = false
    @State private var pushNotifications = true
    @State private var emailNotifications = true

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    NavigationLink {
                        EmailSettingsView()
                    } label: {
                        SettingsRow(icon: "envelope.fill", title: "Email", value: authViewModel.currentUser?.email ?? "")
                    }

                    NavigationLink {
                        PasswordSettingsView()
                    } label: {
                        SettingsRow(icon: "lock.fill", title: "Password", value: "••••••••")
                    }

                    NavigationLink {
                        TwoFactorSettingsView()
                    } label: {
                        SettingsRow(icon: "shield.fill", title: "Two-Factor Authentication", value: "Off")
                    }
                }

                Section("Integrations") {
                    NavigationLink {
                        CalendlySettingsView()
                    } label: {
                        SettingsRow(
                            icon: "calendar.badge.plus",
                            title: "Calendly",
                            value: authViewModel.currentUser?.profileData?.calendlyUrl != nil ? "Connected" : "Not Set"
                        )
                    }
                }

                Section("Notifications") {
                    Toggle(isOn: $pushNotifications) {
                        Label("Push Notifications", systemImage: "bell.fill")
                    }
                    Toggle(isOn: $emailNotifications) {
                        Label("Email Notifications", systemImage: "envelope.badge.fill")
                    }
                }

                Section("Privacy") {
                    NavigationLink {
                        PrivacySettingsView()
                    } label: {
                        SettingsRow(icon: "hand.raised.fill", title: "Privacy Settings", value: "")
                    }

                    NavigationLink {
                        DataExportView()
                    } label: {
                        SettingsRow(icon: "square.and.arrow.up.fill", title: "Export Data", value: "")
                    }
                }

                Section("Legal") {
                    NavigationLink {
                        TermsOfServiceView()
                    } label: {
                        SettingsRow(icon: "doc.text.fill", title: "Terms of Service", value: "")
                    }

                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        SettingsRow(icon: "lock.doc.fill", title: "Privacy Policy", value: "")
                    }

                    NavigationLink {
                        CommunityGuidelinesView()
                    } label: {
                        SettingsRow(icon: "person.2.fill", title: "Community Guidelines", value: "")
                    }

                    HStack {
                        Label("Version", systemImage: "info.circle.fill")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.textSecondary)
                    }
                }

                Section {
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        HStack {
                            Spacer()
                            if isDeleting {
                                ProgressView()
                                    .tint(.error)
                            } else {
                                Label("Delete Account", systemImage: "trash.fill")
                                    .foregroundColor(.error)
                            }
                            Spacer()
                        }
                    }
                    .disabled(isDeleting)
                } footer: {
                    Text("Deleting your account will permanently remove all your data. This action cannot be undone.")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .disabled(isDeleting)
                }
            }
            .alert("Delete Account?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Continue", role: .destructive) {
                    showDeleteFinalConfirmation = true
                }
            } message: {
                Text("Are you sure you want to delete your account? This will permanently remove all your data.")
            }
            .alert("Final Confirmation", isPresented: $showDeleteFinalConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete Forever", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("This action is PERMANENT and cannot be undone. All your data will be lost forever.")
            }
        }
    }

    private func deleteAccount() {
        isDeleting = true
        Task {
            let success = await authViewModel.deleteAccount()
            isDeleting = false
            if success {
                Haptics.notification(.success)
                dismiss()
            } else {
                Haptics.notification(.error)
            }
        }
    }
}

// MARK: - Settings Row Helper
struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            if !value.isEmpty {
                Text(value)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
    }
}

// MARK: - Email Settings View
struct EmailSettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var newEmail = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Current Email")
                    Spacer()
                    Text(authViewModel.currentUser?.email ?? "")
                        .foregroundColor(.textSecondary)
                }
            }

            Section {
                TextField("New Email Address", text: $newEmail)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Confirm Password", text: $password)
                    .textContentType(.password)
            } header: {
                Text("Change Email")
            } footer: {
                Text("Enter your password to confirm the email change. A verification link will be sent to your new email.")
            }

            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.error)
                        .font(.caption)
                }
            }

            Section {
                Button(action: updateEmail) {
                    HStack {
                        Spacer()
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Update Email")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(newEmail.isEmpty || password.isEmpty || isLoading)
            }
        }
        .navigationTitle("Email")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Email Updated", isPresented: $showSuccess) {
            Button("OK") { }
        } message: {
            Text("Please check your new email for a verification link.")
        }
    }

    private func updateEmail() {
        isLoading = true
        errorMessage = nil
        // TODO: Implement API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
            showSuccess = true
            Haptics.notification(.success)
        }
    }
}

// MARK: - Password Settings View
struct PasswordSettingsView: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    var passwordsMatch: Bool {
        !newPassword.isEmpty && newPassword == confirmPassword
    }

    var passwordStrength: PasswordStrength {
        if newPassword.count < 8 { return .weak }
        let hasUppercase = newPassword.contains(where: { $0.isUppercase })
        let hasNumber = newPassword.contains(where: { $0.isNumber })
        let hasSpecial = newPassword.contains(where: { !$0.isLetter && !$0.isNumber })

        if hasUppercase && hasNumber && hasSpecial && newPassword.count >= 12 {
            return .strong
        } else if (hasUppercase || hasNumber) && newPassword.count >= 8 {
            return .medium
        }
        return .weak
    }

    var body: some View {
        Form {
            Section {
                SecureField("Current Password", text: $currentPassword)
                    .textContentType(.password)
            } header: {
                Text("Verify Identity")
            }

            Section {
                SecureField("New Password", text: $newPassword)
                    .textContentType(.newPassword)

                if !newPassword.isEmpty {
                    HStack {
                        Text("Strength:")
                            .font(.caption)
                            .foregroundColor(.textSecondary)

                        Text(passwordStrength.label)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(passwordStrength.color)

                        Spacer()

                        HStack(spacing: 4) {
                            ForEach(0..<3) { index in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(index < passwordStrength.bars ? passwordStrength.color : Color.gray.opacity(0.3))
                                    .frame(width: 24, height: 4)
                            }
                        }
                    }
                }

                SecureField("Confirm New Password", text: $confirmPassword)
                    .textContentType(.newPassword)

                if !confirmPassword.isEmpty && !passwordsMatch {
                    Text("Passwords don't match")
                        .font(.caption)
                        .foregroundColor(.error)
                }
            } header: {
                Text("New Password")
            } footer: {
                Text("Use at least 8 characters with a mix of letters, numbers, and symbols for a strong password.")
            }

            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.error)
                        .font(.caption)
                }
            }

            Section {
                Button(action: updatePassword) {
                    HStack {
                        Spacer()
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Update Password")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(currentPassword.isEmpty || !passwordsMatch || isLoading)
            }
        }
        .navigationTitle("Password")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Password Updated", isPresented: $showSuccess) {
            Button("OK") { }
        } message: {
            Text("Your password has been changed successfully.")
        }
    }

    private func updatePassword() {
        isLoading = true
        errorMessage = nil
        // TODO: Implement API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
            showSuccess = true
            currentPassword = ""
            newPassword = ""
            confirmPassword = ""
            Haptics.notification(.success)
        }
    }
}

enum PasswordStrength {
    case weak, medium, strong

    var label: String {
        switch self {
        case .weak: return "Weak"
        case .medium: return "Medium"
        case .strong: return "Strong"
        }
    }

    var color: Color {
        switch self {
        case .weak: return .error
        case .medium: return .warning
        case .strong: return .success
        }
    }

    var bars: Int {
        switch self {
        case .weak: return 1
        case .medium: return 2
        case .strong: return 3
        }
    }
}

// MARK: - Two-Factor Authentication Settings View
struct TwoFactorSettingsView: View {
    @State private var is2FAEnabled = false
    @State private var showSetupSheet = false
    @State private var showDisableAlert = false
    @State private var verificationCode = ""
    @State private var isLoading = false

    var body: some View {
        Form {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Two-Factor Authentication")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text(is2FAEnabled ? "Enabled" : "Disabled")
                            .font(.caption)
                            .foregroundColor(is2FAEnabled ? .success : .textSecondary)
                    }

                    Spacer()

                    Toggle("", isOn: $is2FAEnabled)
                        .labelsHidden()
                        .onChange(of: is2FAEnabled) { _, newValue in
                            if newValue {
                                showSetupSheet = true
                            } else {
                                showDisableAlert = true
                            }
                        }
                }
            } footer: {
                Text("Add an extra layer of security to your account by requiring a verification code when you sign in.")
            }

            if is2FAEnabled {
                Section("Recovery Options") {
                    NavigationLink {
                        RecoveryCodesView()
                    } label: {
                        Label("View Recovery Codes", systemImage: "key.fill")
                    }

                    Button(action: {
                        // Regenerate codes
                    }) {
                        Label("Regenerate Recovery Codes", systemImage: "arrow.clockwise")
                    }
                }
            }

            Section {
                VStack(alignment: .leading, spacing: .spacingM) {
                    Label("How it works", systemImage: "questionmark.circle.fill")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    VStack(alignment: .leading, spacing: .spacingS) {
                        BulletPoint(text: "Download an authenticator app (Google Authenticator, Authy)")
                        BulletPoint(text: "Scan the QR code to add your account")
                        BulletPoint(text: "Enter the 6-digit code when signing in")
                    }
                }
            }
        }
        .navigationTitle("Two-Factor Auth")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSetupSheet, onDismiss: {
            if verificationCode.isEmpty {
                is2FAEnabled = false
            }
        }) {
            TwoFactorSetupSheet(verificationCode: $verificationCode, isEnabled: $is2FAEnabled)
        }
        .alert("Disable 2FA?", isPresented: $showDisableAlert) {
            Button("Cancel", role: .cancel) {
                is2FAEnabled = true
            }
            Button("Disable", role: .destructive) {
                // Disable 2FA
            }
        } message: {
            Text("This will make your account less secure. Are you sure?")
        }
    }
}

struct BulletPoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: .spacingS) {
            Circle()
                .fill(Color.brandPrimary)
                .frame(width: 6, height: 6)
                .padding(.top, 6)

            Text(text)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
    }
}

struct TwoFactorSetupSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var verificationCode: String
    @Binding var isEnabled: Bool
    @State private var step = 1

    var body: some View {
        NavigationStack {
            VStack(spacing: .spacing2XL) {
                // Progress indicator
                HStack(spacing: .spacingS) {
                    ForEach(1...3, id: \.self) { stepNum in
                        Circle()
                            .fill(stepNum <= step ? Color.brandPrimary : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }

                if step == 1 {
                    setupStep1
                } else if step == 2 {
                    setupStep2
                } else {
                    setupStep3
                }

                Spacer()
            }
            .padding(.spacing2XL)
            .navigationTitle("Set Up 2FA")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        verificationCode = ""
                        dismiss()
                    }
                }
            }
        }
    }

    private var setupStep1: some View {
        VStack(spacing: .spacingXL) {
            Image(systemName: "apps.iphone")
                .font(.system(size: 60))
                .foregroundStyle(LinearGradient.brand)

            Text("Download an Authenticator App")
                .font(.title2)
                .fontWeight(.bold)

            Text("We recommend Google Authenticator or Authy. Download one from the App Store if you haven't already.")
                .font(.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)

            PrimaryButton(title: "Next", action: { step = 2 })
        }
    }

    private var setupStep2: some View {
        VStack(spacing: .spacingXL) {
            // Placeholder QR code
            RoundedRectangle(cornerRadius: .radiusMedium)
                .fill(Color.adaptiveSurface())
                .frame(width: 200, height: 200)
                .overlay(
                    Image(systemName: "qrcode")
                        .font(.system(size: 80))
                        .foregroundColor(.textSecondary)
                )

            Text("Scan this QR Code")
                .font(.title2)
                .fontWeight(.bold)

            Text("Open your authenticator app and scan this code to add your Formative account.")
                .font(.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)

            PrimaryButton(title: "Next", action: { step = 3 })
        }
    }

    private var setupStep3: some View {
        VStack(spacing: .spacingXL) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 60))
                .foregroundStyle(LinearGradient.brand)

            Text("Enter Verification Code")
                .font(.title2)
                .fontWeight(.bold)

            Text("Enter the 6-digit code from your authenticator app to complete setup.")
                .font(.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)

            TextField("000000", text: $verificationCode)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .frame(maxWidth: 200)
                .padding()
                .background(Color.adaptiveSurface())
                .cornerRadius(.radiusMedium)

            PrimaryButton(title: "Verify & Enable", action: {
                isEnabled = true
                Haptics.notification(.success)
                dismiss()
            }, isDisabled: verificationCode.count != 6)
        }
    }
}

struct RecoveryCodesView: View {
    let codes = ["ABC123DEF456", "GHI789JKL012", "MNO345PQR678", "STU901VWX234", "YZA567BCD890"]
    @State private var copiedIndex: Int?

    var body: some View {
        Form {
            Section {
                ForEach(Array(codes.enumerated()), id: \.offset) { index, code in
                    HStack {
                        Text(code)
                            .font(.system(.body, design: .monospaced))

                        Spacer()

                        Button(action: {
                            UIPasteboard.general.string = code
                            copiedIndex = index
                            Haptics.notification(.success)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                copiedIndex = nil
                            }
                        }) {
                            Image(systemName: copiedIndex == index ? "checkmark" : "doc.on.doc")
                                .foregroundColor(copiedIndex == index ? .success : .brandPrimary)
                        }
                    }
                }
            } header: {
                Text("Recovery Codes")
            } footer: {
                Text("Save these codes in a secure place. You can use them to access your account if you lose your authenticator device.")
            }

            Section {
                Button(action: {
                    UIPasteboard.general.string = codes.joined(separator: "\n")
                    Haptics.notification(.success)
                }) {
                    Label("Copy All Codes", systemImage: "doc.on.doc.fill")
                }
            }
        }
        .navigationTitle("Recovery Codes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Calendly Settings View
struct CalendlySettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var calendlyUrl = ""
    @State private var isLoading = false
    @State private var showSuccess = false

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: .spacingM) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 40))
                        .foregroundStyle(LinearGradient.brand)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, .spacingM)

                    Text("Connect Calendly")
                        .font(.headline)
                        .frame(maxWidth: .infinity)

                    Text("Add your Calendly link so brands and collaborators can easily schedule meetings with you.")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }

            Section {
                TextField("https://calendly.com/your-link", text: $calendlyUrl)
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
            } header: {
                Text("Calendly URL")
            } footer: {
                Text("Your Calendly link will appear on your dashboard calendar section.")
            }

            Section {
                Button(action: saveCalendlyUrl) {
                    HStack {
                        Spacer()
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Save")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(isLoading)

                if !calendlyUrl.isEmpty {
                    Button(role: .destructive, action: removeCalendlyUrl) {
                        HStack {
                            Spacer()
                            Text("Remove Calendly Link")
                            Spacer()
                        }
                    }
                }
            }
        }
        .navigationTitle("Calendly")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            calendlyUrl = authViewModel.currentUser?.profileData?.calendlyUrl ?? ""
        }
        .alert("Calendly Updated", isPresented: $showSuccess) {
            Button("OK") { }
        }
    }

    private func saveCalendlyUrl() {
        isLoading = true
        Task {
            let success = await authViewModel.updateProfile(
                name: nil,
                bio: nil,
                website: nil,
                location: nil,
                calendlyUrl: calendlyUrl.isEmpty ? nil : calendlyUrl
            )
            isLoading = false
            if success {
                showSuccess = true
                Haptics.notification(.success)
            } else {
                Haptics.notification(.error)
            }
        }
    }

    private func removeCalendlyUrl() {
        calendlyUrl = ""
        saveCalendlyUrl()
    }
}

// MARK: - Privacy Settings View
struct PrivacySettingsView: View {
    @State private var profileVisibility = "Public"
    @State private var showActivityStatus = true
    @State private var allowMessages = "Everyone"

    var body: some View {
        Form {
            Section("Profile Visibility") {
                Picker("Who can see your profile", selection: $profileVisibility) {
                    Text("Public").tag("Public")
                    Text("Connections Only").tag("Connections")
                    Text("Private").tag("Private")
                }
            }

            Section {
                Toggle("Show Activity Status", isOn: $showActivityStatus)
            } header: {
                Text("Activity")
            } footer: {
                Text("When enabled, others can see when you were last active.")
            }

            Section("Messaging") {
                Picker("Who can message you", selection: $allowMessages) {
                    Text("Everyone").tag("Everyone")
                    Text("Connections Only").tag("Connections")
                    Text("No One").tag("None")
                }
            }

            Section("Blocked Accounts") {
                NavigationLink {
                    BlockedAccountsView()
                } label: {
                    Text("Manage Blocked Accounts")
                }
            }
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BlockedAccountsView: View {
    var body: some View {
        VStack(spacing: .spacingXL) {
            Spacer()

            Image(systemName: "person.crop.circle.badge.xmark")
                .font(.system(size: 60))
                .foregroundColor(.textSecondary.opacity(0.5))

            Text("No Blocked Accounts")
                .font(.headline)

            Text("Accounts you block will appear here")
                .font(.subheadline)
                .foregroundColor(.textSecondary)

            Spacer()
        }
        .navigationTitle("Blocked Accounts")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Data Export View
struct DataExportView: View {
    @State private var isExporting = false
    @State private var showSuccess = false

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: .spacingM) {
                    Image(systemName: "square.and.arrow.up.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(LinearGradient.brand)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, .spacingM)

                    Text("Export Your Data")
                        .font(.headline)
                        .frame(maxWidth: .infinity)

                    Text("Download a copy of all your Formative data including your profile, applications, messages, and activity history.")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }

            Section("What's Included") {
                Label("Profile Information", systemImage: "person.fill")
                Label("Applications & Proposals", systemImage: "briefcase.fill")
                Label("Messages & Conversations", systemImage: "message.fill")
                Label("Activity History", systemImage: "clock.fill")
                Label("Media Kit & Portfolio", systemImage: "photo.fill")
            }

            Section {
                Button(action: exportData) {
                    HStack {
                        Spacer()
                        if isExporting {
                            ProgressView()
                            Text("Preparing...")
                                .padding(.leading, .spacingS)
                        } else {
                            Label("Request Data Export", systemImage: "arrow.down.circle.fill")
                        }
                        Spacer()
                    }
                }
                .disabled(isExporting)
            } footer: {
                Text("You'll receive an email with a download link when your data is ready. This usually takes a few minutes.")
            }
        }
        .navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Export Requested", isPresented: $showSuccess) {
            Button("OK") { }
        } message: {
            Text("We're preparing your data. You'll receive an email with a download link shortly.")
        }
    }

    private func exportData() {
        isExporting = true
        // Simulate export
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isExporting = false
            showSuccess = true
            Haptics.notification(.success)
        }
    }
}

struct MediaKitView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showAddSocial = false
    @State private var showAddPortfolio = false
    @State private var socialAccounts: [SocialAccount] = []
    @State private var portfolioItems: [PortfolioItem] = []
    @State private var collaborationRate = ""
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(spacing: .spacing2XL) {
                // Profile Summary Card
                profileSummaryCard
                    .padding(.horizontal, .spacingL)
                    .padding(.top, .spacingL)

                // Social Stats Section
                socialStatsSection
                    .padding(.horizontal, .spacingL)

                // Portfolio Section
                portfolioSection
                    .padding(.horizontal, .spacingL)

                // Collaboration Rates Section
                ratesSection
                    .padding(.horizontal, .spacingL)

                Spacer(minLength: .spacing5XL)
            }
        }
        .background(Color.adaptiveBackground())
        .navigationTitle("Media Kit")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    Haptics.selection()
                    // Share media kit
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showAddSocial) {
            AddSocialAccountView(socialAccounts: $socialAccounts)
        }
        .sheet(isPresented: $showAddPortfolio) {
            AddPortfolioItemView(portfolioItems: $portfolioItems)
        }
    }

    // MARK: - Profile Summary Card
    private var profileSummaryCard: some View {
        GlassCard {
            VStack(spacing: .spacingM) {
                // Avatar
                Circle()
                    .fill(LinearGradient.brand)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(avatarInitials)
                            .font(.title1)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )

                VStack(spacing: .spacingS) {
                    Text(authViewModel.currentUser?.name ?? "Creator")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.adaptiveTextPrimary())

                    if let bio = authViewModel.currentUser?.profileData?.bio {
                        Text(bio)
                            .font(.subhead)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                    }

                    if let location = authViewModel.currentUser?.profileData?.location {
                        Label(location, systemImage: "location.fill")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }

                // Quick Stats
                HStack(spacing: .spacingXL) {
                    VStack {
                        Text(totalFollowers)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.adaptiveTextPrimary())
                        Text("Followers")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }

                    Divider()
                        .frame(height: 30)

                    VStack {
                        Text(averageEngagement)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.adaptiveTextPrimary())
                        Text("Avg. Engagement")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }

                    Divider()
                        .frame(height: 30)

                    VStack {
                        Text("\(portfolioItems.count)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.adaptiveTextPrimary())
                        Text("Works")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(.top, .spacingS)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var avatarInitials: String {
        guard let name = authViewModel.currentUser?.name else { return "C" }
        let words = name.split(separator: " ")
        if words.count >= 2 {
            return String(words[0].prefix(1)) + String(words[1].prefix(1))
        }
        return String(name.prefix(1))
    }

    private var totalFollowers: String {
        let total = socialAccounts.reduce(0) { $0 + $1.followers }
        if total >= 1000000 {
            return String(format: "%.1fM", Double(total) / 1000000)
        } else if total >= 1000 {
            return String(format: "%.1fK", Double(total) / 1000)
        }
        return "\(total)"
    }

    private var averageEngagement: String {
        guard !socialAccounts.isEmpty else { return "0%" }
        let avg = socialAccounts.reduce(0.0) { $0 + $1.engagementRate } / Double(socialAccounts.count)
        return String(format: "%.1f%%", avg)
    }

    // MARK: - Social Stats Section
    private var socialStatsSection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            HStack {
                Text("Social Accounts")
                    .font(.headline)
                    .foregroundColor(.adaptiveTextPrimary())

                Spacer()

                Button(action: {
                    Haptics.selection()
                    showAddSocial = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.brandPrimary)
                }
            }

            if socialAccounts.isEmpty {
                emptyStateCard(
                    icon: "person.2.circle",
                    title: "No Social Accounts",
                    message: "Add your social media accounts to showcase your reach"
                )
            } else {
                ForEach(socialAccounts) { account in
                    SocialAccountCard(account: account, onDelete: {
                        socialAccounts.removeAll { $0.id == account.id }
                    })
                }
            }
        }
    }

    // MARK: - Portfolio Section
    private var portfolioSection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            HStack {
                Text("Portfolio")
                    .font(.headline)
                    .foregroundColor(.adaptiveTextPrimary())

                Spacer()

                Button(action: {
                    Haptics.selection()
                    showAddPortfolio = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.brandPrimary)
                }
            }

            if portfolioItems.isEmpty {
                emptyStateCard(
                    icon: "photo.on.rectangle.angled",
                    title: "No Portfolio Items",
                    message: "Add your best work to impress potential collaborators"
                )
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: .spacingM) {
                    ForEach(portfolioItems) { item in
                        PortfolioItemCard(item: item, onDelete: {
                            portfolioItems.removeAll { $0.id == item.id }
                        })
                    }
                }
            }
        }
    }

    // MARK: - Rates Section
    private var ratesSection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Collaboration Rates")
                .font(.headline)
                .foregroundColor(.adaptiveTextPrimary())

            GlassCard {
                VStack(alignment: .leading, spacing: .spacingM) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.brandPrimary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Starting Rate")
                                .font(.caption)
                                .foregroundColor(.textSecondary)

                            if collaborationRate.isEmpty {
                                TextField("e.g., $500 per post", text: $collaborationRate)
                                    .font(.subhead)
                                    .foregroundColor(.adaptiveTextPrimary())
                            } else {
                                Text(collaborationRate)
                                    .font(.subhead)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.adaptiveTextPrimary())
                            }
                        }

                        Spacer()

                        Button(action: {
                            Haptics.selection()
                            collaborationRate = ""
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.textSecondary)
                        }
                    }

                    Text("Rates are negotiable based on scope and deliverables")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
        }
    }

    private func emptyStateCard(icon: String, title: String, message: String) -> some View {
        GlassCard {
            VStack(spacing: .spacingM) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(.textSecondary.opacity(0.5))

                Text(title)
                    .font(.subhead)
                    .fontWeight(.medium)
                    .foregroundColor(.adaptiveTextPrimary())

                Text(message)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.spacingM)
        }
    }
}

// MARK: - Social Account Model & Card
struct SocialAccount: Identifiable {
    let id = UUID()
    let platform: SocialPlatform
    let username: String
    let followers: Int
    let engagementRate: Double
}

enum SocialPlatform: String, CaseIterable {
    case instagram = "Instagram"
    case tiktok = "TikTok"
    case youtube = "YouTube"
    case twitter = "Twitter/X"
    case linkedin = "LinkedIn"
    case facebook = "Facebook"

    var icon: String {
        switch self {
        case .instagram: return "camera.circle.fill"
        case .tiktok: return "music.note"
        case .youtube: return "play.rectangle.fill"
        case .twitter: return "at.circle.fill"
        case .linkedin: return "link.circle.fill"
        case .facebook: return "person.2.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .instagram: return .pink
        case .tiktok: return .primary
        case .youtube: return .red
        case .twitter: return .blue
        case .linkedin: return .blue
        case .facebook: return .blue
        }
    }
}

struct SocialAccountCard: View {
    let account: SocialAccount
    let onDelete: () -> Void

    var body: some View {
        GlassCard {
            HStack(spacing: .spacingM) {
                Image(systemName: account.platform.icon)
                    .font(.title2)
                    .foregroundColor(account.platform.color)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(account.platform.rawValue)
                        .font(.subhead)
                        .fontWeight(.medium)
                        .foregroundColor(.adaptiveTextPrimary())

                    Text("@\(account.username)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatFollowers(account.followers))
                        .font(.subhead)
                        .fontWeight(.semibold)
                        .foregroundColor(.adaptiveTextPrimary())

                    Text(String(format: "%.1f%% eng.", account.engagementRate))
                        .font(.caption)
                        .foregroundColor(.success)
                }

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.error)
                }
            }
        }
    }

    private func formatFollowers(_ count: Int) -> String {
        if count >= 1000000 {
            return String(format: "%.1fM", Double(count) / 1000000)
        } else if count >= 1000 {
            return String(format: "%.1fK", Double(count) / 1000)
        }
        return "\(count)"
    }
}

// MARK: - Add Social Account View
struct AddSocialAccountView: View {
    @Binding var socialAccounts: [SocialAccount]
    @Environment(\.dismiss) var dismiss

    @State private var selectedPlatform: SocialPlatform = .instagram
    @State private var username = ""
    @State private var followers = ""
    @State private var engagementRate = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Platform") {
                    Picker("Platform", selection: $selectedPlatform) {
                        ForEach(SocialPlatform.allCases, id: \.self) { platform in
                            Text(platform.rawValue).tag(platform)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Account Details") {
                    TextField("Username (without @)", text: $username)
                        .autocapitalization(.none)

                    TextField("Followers", text: $followers)
                        .keyboardType(.numberPad)

                    TextField("Engagement Rate (%)", text: $engagementRate)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Social Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addAccount()
                    }
                    .disabled(username.isEmpty || followers.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func addAccount() {
        let account = SocialAccount(
            platform: selectedPlatform,
            username: username,
            followers: Int(followers) ?? 0,
            engagementRate: Double(engagementRate) ?? 0
        )
        socialAccounts.append(account)
        Haptics.notification(.success)
        dismiss()
    }
}

// MARK: - Portfolio Item Model & Card
struct PortfolioItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let type: PortfolioType
    let url: String?
}

enum PortfolioType: String, CaseIterable {
    case image = "Image"
    case video = "Video"
    case link = "Link"
    case campaign = "Campaign"

    var icon: String {
        switch self {
        case .image: return "photo"
        case .video: return "video"
        case .link: return "link"
        case .campaign: return "megaphone"
        }
    }
}

struct PortfolioItemCard: View {
    let item: PortfolioItem
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: .spacingS) {
            // Placeholder thumbnail
            RoundedRectangle(cornerRadius: .radiusSmall)
                .fill(LinearGradient.brand.opacity(0.3))
                .frame(height: 100)
                .overlay(
                    Image(systemName: item.type.icon)
                        .font(.title)
                        .foregroundColor(.brandPrimary)
                )

            Text(item.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.adaptiveTextPrimary())
                .lineLimit(1)

            HStack {
                Text(item.type.rawValue)
                    .font(.caption2)
                    .foregroundColor(.textSecondary)

                Spacer()

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption2)
                        .foregroundColor(.error)
                }
            }
        }
        .padding(.spacingS)
        .background(Color.adaptiveSurface())
        .cornerRadius(.radiusMedium)
    }
}

// MARK: - Add Portfolio Item View
struct AddPortfolioItemView: View {
    @Binding var portfolioItems: [PortfolioItem]
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var selectedType: PortfolioType = .image
    @State private var url = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)

                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...5)
                }

                Section("Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(PortfolioType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Link (Optional)") {
                    TextField("URL", text: $url)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Add Portfolio Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem()
                    }
                    .disabled(title.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func addItem() {
        let item = PortfolioItem(
            title: title,
            description: description,
            type: selectedType,
            url: url.isEmpty ? nil : url
        )
        portfolioItems.append(item)
        Haptics.notification(.success)
        dismiss()
    }
}

struct MyApplicationsView: View {
    @StateObject private var viewModel = ApplicationsViewModel()
    @State private var selectedFilter: ApplicationFilter = .all

    var body: some View {
        VStack(spacing: 0) {
            // Filter Tabs
            filterTabs
                .padding(.horizontal, .spacingL)
                .padding(.vertical, .spacingM)

            // Applications List
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                Spacer()
            } else if filteredApplications.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: .spacingM) {
                        ForEach(filteredApplications) { application in
                            ApplicationCard(application: application, onWithdraw: {
                                withdrawApplication(application)
                            })
                        }
                    }
                    .padding(.horizontal, .spacingL)
                    .padding(.bottom, .spacing5XL)
                }
            }
        }
        .background(Color.adaptiveBackground())
        .navigationTitle("My Applications")
        .task {
            await viewModel.loadApplications()
        }
        .refreshable {
            await viewModel.loadApplications()
        }
    }

    // MARK: - Filter Tabs
    private var filterTabs: some View {
        HStack(spacing: .spacingS) {
            ForEach(ApplicationFilter.allCases, id: \.self) { filter in
                Button(action: {
                    withAnimation(.springSmooth) {
                        selectedFilter = filter
                    }
                    Haptics.selection()
                }) {
                    Text(filter.title)
                        .font(.subhead)
                        .fontWeight(selectedFilter == filter ? .semibold : .regular)
                        .foregroundColor(selectedFilter == filter ? .white : .textSecondary)
                        .padding(.horizontal, .spacingM)
                        .padding(.vertical, .spacingS)
                        .background(
                            selectedFilter == filter
                                ? AnyShapeStyle(LinearGradient.brand)
                                : AnyShapeStyle(Color.adaptiveSurface())
                        )
                        .cornerRadius(.radiusSmall)
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: .spacingL) {
            Spacer()

            Image(systemName: "briefcase")
                .font(.system(size: 60))
                .foregroundColor(.textSecondary.opacity(0.5))

            Text(emptyStateTitle)
                .font(.headline)
                .foregroundColor(.adaptiveTextPrimary())

            Text(emptyStateMessage)
                .font(.subhead)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, .spacing2XL)

            Spacer()
        }
    }

    private var emptyStateTitle: String {
        switch selectedFilter {
        case .all: return "No Applications Yet"
        case .pending: return "No Pending Applications"
        case .accepted: return "No Accepted Applications"
        case .rejected: return "No Rejected Applications"
        }
    }

    private var emptyStateMessage: String {
        switch selectedFilter {
        case .all: return "Start applying to opportunities to see them here"
        case .pending: return "You don't have any applications awaiting review"
        case .accepted: return "Keep applying! Your next opportunity is waiting"
        case .rejected: return "No rejected applications"
        }
    }

    // MARK: - Filtered Applications
    private var filteredApplications: [Application] {
        switch selectedFilter {
        case .all: return viewModel.applications
        case .pending: return viewModel.pendingApplications
        case .accepted: return viewModel.acceptedApplications
        case .rejected: return viewModel.rejectedApplications
        }
    }

    private func withdrawApplication(_ application: Application) {
        Task {
            let success = await viewModel.withdrawApplication(applicationId: application.id)
            if success {
                Haptics.notification(.success)
            } else {
                Haptics.notification(.error)
            }
        }
    }
}

// MARK: - Application Filter
enum ApplicationFilter: CaseIterable {
    case all, pending, accepted, rejected

    var title: String {
        switch self {
        case .all: return "All"
        case .pending: return "Pending"
        case .accepted: return "Accepted"
        case .rejected: return "Rejected"
        }
    }
}

// MARK: - Application Card
struct ApplicationCard: View {
    let application: Application
    let onWithdraw: () -> Void
    @State private var showWithdrawAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            // Header with status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(application.opportunity?.title ?? "Opportunity #\(application.opportunityId)")
                        .font(.headline)
                        .foregroundColor(.adaptiveTextPrimary())

                    if let company = application.opportunity?.companyName {
                        Text(company)
                            .font(.subhead)
                            .foregroundColor(.textSecondary)
                    }
                }

                Spacer()

                ApplicationStatusBadge(status: application.status ?? "pending")
            }

            Divider()

            // Application details
            if let message = application.message {
                Text(message)
                    .font(.body)
                    .foregroundColor(.adaptiveTextPrimary())
                    .lineLimit(2)
            }

            HStack {
                if let rate = application.proposedRate, !rate.isEmpty {
                    Label(rate, systemImage: "dollarsign.circle")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                if let date = application.createdAt {
                    Text(formatDate(date))
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }

            // Withdraw button for pending applications
            if application.isActive {
                Button(action: {
                    showWithdrawAlert = true
                }) {
                    Text("Withdraw Application")
                        .font(.subhead)
                        .foregroundColor(.error)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, .spacingS)
                        .background(Color.error.opacity(0.1))
                        .cornerRadius(.radiusSmall)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.spacingL)
        .background(Color.adaptiveSurface())
        .cornerRadius(.radiusMedium)
        .alert("Withdraw Application?", isPresented: $showWithdrawAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Withdraw", role: .destructive) {
                onWithdraw()
            }
        } message: {
            Text("Are you sure you want to withdraw this application? This action cannot be undone.")
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }

        // Try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }

        return dateString
    }
}

// MARK: - Application Status Badge
struct ApplicationStatusBadge: View {
    let status: String

    var body: some View {
        Text(status.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, .spacingM)
            .padding(.vertical, 4)
            .background(statusColor)
            .cornerRadius(.radiusSmall)
    }

    private var statusColor: Color {
        switch status.lowercased() {
        case "pending": return .warning
        case "reviewing": return .brandPrimary
        case "accepted": return .success
        case "rejected": return .error
        case "withdrawn": return .textSecondary
        default: return .textSecondary
        }
    }
}

struct ShopView: View {
    @State private var products: [ShopProduct] = []
    @State private var showAddProduct = false
    @State private var selectedCategory: ProductCategory? = nil

    var filteredProducts: [ShopProduct] {
        if let category = selectedCategory {
            return products.filter { $0.category == category }
        }
        return products
    }

    var body: some View {
        VStack(spacing: 0) {
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: .spacingS) {
                    CategoryChip(
                        title: "All",
                        isSelected: selectedCategory == nil,
                        action: { selectedCategory = nil }
                    )

                    ForEach(ProductCategory.allCases, id: \.self) { category in
                        CategoryChip(
                            title: category.rawValue,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal, .spacingL)
                .padding(.vertical, .spacingM)
            }

            Divider()

            // Products Grid
            if products.isEmpty {
                VStack(spacing: .spacingL) {
                    Spacer()

                    Image(systemName: "bag")
                        .font(.system(size: 60))
                        .foregroundColor(.textSecondary.opacity(0.5))

                    Text("No Products Yet")
                        .font(.headline)
                        .foregroundColor(.adaptiveTextPrimary())

                    Text("Add products or services to start selling")
                        .font(.subhead)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, .spacing2XL)

                    Button(action: {
                        Haptics.selection()
                        showAddProduct = true
                    }) {
                        Label("Add Product", systemImage: "plus")
                            .font(.subhead)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, .spacingXL)
                            .padding(.vertical, .spacingM)
                            .background(LinearGradient.brand)
                            .cornerRadius(.radiusMedium)
                    }

                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: .spacingM) {
                        ForEach(filteredProducts) { product in
                            ShopProductCard(product: product, onDelete: {
                                products.removeAll { $0.id == product.id }
                            })
                        }
                    }
                    .padding(.spacingL)
                }
            }
        }
        .background(Color.adaptiveBackground())
        .navigationTitle("Creator Shop")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    Haptics.selection()
                    showAddProduct = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddProduct) {
            AddProductView(products: $products)
        }
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptics.selection()
            action()
        }) {
            Text(title)
                .font(.subhead)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .textSecondary)
                .padding(.horizontal, .spacingM)
                .padding(.vertical, .spacingS)
                .background(
                    isSelected
                        ? AnyShapeStyle(LinearGradient.brand)
                        : AnyShapeStyle(Color.adaptiveSurface())
                )
                .cornerRadius(.radiusFull)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Shop Product Model
struct ShopProduct: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let price: Double
    let category: ProductCategory
    let deliveryTime: String?
    let isDigital: Bool
}

enum ProductCategory: String, CaseIterable {
    case service = "Service"
    case digital = "Digital"
    case physical = "Physical"
    case consultation = "Consultation"
    case content = "Content"

    var icon: String {
        switch self {
        case .service: return "wrench.and.screwdriver"
        case .digital: return "arrow.down.circle"
        case .physical: return "shippingbox"
        case .consultation: return "video"
        case .content: return "photo.stack"
        }
    }
}

// MARK: - Shop Product Card
struct ShopProductCard: View {
    let product: ShopProduct
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: .spacingS) {
            // Product Image Placeholder
            RoundedRectangle(cornerRadius: .radiusSmall)
                .fill(LinearGradient.brand.opacity(0.2))
                .frame(height: 120)
                .overlay(
                    Image(systemName: product.category.icon)
                        .font(.largeTitle)
                        .foregroundColor(.brandPrimary)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.subhead)
                    .fontWeight(.semibold)
                    .foregroundColor(.adaptiveTextPrimary())
                    .lineLimit(1)

                Text(product.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                HStack {
                    Text(formatPrice(product.price))
                        .font(.subhead)
                        .fontWeight(.bold)
                        .foregroundColor(.brandPrimary)

                    Spacer()

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.error)
                    }
                }
            }
            .padding(.horizontal, .spacingS)
            .padding(.bottom, .spacingS)
        }
        .background(Color.adaptiveSurface())
        .cornerRadius(.radiusMedium)
    }

    private func formatPrice(_ price: Double) -> String {
        if price == 0 {
            return "Free"
        }
        return String(format: "$%.2f", price)
    }
}

// MARK: - Add Product View
struct AddProductView: View {
    @Binding var products: [ShopProduct]
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var price = ""
    @State private var selectedCategory: ProductCategory = .service
    @State private var deliveryTime = ""
    @State private var isDigital = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Product Details") {
                    TextField("Title", text: $title)

                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)

                    TextField("Price ($)", text: $price)
                        .keyboardType(.decimalPad)
                }

                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ProductCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Delivery") {
                    Toggle("Digital Product", isOn: $isDigital)

                    TextField("Delivery Time (e.g., 3-5 days)", text: $deliveryTime)
                }
            }
            .navigationTitle("Add Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addProduct()
                    }
                    .disabled(title.isEmpty || price.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func addProduct() {
        let product = ShopProduct(
            title: title,
            description: description,
            price: Double(price) ?? 0,
            category: selectedCategory,
            deliveryTime: deliveryTime.isEmpty ? nil : deliveryTime,
            isDigital: isDigital
        )
        products.append(product)
        Haptics.notification(.success)
        dismiss()
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}

