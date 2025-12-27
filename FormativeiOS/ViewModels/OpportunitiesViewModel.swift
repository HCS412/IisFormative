//
//  OpportunitiesViewModel.swift
//  FormativeiOS
//
//  Created on [Date]
//

import Foundation
import SwiftUI
import Combine

@MainActor
class OpportunitiesViewModel: ObservableObject {
    @Published var opportunities: [Opportunity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    func loadOpportunities() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: OpportunitiesResponse = try await apiClient.request(
                endpoint: "/opportunities",
                method: "GET"
            )
            opportunities = response.opportunities
        } catch {
            errorMessage = "Failed to load opportunities: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

