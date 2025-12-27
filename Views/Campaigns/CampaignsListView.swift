//
//  CampaignsListView.swift
//  FormativeiOS
//
//  Campaigns List View
//

import SwiftUI
import Combine

struct CampaignsListView: View {
    @StateObject private var viewModel = CampaignsViewModel()
    @State private var selectedSegment: CampaignSegment = .active
    
    enum CampaignSegment: String, CaseIterable {
        case active = "Active"
        case completed = "Completed"
        case draft = "Draft"
    }
    
    var filteredCampaigns: [Campaign] {
        viewModel.campaigns.filter { campaign in
            switch selectedSegment {
            case .active:
                return campaign.status == .active
            case .completed:
                return campaign.status == .completed
            case .draft:
                return campaign.status == .draft
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented Control
                Picker("Campaigns", selection: $selectedSegment) {
                    ForEach(CampaignSegment.allCases, id: \.self) { segment in
                        Text(segment.rawValue).tag(segment)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.spacingL)
                
                // Campaigns List
                if viewModel.isLoading && viewModel.campaigns.isEmpty {
                    ProgressView()
                } else if filteredCampaigns.isEmpty {
                    ScrollView {
                        EmptyStateView(
                            icon: "megaphone",
                            title: "No \(selectedSegment.rawValue) Campaigns",
                            message: "You don't have any \(selectedSegment.rawValue.lowercased()) campaigns yet.",
                            actionTitle: selectedSegment == .draft ? "Create Campaign" : nil,
                            action: selectedSegment == .draft ? {} : nil
                        )
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: .spacingM) {
                            ForEach(filteredCampaigns) { campaign in
                                NavigationLink(destination: CampaignDetailView(campaign: campaign)) {
                                    CampaignCard(campaign: campaign)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.spacingL)
                    }
                }
            }
            .background(Color.adaptiveBackground())
            .navigationTitle("Campaigns")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {}) {
                        Image(systemName: "plus")
                    }
                }
            }
            .refreshable {
                await viewModel.loadCampaigns()
            }
            .task {
                await viewModel.loadCampaigns()
            }
        }
    }
}

// MARK: - Campaign Card
struct CampaignCard: View {
    let campaign: Campaign
    @State private var isPressed = false
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: .spacingM) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: .spacingS) {
                        Text(campaign.title)
                            .font(.headline)
                            .foregroundColor(.adaptiveTextPrimary())
                        
                        if let brandName = campaign.brandName {
                            Text(brandName)
                                .font(.subhead)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    StatusBadge(status: campaign.status)
                }
                
                // Progress
                if let milestones = campaign.milestones, !milestones.isEmpty {
                    VStack(alignment: .leading, spacing: .spacingS) {
                        HStack {
                            Text("Progress")
                                .font(.caption)
                            Spacer()
                            Text("\(completedMilestones)/\(milestones.count) milestones")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(LinearGradient.brand)
                                    .frame(
                                        width: geometry.size.width * progress,
                                        height: 8
                                    )
                            }
                        }
                        .frame(height: 8)
                    }
                }
                
                // Budget
                if let budget = campaign.budget {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.success)
                        Text(formatCurrency(budget))
                            .font(.subhead)
                            .foregroundColor(.adaptiveTextPrimary())
                    }
                }
            }
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
    }
    
    private var completedMilestones: Int {
        campaign.milestones?.filter { $0.isCompleted }.count ?? 0
    }
    
    private var progress: Double {
        guard let milestones = campaign.milestones, !milestones.isEmpty else { return 0 }
        return Double(completedMilestones) / Double(milestones.count)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: CampaignStatus
    
    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, .spacingS)
            .padding(.vertical, 4)
            .background(statusColor)
            .cornerRadius(.radiusSmall)
    }
    
    private var statusColor: Color {
        switch status {
        case .active: return .success
        case .completed: return .brandPrimary
        case .draft: return .textSecondary
        case .cancelled: return .error
        }
    }
}

// MARK: - Campaign Detail View
struct CampaignDetailView: View {
    let campaign: Campaign
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacing2XL) {
                // Header
                VStack(alignment: .leading, spacing: .spacingM) {
                    Text(campaign.title)
                        .font(.title1)
                        .fontWeight(.bold)
                    
                    if let brandName = campaign.brandName {
                        Text(brandName)
                            .font(.title3)
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(.horizontal, .spacingL)
                .padding(.top, .spacingL)
                
                // Milestones
                if let milestones = campaign.milestones {
                    milestonesSection(milestones: milestones)
                        .padding(.horizontal, .spacingL)
                }
                
                // Deliverables
                if let deliverables = campaign.deliverables {
                    deliverablesSection(deliverables: deliverables)
                        .padding(.horizontal, .spacingL)
                }
            }
        }
        .background(Color.adaptiveBackground())
        .navigationTitle("Campaign")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func milestonesSection(milestones: [Milestone]) -> some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Milestones")
                .font(.headline)
                .foregroundColor(.adaptiveTextPrimary())
            
            ForEach(milestones) { milestone in
                MilestoneRow(milestone: milestone)
            }
        }
    }
    
    private func deliverablesSection(deliverables: [Deliverable]) -> some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Deliverables")
                .font(.headline)
                .foregroundColor(.adaptiveTextPrimary())
            
            ForEach(deliverables) { deliverable in
                DeliverableRow(deliverable: deliverable)
            }
        }
    }
}

// MARK: - Milestone Row
struct MilestoneRow: View {
    let milestone: Milestone
    
    var body: some View {
        HStack(alignment: .top, spacing: .spacingM) {
            Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(milestone.isCompleted ? .success : .textSecondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(milestone.title)
                    .font(.subhead)
                    .fontWeight(.semibold)
                    .foregroundColor(.adaptiveTextPrimary())
                
                if let description = milestone.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
        }
        .padding(.spacingM)
        .background(Color.adaptiveSurface())
        .cornerRadius(.radiusMedium)
    }
}

// MARK: - Deliverable Row
struct DeliverableRow: View {
    let deliverable: Deliverable
    
    var body: some View {
        HStack {
            Image(systemName: deliverable.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(deliverable.isCompleted ? .success : .textSecondary)
            
            Text(deliverable.title)
                .font(.subhead)
                .foregroundColor(.adaptiveTextPrimary())
            
            Spacer()
        }
        .padding(.spacingM)
        .background(Color.adaptiveSurface())
        .cornerRadius(.radiusMedium)
    }
}

// MARK: - Campaigns View Model
@MainActor
class CampaignsViewModel: ObservableObject {
    @Published var campaigns: [Campaign] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    func loadCampaigns() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Mock data - replace with actual API call
            campaigns = []
        } catch {
            errorMessage = "Failed to load campaigns: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

#Preview {
    CampaignsListView()
}

