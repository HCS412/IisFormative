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
    var body: some View {
        Text("Creator Shop")
            .navigationTitle("Shop")
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}

