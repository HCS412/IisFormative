//
//  LegalViews.swift
//  FormativeiOS
//
//  Privacy Policy, Terms of Service, and Community Guidelines
//

import SwiftUI

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacingXL) {
                Text("Privacy Policy")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.adaptiveTextPrimary())

                Text("Last Updated: December 2024")
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                Group {
                    sectionHeader("1. Information We Collect")
                    sectionText("""
                    We collect information you provide directly to us, including:

                    • Account Information: When you create an account, we collect your name, email address, password, and account type (creator, brand, or agency).

                    • Profile Information: Information you add to your profile such as bio, location, website, social media links, and profile photos.

                    • Content: Any content you create, upload, or share through the platform, including messages, applications, media kit information, and shop listings.

                    • Communications: When you contact us or communicate with other users through our platform.

                    • Usage Data: Information about how you interact with our services, including access times, pages viewed, and features used.
                    """)

                    sectionHeader("2. How We Use Your Information")
                    sectionText("""
                    We use the information we collect to:

                    • Provide, maintain, and improve our services
                    • Process transactions and send related information
                    • Connect creators with brands and facilitate collaborations
                    • Send you technical notices, updates, and support messages
                    • Respond to your comments, questions, and requests
                    • Monitor and analyze trends, usage, and activities
                    • Detect, investigate, and prevent fraudulent transactions and abuse
                    • Personalize and improve your experience
                    """)

                    sectionHeader("3. Information Sharing")
                    sectionText("""
                    We may share your information in the following circumstances:

                    • With other users as part of the platform's core functionality (e.g., when you apply to opportunities or send messages)
                    • With service providers who perform services on our behalf
                    • In response to legal process or government requests
                    • To protect the rights, privacy, safety, or property of Formative, our users, or the public
                    • In connection with a merger, acquisition, or sale of assets

                    We do not sell your personal information to third parties.
                    """)
                }

                Group {
                    sectionHeader("4. Data Security")
                    sectionText("""
                    We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. This includes:

                    • Encryption of data in transit and at rest
                    • Secure authentication mechanisms including two-factor authentication
                    • Regular security assessments and updates
                    • Limited access to personal information by employees
                    """)

                    sectionHeader("5. Data Retention")
                    sectionText("""
                    We retain your information for as long as your account is active or as needed to provide you services. You may request deletion of your account and associated data at any time through the app settings.

                    Upon account deletion, we will delete or anonymize your personal information within 30 days, except where we are required to retain it for legal purposes.
                    """)

                    sectionHeader("6. Your Rights")
                    sectionText("""
                    You have the right to:

                    • Access the personal information we hold about you
                    • Correct inaccurate or incomplete information
                    • Delete your account and personal information
                    • Export your data in a portable format
                    • Opt out of marketing communications
                    • Withdraw consent where processing is based on consent

                    To exercise these rights, please contact us or use the relevant features in the app settings.
                    """)

                    sectionHeader("7. Children's Privacy")
                    sectionText("""
                    Our services are not intended for users under the age of 13. We do not knowingly collect personal information from children under 13. If we become aware that we have collected personal information from a child under 13, we will take steps to delete such information.
                    """)

                    sectionHeader("8. Changes to This Policy")
                    sectionText("""
                    We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.
                    """)

                    sectionHeader("9. Contact Us")
                    sectionText("""
                    If you have any questions about this Privacy Policy, please contact us at:

                    Email: privacy@formative.app
                    """)
                }
            }
            .padding(.spacingL)
            .padding(.bottom, .spacing5XL)
        }
        .background(Color.adaptiveBackground())
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.adaptiveTextPrimary())
            .padding(.top, .spacingM)
    }

    private func sectionText(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.adaptiveTextPrimary())
            .lineSpacing(4)
    }
}

