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
                
                if let username = authViewModel.currentUser?.username {
                    Text("@\(username)")
                        .font(.subhead)
                        .foregroundColor(.textSecondary)
                }
            }
        }
    }
    
    private var displayName: String {
        guard let user = authViewModel.currentUser else { return "User" }
        if let firstName = user.firstName, let lastName = user.lastName {
            return "\(firstName) \(lastName)"
        } else if let firstName = user.firstName {
            return firstName
        } else if let username = user.username {
            return username
        }
        return user.email
    }
    
    private var avatarInitials: String {
        guard let user = authViewModel.currentUser else { return "U" }
        if let firstName = user.firstName, let lastName = user.lastName {
            return String(firstName.prefix(1)) + String(lastName.prefix(1))
        } else if let firstName = user.firstName {
            return String(firstName.prefix(1))
        } else if let username = user.username {
            return String(username.prefix(1))
        }
        return String(user.email.prefix(1))
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
                
                if let location = authViewModel.currentUser?.firstName {
                    // Would have location in user model
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

// MARK: - Placeholder Views
struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Text("Edit Profile")
                .navigationTitle("Edit Profile")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
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

