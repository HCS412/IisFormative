//
//  TeamsListView.swift
//  FormativeiOS
//
//  Teams List View
//

import SwiftUI
import Combine

struct TeamsListView: View {
    @StateObject private var viewModel = TeamsViewModel()
    @State private var showCreateTeam = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.adaptiveBackground()
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.teams.isEmpty {
                    ProgressView()
                } else if viewModel.teams.isEmpty && viewModel.invitations.isEmpty {
                    EmptyStateView(
                        icon: "person.2",
                        title: "No Teams Yet",
                        message: "Create a team or accept an invitation to get started.",
                        actionTitle: "Create Team",
                        action: { showCreateTeam = true }
                    )
                } else {
                    ScrollView {
                        VStack(spacing: .spacing2XL) {
                            // Invitations
                            if !viewModel.invitations.isEmpty {
                                invitationsSection
                                    .padding(.horizontal, .spacingL)
                                    .padding(.top, .spacingL)
                            }
                            
                            // My Teams
                            if !viewModel.teams.isEmpty {
                                teamsSection
                                    .padding(.horizontal, .spacingL)
                            }
                        }
                        .padding(.bottom, .spacing5XL)
                    }
                }
            }
            .navigationTitle("Teams")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showCreateTeam = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateTeam) {
                CreateTeamView()
            }
            .refreshable {
                await viewModel.loadTeams()
            }
            .task {
                await viewModel.loadTeams()
            }
        }
    }
    
    // MARK: - Invitations Section
    private var invitationsSection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Pending Invitations")
                .font(.headline)
                .foregroundColor(.adaptiveTextPrimary())
            
            ForEach(viewModel.invitations) { invitation in
                TeamInvitationCard(invitation: invitation, viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Teams Section
    private var teamsSection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("My Teams")
                .font(.headline)
                .foregroundColor(.adaptiveTextPrimary())
            
            ForEach(viewModel.teams) { team in
                NavigationLink(destination: TeamDetailView(team: team)) {
                    TeamCard(team: team)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Team Card
struct TeamCard: View {
    let team: Team
    
    var body: some View {
        GlassCard {
            HStack(spacing: .spacingM) {
                // Logo
                AsyncImage(url: URL(string: team.logo ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(LinearGradient.brand)
                        .overlay(
                            Text(String(team.name.prefix(1)))
                                .font(.headline)
                                .foregroundColor(.white)
                        )
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(team.name)
                        .font(.headline)
                        .foregroundColor(.adaptiveTextPrimary())
                    
                    Text("\(team.members.count) members")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

// MARK: - Team Invitation Card
struct TeamInvitationCard: View {
    let invitation: TeamInvitation
    @ObservedObject var viewModel: TeamsViewModel
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: .spacingM) {
                Text(invitation.teamName)
                    .font(.headline)
                    .foregroundColor(.adaptiveTextPrimary())
                
                Text("\(invitation.inviterName) invited you to join this team")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                HStack(spacing: .spacingM) {
                    SecondaryButton(title: "Decline", action: {
                        Task {
                            await viewModel.declineInvitation(invitation.id)
                        }
                    })
                    
                    PrimaryButton(title: "Accept", action: {
                        Task {
                            await viewModel.acceptInvitation(invitation.id)
                        }
                    })
                }
            }
        }
    }
}

// MARK: - Team Detail View
struct TeamDetailView: View {
    let team: Team
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacing2XL) {
                // Header
                VStack(alignment: .leading, spacing: .spacingM) {
                    AsyncImage(url: URL(string: team.logo ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(LinearGradient.brand)
                            .overlay(
                                Text(String(team.name.prefix(1)))
                                    .font(.title1)
                                    .foregroundColor(.white)
                            )
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    
                    Text(team.name)
                        .font(.title1)
                        .fontWeight(.bold)
                    
                    if let description = team.description {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(.horizontal, .spacingL)
                .padding(.top, .spacingL)
                
                // Members
                membersSection
                    .padding(.horizontal, .spacingL)
            }
        }
        .background(Color.adaptiveBackground())
        .navigationTitle("Team")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var membersSection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Members")
                .font(.headline)
                .foregroundColor(.adaptiveTextPrimary())
            
            ForEach(team.members) { member in
                MemberRow(member: member)
            }
        }
    }
}

// MARK: - Member Row
struct MemberRow: View {
    let member: TeamMember
    
    var body: some View {
        HStack(spacing: .spacingM) {
            Circle()
                .fill(LinearGradient.brand)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(member.user?.username ?? member.user?.email ?? "Member")
                    .font(.subhead)
                    .fontWeight(.semibold)
                
                Text(member.role.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
        .padding(.spacingM)
        .background(Color.adaptiveSurface())
        .cornerRadius(.radiusMedium)
    }
}

// MARK: - Create Team View
struct CreateTeamView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var selectedType: TeamType = .creatorCollective
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Team Information") {
                    TextField("Team Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Team Type") {
                    Picker("Type", selection: $selectedType) {
                        Text("Brand").tag(TeamType.brand)
                        Text("Agency").tag(TeamType.agency)
                        Text("Creator Collective").tag(TeamType.creatorCollective)
                    }
                }
            }
            .navigationTitle("Create Team")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        // Create team
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Teams View Model
@MainActor
class TeamsViewModel: ObservableObject {
    @Published var teams: [Team] = []
    @Published var invitations: [TeamInvitation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    func loadTeams() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Mock data - replace with actual API calls
            teams = []
            invitations = []
        } catch {
            errorMessage = "Failed to load teams: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func acceptInvitation(_ invitationId: String) async {
        // API call to accept invitation
        await loadTeams()
    }
    
    func declineInvitation(_ invitationId: String) async {
        // API call to decline invitation
        await loadTeams()
    }
}

#Preview {
    TeamsListView()
}