// MARK: - Terms of Service View
struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacingXL) {
                Text("Terms of Service")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.adaptiveTextPrimary())

                Text("Last Updated: December 2024")
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                Group {
                    sectionHeader("1. Acceptance of Terms")
                    sectionText("""
                    By accessing or using Formative, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our services.
                    """)

                    sectionHeader("2. Description of Service")
                    sectionText("""
                    Formative is a platform that connects content creators with brands and agencies for collaboration opportunities. We provide tools for:

                    • Discovering and applying to collaboration opportunities
                    • Creating and sharing media kits
                    • Messaging and communication between users
                    • Managing creator shops and services
                    """)

                    sectionHeader("3. User Accounts")
                    sectionText("""
                    To use certain features of our service, you must create an account. You agree to:

                    • Provide accurate and complete information
                    • Maintain the security of your account credentials
                    • Promptly update any information that changes
                    • Accept responsibility for all activities under your account
                    • Notify us immediately of any unauthorized use
                    """)

                    sectionHeader("4. User Conduct")
                    sectionText("""
                    You agree not to:

                    • Violate any applicable laws or regulations
                    • Infringe on the rights of others
                    • Post false, misleading, or fraudulent content
                    • Harass, threaten, or intimidate other users
                    • Upload malicious code or attempt to hack our systems
                    • Use the service for any illegal purpose
                    • Circumvent any access restrictions or security measures
                    """)

                    sectionHeader("5. Content")
                    sectionText("""
                    You retain ownership of content you create and share on Formative. By posting content, you grant us a non-exclusive, worldwide, royalty-free license to use, display, and distribute your content in connection with operating and promoting the service.

                    You are solely responsible for your content and the consequences of posting it.
                    """)
                }

                Group {
                    sectionHeader("6. Prohibited Content")
                    sectionText("""
                    The following content is prohibited:

                    • Sexually explicit or pornographic material
                    • Content promoting violence or hatred
                    • Illegal content or content promoting illegal activities
                    • Content that infringes intellectual property rights
                    • Spam, malware, or deceptive content
                    • Personal information of others without consent

                    We reserve the right to remove any content that violates these terms.
                    """)

                    sectionHeader("7. Termination")
                    sectionText("""
                    We may terminate or suspend your account at any time for violations of these terms or for any other reason at our discretion. You may also delete your account at any time through the app settings.
                    """)

                    sectionHeader("8. Disclaimers")
                    sectionText("""
                    THE SERVICE IS PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND. WE DO NOT GUARANTEE THAT THE SERVICE WILL BE UNINTERRUPTED, SECURE, OR ERROR-FREE.

                    We are not responsible for the conduct of users or the content they post. Any transactions between users are solely between those parties.
                    """)

                    sectionHeader("9. Limitation of Liability")
                    sectionText("""
                    TO THE MAXIMUM EXTENT PERMITTED BY LAW, FORMATIVE SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES ARISING FROM YOUR USE OF THE SERVICE.
                    """)

                    sectionHeader("10. Changes to Terms")
                    sectionText("""
                    We may modify these terms at any time. Continued use of the service after changes constitutes acceptance of the modified terms.
                    """)

                    sectionHeader("11. Contact")
                    sectionText("""
                    For questions about these Terms of Service, contact us at:

                    Email: legal@formative.app
                    """)
                }
            }
            .padding(.spacingL)
            .padding(.bottom, .spacing5XL)
        }
        .background(Color.adaptiveBackground())
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.adaptiveTextPrimary())
            .padding(.top, .spacingM)
    }

    private func sectionText(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.adaptiveTextPrimary())
            .lineSpacing(4)
    }
}

// MARK: - Community Guidelines View
struct CommunityGuidelinesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacingXL) {
                Text("Community Guidelines")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.adaptiveTextPrimary())

                Text("Last Updated: December 2024")
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                sectionText("""
                Formative is a professional platform for creators and brands to connect and collaborate. To maintain a safe and productive environment, all users must follow these guidelines.
                """)

                Group {
                    sectionHeader("Be Respectful")
                    sectionText("""
                    • Treat all users with respect and professionalism
                    • Do not harass, bully, or intimidate others
                    • Avoid discriminatory language or behavior
                    • Respect different opinions and perspectives
                    """)

                    sectionHeader("Be Authentic")
                    sectionText("""
                    • Use your real identity and accurate information
                    • Do not impersonate others or create fake accounts
                    • Be honest about your capabilities and experience
                    • Only share content you have rights to use
                    """)

                    sectionHeader("Be Professional")
                    sectionText("""
                    • Communicate professionally in all interactions
                    • Honor commitments and agreements
                    • Respond to messages and applications promptly
                    • Provide constructive feedback when appropriate
                    """)

                    sectionHeader("Keep It Safe")
                    sectionText("""
                    • Do not share personal information publicly
                    • Report suspicious or inappropriate behavior
                    • Do not engage in illegal activities
                    • Protect your account credentials
                    """)
                }

                Group {
                    sectionHeader("Prohibited Content")
                    sectionText("""
                    The following content is strictly prohibited:

                    🚫 Nudity or sexually explicit content
                    🚫 Violence, gore, or graphic content
                    🚫 Hate speech or discrimination
                    🚫 Harassment or bullying
                    🚫 Illegal activities or substances
                    🚫 Spam or misleading content
                    🚫 Malware or phishing attempts
                    🚫 Copyright infringement
                    🚫 Personal information of others
                    """)

                    sectionHeader("Reporting Violations")
                    sectionText("""
                    If you encounter content or behavior that violates these guidelines, please report it immediately using the report feature or by contacting us at:

                    Email: safety@formative.app

                    All reports are reviewed by our team and appropriate action will be taken.
                    """)

                    sectionHeader("Consequences")
                    sectionText("""
                    Violations of these guidelines may result in:

                    • Content removal
                    • Warning or temporary suspension
                    • Permanent account termination
                    • Legal action where appropriate

                    We reserve the right to take action at our discretion to protect our community.
                    """)

                    sectionHeader("Questions?")
                    sectionText("""
                    If you have questions about these guidelines, contact us at:

                    Email: support@formative.app
                    """)
                }
            }
            .padding(.spacingL)
            .padding(.bottom, .spacing5XL)
        }
        .background(Color.adaptiveBackground())
        .navigationTitle("Community Guidelines")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.adaptiveTextPrimary())
            .padding(.top, .spacingM)
    }

    private func sectionText(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.adaptiveTextPrimary())
            .lineSpacing(4)
    }
}

