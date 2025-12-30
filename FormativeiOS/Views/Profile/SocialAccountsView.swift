//
//  SocialAccountsView.swift
//  FormativeiOS
//
//  View for managing connected social media accounts
//

import SwiftUI
import AuthenticationServices

struct SocialAccountsView: View {
    @StateObject private var viewModel = SocialAccountsViewModel()
    @State private var showingOAuthSheet = false
    @State private var selectedPlatform: SocialPlatform?
    @State private var blueskyHandle = ""
    @State private var showingBlueskySheet = false
    @State private var showingDisconnectAlert = false
    @State private var platformToDisconnect: SocialPlatform?

    var body: some View {
        ScrollView {
            VStack(spacing: .spacing2XL) {
                // Header
                headerSection
                    .padding(.horizontal, .spacingL)
                    .padding(.top, .spacingL)

                // Connected Accounts
                if !viewModel.accounts.isEmpty {
                    connectedAccountsSection
                }

                // Available Platforms
                availablePlatformsSection
                    .padding(.horizontal, .spacingL)
            }
            .padding(.bottom, .spacing5XL)
        }
        .background(Color.adaptiveBackground())
        .navigationTitle("Social Accounts")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadAccounts()
        }
        .refreshable {
            await viewModel.loadAccounts()
        }
        .sheet(isPresented: $showingOAuthSheet) {
            if let platform = selectedPlatform,
               let url = viewModel.getOAuthURL(for: platform) {
                OAuthWebView(url: url, platform: platform) { success in
                    showingOAuthSheet = false
                    if success {
                        Task {
                            await viewModel.loadAccounts()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingBlueskySheet) {
            blueskyVerificationSheet
        }
        .alert("Disconnect Account", isPresented: $showingDisconnectAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Disconnect", role: .destructive) {
                if let platform = platformToDisconnect {
                    Task {
                        _ = await viewModel.disconnectAccount(platform: platform)
                    }
                }
            }
        } message: {
            if let platform = platformToDisconnect {
                Text("Are you sure you want to disconnect your \(platform.displayName) account?")
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Connect your social media accounts to showcase your reach and engagement to brands.")
                .font(.subhead)
                .foregroundColor(.textSecondary)

            if viewModel.aggregatedStats.platformCount > 0 {
                HStack(spacing: .spacingL) {
                    VStack(alignment: .leading) {
                        Text(viewModel.aggregatedStats.formattedFollowers)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.adaptiveTextPrimary())
                        Text("Total Followers")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }

                    Divider()
                        .frame(height: 40)

                    VStack(alignment: .leading) {
                        Text(viewModel.aggregatedStats.formattedEngagement)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.adaptiveTextPrimary())
                        Text("Avg Engagement")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(.spacingM)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.adaptiveSurface())
                .cornerRadius(.radiusMedium)
            }
        }
    }

    // MARK: - Connected Accounts Section
    private var connectedAccountsSection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Connected Accounts")
                .font(.headline)
                .foregroundColor(.adaptiveTextPrimary())
                .padding(.horizontal, .spacingL)

            VStack(spacing: .spacingS) {
                ForEach(viewModel.accounts, id: \.id) { account in
                    ConnectedAccountRow(
                        account: account,
                        onRefresh: {
                            Task {
                                await viewModel.refreshStats(for: account.platformType)
                            }
                        },
                        onDisconnect: {
                            platformToDisconnect = account.platformType
                            showingDisconnectAlert = true
                        }
                    )
                }
            }
            .padding(.horizontal, .spacingL)
        }
    }

    // MARK: - Available Platforms Section
    private var availablePlatformsSection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Connect More Accounts")
                .font(.headline)
                .foregroundColor(.adaptiveTextPrimary())

