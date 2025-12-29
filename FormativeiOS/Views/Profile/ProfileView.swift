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
                location: location.isEmpty ? nil : location
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
    
    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    NavigationLink("Email") {}
                    NavigationLink("Password") {}
                    NavigationLink("Two-Factor Authentication") {}
                }
                
                Section("Notifications") {
                    Toggle("Push Notifications", isOn: .constant(true))
                    Toggle("Email Notifications", isOn: .constant(true))
                }
                
                Section("Privacy") {
                    NavigationLink("Privacy Settings") {}
                    NavigationLink("Data Export") {}
                }
                
                Section("About") {
                    NavigationLink("Terms of Service") {}
                    NavigationLink("Privacy Policy") {}
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct MediaKitView: View {
    var body: some View {
        Text("Media Kit")
            .navigationTitle("Media Kit")
    }
}

struct MyApplicationsView: View {
    var body: some View {
        Text("My Applications")
            .navigationTitle("My Applications")
    }
}

struct ShopView: View {
    var body: some View {
        Text("Creator Shop")
            .navigationTitle("Shop")
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}

