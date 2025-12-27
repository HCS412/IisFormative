//
//  OpportunitiesListView.swift
//  FormativeiOS
//
//  Enhanced Opportunities List with Search and Filters
//

import SwiftUI

struct OpportunitiesListView: View {
    @StateObject private var viewModel = OpportunitiesViewModel()
    @State private var searchText = ""
    @State private var showFilters = false
    @State private var selectedSort: SortOption = .newest
    
    enum SortOption: String, CaseIterable {
        case newest = "Newest"
        case deadline = "Deadline"
        case budget = "Budget"
    }
    
    var filteredOpportunities: [Opportunity] {
        var opportunities = viewModel.opportunities
        
        // Search filter
        if !searchText.isEmpty {
            opportunities = opportunities.filter { opp in
                opp.title.localizedCaseInsensitiveContains(searchText) ||
                opp.description.localizedCaseInsensitiveContains(searchText) ||
                (opp.company?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Sort
        switch selectedSort {
        case .newest:
            opportunities.sort { $0.createdAt ?? "" > $1.createdAt ?? "" }
        case .deadline:
            opportunities.sort { ($0.deadline ?? "") < ($1.deadline ?? "") }
        case .budget:
            // Would need to parse budget string - simplified for now
            break
        }
        
        return opportunities
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.adaptiveBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search and Filter Bar
                    VStack(spacing: .spacingM) {
                        SearchBar(text: $searchText)
                        
                        HStack(spacing: .spacingS) {
                            // Sort Menu
                            Menu {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Button(action: {
                                        selectedSort = option
                                        Haptics.selection()
                                    }) {
                                        HStack {
                                            Text(option.rawValue)
                                            if selectedSort == option {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: .spacingS) {
                                    Image(systemName: "arrow.up.arrow.down")
                                    Text(selectedSort.rawValue)
                                }
                                .font(.subhead)
                                .foregroundColor(.adaptiveTextPrimary())
                                .padding(.spacingM)
                                .background(Color.adaptiveSurface())
                                .cornerRadius(.radiusSmall)
                            }
                            
                            // Filter Button
                            Button(action: {
                                Haptics.impact(.light)
                                showFilters = true
                            }) {
                                HStack(spacing: .spacingS) {
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                    Text("Filters")
                                }
                                .font(.subhead)
                                .foregroundColor(.adaptiveTextPrimary())
                                .padding(.spacingM)
                                .background(Color.adaptiveSurface())
                                .cornerRadius(.radiusSmall)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, .spacingL)
                    .padding(.top, .spacingM)
                    .padding(.bottom, .spacingS)
                    .background(Color.adaptiveBackground())
                    
                    // Opportunities List
                    if viewModel.isLoading && viewModel.opportunities.isEmpty {
                        ScrollView {
                            LazyVStack(spacing: .spacingM) {
                                ForEach(0..<5) { _ in
                                    SkeletonCard()
                                }
                            }
                            .padding(.spacingL)
                        }
                    } else if filteredOpportunities.isEmpty {
                        ScrollView {
                            EmptyStateView(
                                icon: searchText.isEmpty ? "briefcase" : "magnifyingglass",
                                title: searchText.isEmpty ? "No Opportunities Yet" : "No Results Found",
                                message: searchText.isEmpty
                                    ? "Check back soon for new opportunities that match your profile."
                                    : "Try adjusting your search or filters to find what you're looking for.",
                                actionTitle: searchText.isEmpty ? nil : "Clear Filters",
                                action: searchText.isEmpty ? nil : {
                                    searchText = ""
                                    showFilters = false
                                }
                            )
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: .spacingM) {
                                ForEach(filteredOpportunities) { opportunity in
                                    NavigationLink(destination: OpportunityDetailView(opportunity: opportunity)) {
                                        OpportunityCard(opportunity: opportunity)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.spacingL)
                        }
                    }
                }
            }
            .navigationTitle("Opportunities")
            .refreshable {
                await viewModel.loadOpportunities()
            }
            .sheet(isPresented: $showFilters) {
                FiltersSheet(
                    viewModel: viewModel,
                    isPresented: $showFilters
                )
            }
            .task {
                await viewModel.loadOpportunities()
            }
        }
    }
}

// MARK: - Opportunity Card
struct OpportunityCard: View {
    let opportunity: Opportunity
    @State private var isPressed = false
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: .spacingM) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: .spacingS) {
                        Text(opportunity.title)
                            .font(.headline)
                            .foregroundColor(.adaptiveTextPrimary())
                        
                        if let company = opportunity.company {
                            Text(company)
                                .font(.subhead)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    if let type = opportunity.type {
                        Text(type.uppercased())
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.brandPrimary)
                            .padding(.horizontal, .spacingS)
                            .padding(.vertical, 4)
                            .background(Color.brandPrimary.opacity(0.1))
                            .cornerRadius(.radiusSmall)
                    }
                }
                
                // Description Preview
                Text(opportunity.description)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
                
                // Details Row
                HStack(spacing: .spacingL) {
                    if let location = opportunity.location {
                        Label(location, systemImage: "location.fill")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    if let compensation = opportunity.compensation {
                        Label(compensation, systemImage: "dollarsign.circle.fill")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                // Deadline
                if let deadline = opportunity.deadline {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text("Deadline: \(deadline)")
                            .font(.caption)
                    }
                    .foregroundColor(.textSecondary)
                }
            }
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.springSnappy) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.springSnappy) {
                        isPressed = false
                    }
                }
        )
    }
}

// MARK: - Filters Sheet
struct FiltersSheet: View {
    @ObservedObject var viewModel: OpportunitiesViewModel
    @Binding var isPresented: Bool
    @State private var selectedType: String? = nil
    @State private var selectedIndustry: String? = nil
    @State private var minBudget: Double = 0
    @State private var maxBudget: Double = 100000
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Opportunity Type", selection: $selectedType) {
                        Text("All").tag(nil as String?)
                        Text("Full-time").tag("full-time" as String?)
                        Text("Part-time").tag("part-time" as String?)
                        Text("Contract").tag("contract" as String?)
                    }
                }
                
                Section("Budget Range") {
                    VStack {
                        HStack {
                            Text("$\(Int(minBudget))")
                            Spacer()
                            Text("$\(Int(maxBudget))")
                        }
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        
                        RangeSlider(
                            minValue: $minBudget,
                            maxValue: $maxBudget,
                            range: 0...100000
                        )
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        // Apply filters
                        isPresented = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Range Slider
struct RangeSlider: View {
    @Binding var minValue: Double
    @Binding var maxValue: Double
    let range: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)
                
                // Active range
                HStack {
                    Spacer()
                        .frame(width: CGFloat((minValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient.brand)
                        .frame(
                            width: CGFloat((maxValue - minValue) / (range.upperBound - range.lowerBound)) * geometry.size.width,
                            height: 4
                        )
                    
                    Spacer()
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let percentage = value.location.x / geometry.size.width
                        let newValue = range.lowerBound + percentage * (range.upperBound - range.lowerBound)
                        
                        if abs(newValue - minValue) < abs(newValue - maxValue) {
                            minValue = max(range.lowerBound, min(newValue, maxValue - 1000))
                        } else {
                            maxValue = min(range.upperBound, max(newValue, minValue + 1000))
                        }
                    }
            )
        }
        .frame(height: 44)
    }
}

#Preview {
    OpportunitiesListView()
}
