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