// MARK: - Compact Legal Links (for Login/Register screens)
struct LegalLinksView: View {
    @State private var showPrivacyPolicy = false
    @State private var showTerms = false

    var body: some View {
        VStack(spacing: .spacingS) {
            Text("By continuing, you agree to our")
                .font(.caption)
                .foregroundColor(.textSecondary)

            HStack(spacing: 4) {
                Button("Terms of Service") {
                    showTerms = true
                }
                .font(.caption)
                .foregroundColor(.brandPrimary)

                Text("and")
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                Button("Privacy Policy") {
                    showPrivacyPolicy = true
                }
                .font(.caption)
                .foregroundColor(.brandPrimary)
            }
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            NavigationStack {
                PrivacyPolicyView()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") {
                                showPrivacyPolicy = false
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $showTerms) {
            NavigationStack {
                TermsOfServiceView()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") {
                                showTerms = false
                            }
                        }
                    }
            }
        }
    }
}

// MARK: - Report Content View
struct ReportContentView: View {
    let contentType: String
    let contentId: Int
    @Environment(\.dismiss) var dismiss

    @State private var selectedReason: ReportReason = .inappropriate
    @State private var additionalDetails = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Reason", selection: $selectedReason) {
                        ForEach(ReportReason.allCases, id: \.self) { reason in
                            Text(reason.displayName).tag(reason)
                        }
                    }
                } header: {
                    Text("Why are you reporting this \(contentType)?")
                }

                Section {
                    TextEditor(text: $additionalDetails)
                        .frame(minHeight: 100)
                } header: {
                    Text("Additional Details (Optional)")
                } footer: {
                    Text("Please provide any additional context that will help us review this report.")
                }

                Section {
                    Button(action: submitReport) {
                        HStack {
                            Spacer()
                            if isSubmitting {
                                ProgressView()
                            } else {
                                Text("Submit Report")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(isSubmitting)
                } footer: {
                    Text("False reports may result in action against your account. Reports are reviewed within 24 hours.")
                }
            }
            .navigationTitle("Report \(contentType.capitalized)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSubmitting)
                }
            }
            .alert("Report Submitted", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Thank you for helping keep Formative safe. We'll review your report and take appropriate action.")
            }
        }
    }

    private func submitReport() {
        isSubmitting = true
        // In a real app, this would call the API
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSubmitting = false
            showSuccess = true
            Haptics.notification(.success)
        }
    }
}

enum ReportReason: String, CaseIterable {
    case inappropriate = "inappropriate"
    case spam = "spam"
    case harassment = "harassment"
    case violence = "violence"
    case hateSpeech = "hate_speech"
    case falseInfo = "false_information"
    case copyright = "copyright"
    case other = "other"

    var displayName: String {
        switch self {
        case .inappropriate: return "Inappropriate Content"
        case .spam: return "Spam or Scam"
        case .harassment: return "Harassment or Bullying"
        case .violence: return "Violence or Threats"
        case .hateSpeech: return "Hate Speech"
        case .falseInfo: return "False Information"
        case .copyright: return "Copyright Violation"
        case .other: return "Other"
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
