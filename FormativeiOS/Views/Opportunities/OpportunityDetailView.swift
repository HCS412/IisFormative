//
//  OpportunityDetailView.swift
//  FormativeiOS
//
//  Enhanced Opportunity Detail View
//

import SwiftUI

struct OpportunityDetailView: View {
    let opportunity: Opportunity
    @State private var showApplySheet = false
    @State private var isDescriptionExpanded = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showHeader = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: .spacing2XL) {
                    // Hero Section
                    heroSection
                        .padding(.horizontal, .spacingL)
                        .padding(.top, .spacingL)

                    // Details Section
                    detailsSection
                        .padding(.horizontal, .spacingL)

                    // Description Section
                    descriptionSection
                        .padding(.horizontal, .spacingL)

                    // Requirements Section
                    if let requirements = opportunity.requirements, !requirements.isEmpty {
                        requirementsSection(requirements: requirements)
                            .padding(.horizontal, .spacingL)
                    }

                    // Brand Preview Card
                    if opportunity.createdByName != nil {
                        brandPreviewSection
                            .padding(.horizontal, .spacingL)
                    }

                    // Spacer for floating button
                    Spacer(minLength: 100)
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
                withAnimation(.springSmooth) {
                    showHeader = scrollOffset < -50
                }
            }

            // Floating Apply Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton(icon: "paperplane.fill", action: {
                        Haptics.impact(.medium)
                        showApplySheet = true
                    })
                    .padding(.trailing, .spacingL)
                    .padding(.bottom, .spacingL)
                }
            }
        }
        .background(Color.adaptiveBackground())
        .navigationTitle(showHeader ? opportunity.title : "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    Haptics.selection()
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showApplySheet) {
            ApplyToOpportunityView(opportunityId: opportunity.id)
        }
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: .spacingS) {
                    Text(opportunity.title)
                        .font(.title1)
                        .fontWeight(.bold)
                        .foregroundColor(.adaptiveTextPrimary())

                    HStack(spacing: .spacingS) {
                        if let industry = opportunity.industry {
                            Text(industry.capitalized)
                                .font(.title3)
                                .foregroundColor(.textSecondary)
                        }
                        if opportunity.createdByName != nil {
                            Text("• \(opportunity.companyName)")
                                .font(.title3)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }

                Spacer()

                if let type = opportunity.type {
                    Text(type.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, .spacingM)
                        .padding(.vertical, .spacingS)
                        .background(LinearGradient.brand)
                        .cornerRadius(.radiusSmall)
                }
            }

            // Quick Info Row
            HStack(spacing: .spacingL) {
                if opportunity.isRemote == true {
                    Label("Remote", systemImage: "wifi")
                        .font(.subhead)
                        .foregroundColor(.success)
                } else if let location = opportunity.location {
                    Label(location, systemImage: "location.fill")
                        .font(.subhead)
                        .foregroundColor(.textSecondary)
                }

                Label(opportunity.budget, systemImage: "dollarsign.circle.fill")
                    .font(.subhead)
                    .foregroundColor(.textSecondary)
            }
        }
    }

    // MARK: - Details Section
    private var detailsSection: some View {
        GlassCard {
            VStack(spacing: .spacingM) {
                if let deadline = opportunity.deadline {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.brandPrimary)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Deadline")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                            Text(deadline)
                                .font(.subhead)
                                .fontWeight(.semibold)
                                .foregroundColor(.adaptiveTextPrimary())
                        }
                        Spacer()
                    }
                    Divider()
                }

                if let type = opportunity.type {
                    HStack {
                        Image(systemName: "briefcase.fill")
                            .foregroundColor(.brandPrimary)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Type")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                            Text(type.capitalized)
                                .font(.subhead)
                                .fontWeight(.semibold)
                                .foregroundColor(.adaptiveTextPrimary())
                        }
                        Spacer()
                    }
                    Divider()
                }

                if let industry = opportunity.industry {
                    HStack {
                        Image(systemName: "building.2.fill")
                            .foregroundColor(.brandPrimary)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Industry")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                            Text(industry.capitalized)
                                .font(.subhead)
                                .fontWeight(.semibold)
                                .foregroundColor(.adaptiveTextPrimary())
                        }
                        Spacer()
                    }
                }
            }
        }
    }

    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Button(action: {
                withAnimation(.springSmooth) {
                    isDescriptionExpanded.toggle()
                }
                Haptics.selection()
            }) {
                HStack {
                    Text("Description")
                        .font(.headline)
                        .foregroundColor(.adaptiveTextPrimary())

                    Spacer()

                    Image(systemName: isDescriptionExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            .buttonStyle(.plain)

            if isDescriptionExpanded {
                Text(opportunity.description)
                    .font(.body)
                    .foregroundColor(.adaptiveTextPrimary())
                    .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                Text(opportunity.description)
                    .font(.body)
                    .foregroundColor(.adaptiveTextPrimary())
                    .lineLimit(3)
            }
        }
    }

    // MARK: - Requirements Section
    private func requirementsSection(requirements: [String]) -> some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Requirements")
                .font(.headline)
                .foregroundColor(.adaptiveTextPrimary())

            GlassCard {
                VStack(alignment: .leading, spacing: .spacingM) {
                    ForEach(Array(requirements.enumerated()), id: \.offset) { index, requirement in
                        HStack(alignment: .top, spacing: .spacingM) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.success)
                                .font(.subhead)

                            Text(requirement)
                                .font(.body)
                                .foregroundColor(.adaptiveTextPrimary())

                            Spacer()
                        }

                        if index < requirements.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Brand Preview
    private var brandPreviewSection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Posted by")
                .font(.headline)
                .foregroundColor(.adaptiveTextPrimary())

            GlassCard {
                HStack(spacing: .spacingM) {
                    Circle()
                        .fill(LinearGradient.brand)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text(String(opportunity.companyName.prefix(1)))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(opportunity.companyName)
                            .font(.headline)
                            .foregroundColor(.adaptiveTextPrimary())

                        Text("Verified")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }

                    Spacer()
                }
            }
        }
    }
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Apply View
struct ApplyToOpportunityView: View {
    let opportunityId: Int
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ApplicationsViewModel()
    @State private var message = ""
    @State private var proposedRate = ""
    @State private var portfolioLinks: [String] = []
    @State private var newLink = ""
    @State private var showSuccess = false
    @State private var showError = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .spacing2XL) {
                    // Cover Message
                    VStack(alignment: .leading, spacing: .spacingM) {
                        Text("Cover Message")
                            .font(.headline)
                            .foregroundColor(.adaptiveTextPrimary())

                        TextEditor(text: $message)
                            .frame(minHeight: 150)
                            .padding(.spacingM)
                            .background(Color.adaptiveSurface())
                            .cornerRadius(.radiusSmall)
                            .overlay(
                                RoundedRectangle(cornerRadius: .radiusSmall)
                                    .stroke(Color.separator, lineWidth: 1)
                            )

                        Text("\(message.count) / 500")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.horizontal, .spacingL)
                    .padding(.top, .spacingL)

                    // Proposed Rate
                    VStack(alignment: .leading, spacing: .spacingM) {
                        Text("Proposed Rate (Optional)")
                            .font(.headline)
                            .foregroundColor(.adaptiveTextPrimary())

                        FormTextField(
                            title: "Rate",
                            text: $proposedRate,
                            placeholder: "$0.00",
                            icon: "dollarsign.circle.fill",
                            keyboardType: .decimalPad
                        )
                    }
                    .padding(.horizontal, .spacingL)

                    // Portfolio Links
                    VStack(alignment: .leading, spacing: .spacingM) {
                        Text("Portfolio Links (Optional)")
                            .font(.headline)
                            .foregroundColor(.adaptiveTextPrimary())

                        ForEach(portfolioLinks, id: \.self) { link in
                            HStack {
                                Text(link)
                                    .font(.subhead)
                                    .lineLimit(1)
                                Spacer()
                                Button(action: {
                                    portfolioLinks.removeAll { $0 == link }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.error)
                                }
                            }
                            .padding(.spacingM)
                            .background(Color.adaptiveSurface())
                            .cornerRadius(.radiusSmall)
                        }

                        HStack {
                            TextField("Add portfolio link", text: $newLink)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.none)
                                .keyboardType(.URL)

                            Button(action: {
                                if !newLink.isEmpty {
                                    portfolioLinks.append(newLink)
                                    newLink = ""
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.brandPrimary)
                            }
                        }
                    }
                    .padding(.horizontal, .spacingL)
                }
                .padding(.bottom, .spacing5XL)
            }
            .background(Color.adaptiveBackground())
            .navigationTitle("Apply")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(viewModel.isSubmitting)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isSubmitting {
                        ProgressView()
                    } else {
                        Button("Submit") {
                            submitApplication()
                        }
                        .disabled(message.isEmpty)
                        .fontWeight(.semibold)
                    }
                }
            }
            .overlay {
                if showSuccess {
                    SuccessOverlay {
                        dismiss()
                    }
                }
            }
            .alert("Application Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Failed to submit application")
            }
        }
    }

    private func submitApplication() {
        Task {
            let success = await viewModel.submitApplication(
                opportunityId: opportunityId,
                message: message,
                proposedRate: proposedRate.isEmpty ? nil : proposedRate,
                portfolioLinks: portfolioLinks.isEmpty ? nil : portfolioLinks
            )

            if success {
                Haptics.notification(.success)
                showSuccess = true
            } else {
                Haptics.notification(.error)
                showError = true
            }
        }
    }
}

// MARK: - Success Overlay
struct SuccessOverlay: View {
    let onDismiss: () -> Void
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: .spacingXL) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.success)
                    .scaleEffect(scale)
                    .opacity(opacity)

                Text("Application Submitted!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.adaptiveTextPrimary())
            }
            .padding(.spacing5XL)
            .background(Color.adaptiveSurface())
            .cornerRadius(.radiusLarge)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.springBouncy) {
                scale = 1.0
                opacity = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInExit) {
                    opacity = 0
                }
                onDismiss()
            }
        }
    }
}

#Preview {
    NavigationStack {
        OpportunityDetailView(opportunity: Opportunity(
            id: 1,
            title: "Social Media Manager",
            description: "We are looking for an experienced social media manager to join our team.",
            type: "influencer",
            industry: "technology",
            budgetRange: "$500-$2000",
            budgetMin: 500,
            budgetMax: 2000,
            createdBy: 1,
            createdByName: "Tech Startup Inc",
            status: "active",
            requirements: ["3+ years experience", "Strong writing skills"],
            platforms: nil,
            deadline: "2024-12-31",
            location: nil,
            isRemote: true,
            createdAt: nil,
            updatedAt: nil
        ))
    }
}