            VStack(spacing: .spacingS) {
                ForEach(SocialPlatform.allCases.filter { $0 != .other }, id: \.self) { platform in
                    if !viewModel.isConnected(platform) {
                        PlatformConnectButton(platform: platform) {
                            connectPlatform(platform)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Bluesky Verification Sheet
    private var blueskyVerificationSheet: some View {
        NavigationStack {
            VStack(spacing: .spacingXL) {
                Image(systemName: "cloud.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "0085FF"))
                    .padding(.top, .spacing2XL)

                Text("Connect Bluesky")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Enter your Bluesky handle to verify your account")
                    .font(.subhead)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)

                FormTextField(
                    title: "Bluesky Handle",
                    text: $blueskyHandle,
                    placeholder: "username.bsky.social",
                    icon: "at"
                )
                .padding(.horizontal, .spacingL)

                PrimaryButton(
                    title: "Verify Account",
                    action: {
                        Task {
                            let success = await viewModel.verifyBluesky(handle: blueskyHandle)
                            if success {
                                showingBlueskySheet = false
                                blueskyHandle = ""
                            }
                        }
                    },
                    isLoading: viewModel.isLoading
                )
                .disabled(blueskyHandle.isEmpty)
                .padding(.horizontal, .spacingL)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.error)
                }

                Spacer()
            }
            .navigationTitle("Bluesky")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingBlueskySheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Connect Platform
    private func connectPlatform(_ platform: SocialPlatform) {
        Haptics.selection()
        selectedPlatform = platform

        if platform.requiresOAuth {
            showingOAuthSheet = true
        } else if platform == .bluesky {
            showingBlueskySheet = true
        }
    }
}

// MARK: - Connected Account Row
struct ConnectedAccountRow: View {
    let account: SocialAccount
    let onRefresh: () -> Void
    let onDisconnect: () -> Void
    @State private var isRefreshing = false

    var body: some View {
        GlassCard {
            HStack(spacing: .spacingM) {
                // Platform Icon
                Image(systemName: account.platformType.icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: account.platformType.brandColor))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: account.platformType.brandColor).opacity(0.1))
                    .cornerRadius(.radiusMedium)

                // Account Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(account.platformType.displayName)
                            .font(.subhead)
                            .fontWeight(.semibold)
                            .foregroundColor(.adaptiveTextPrimary())

                        if account.isVerified == true {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundColor(.success)
                        }
                    }

                    Text(account.displayUsername)
                        .font(.caption)
                        .foregroundColor(.textSecondary)

                    HStack(spacing: .spacingM) {
                        Label(account.formattedFollowers, systemImage: "person.2")
                        Label(account.formattedEngagement, systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .font(.caption2)
                    .foregroundColor(.textSecondary)
                }

                Spacer()

                // Actions
                HStack(spacing: .spacingS) {
                    Button(action: {
                        isRefreshing = true
                        onRefresh()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isRefreshing = false
                        }
                    }) {
                        if isRefreshing {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption)
                                .foregroundColor(.brandPrimary)
                        }
                    }
                    .frame(width: 32, height: 32)

                    Menu {
                        Button(role: .destructive, action: onDisconnect) {
                            Label("Disconnect", systemImage: "link.badge.minus")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .frame(width: 32, height: 32)
                    }
                }
            }
        }
    }
}

// MARK: - Platform Connect Button
struct PlatformConnectButton: View {
    let platform: SocialPlatform
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: .spacingM) {
                Image(systemName: platform.icon)
                    .font(.title3)
                    .foregroundColor(Color(hex: platform.brandColor))
                    .frame(width: 40, height: 40)
                    .background(Color(hex: platform.brandColor).opacity(0.1))
                    .cornerRadius(.radiusSmall)

                VStack(alignment: .leading, spacing: 2) {
                    Text(platform.displayName)
                        .font(.subhead)
                        .fontWeight(.medium)
                        .foregroundColor(.adaptiveTextPrimary())

                    Text(platform.requiresOAuth ? "Connect with OAuth" : "Verify handle")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundColor(.brandPrimary)
            }
            .padding(.spacingM)
            .background(Color.adaptiveSurface())
            .cornerRadius(.radiusMedium)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - OAuth Web View
struct OAuthWebView: View {
    let url: URL
    let platform: SocialPlatform
    let onComplete: (Bool) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack {
                if let error = errorMessage {
                    VStack(spacing: .spacingM) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.warning)
                        Text(error)
                            .font(.subhead)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            errorMessage = nil
                        }
                        .foregroundColor(.brandPrimary)
                    }
                    .padding()
                } else {
                    OAuthWebViewRepresentable(
                        url: url,
                        isLoading: $isLoading,
                        onCallback: { callbackURL in
                            handleCallback(callbackURL)
                        },
                        onError: { error in
                            errorMessage = error
                        }
                    )
                    .overlay {
                        if isLoading {
                            VStack(spacing: .spacingM) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                Text("Loading \(platform.displayName)...")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Connect \(platform.displayName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onComplete(false)
                    }
                }
            }
        }
    }

    private func handleCallback(_ url: URL) {
        let urlString = url.absoluteString.lowercased()

        // Check for success indicators
        // Backend redirects to: /dashboard.html?oauth=success&platform=twitter
        if urlString.contains("oauth=success") ||
           urlString.contains("/settings/social") ||
           urlString.contains("/social-accounts") ||
           urlString.contains("success=true") ||
           urlString.contains("connected=true") {
            onComplete(true)
            return
        }

        // Check for error indicators
        if urlString.contains("oauth=error") ||
           urlString.contains("error=") ||
           urlString.contains("denied") ||
           urlString.contains("cancelled") {
            onComplete(false)
            return
        }
    }
}

// MARK: - OAuth WebView Representable
import WebKit

struct OAuthWebViewRepresentable: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    let onCallback: (URL) -> Void
    let onError: (String) -> Void

    func makeUIView(context: Context) -> WKWebView {
        // Configure WebView with proper settings for OAuth
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()

        // Enable JavaScript
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        config.defaultWebpagePreferences = preferences

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        // Set a proper user agent to avoid being blocked
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"

        // Load the URL
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        webView.load(request)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: OAuthWebViewRepresentable

        init(_ parent: OAuthWebViewRepresentable) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false

                // Check if we're on a callback URL
                if let url = webView.url {
                    self.parent.onCallback(url)
                }
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.onError("Failed to load: \(error.localizedDescription)")
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                // Don't show error for cancelled navigations (user tapped a link)
                if (error as NSError).code != NSURLErrorCancelled {
                    self.parent.onError("Connection failed: \(error.localizedDescription)")
                }
            }
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                // Check for callback schemes
                if url.scheme == "formative" || url.absoluteString.contains("formative://") {
                    parent.onCallback(url)
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }
    }
}

#Preview {
    NavigationStack {
        SocialAccountsView()
    }
}
