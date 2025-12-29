//
//  ApplicationsViewModel.swift
//  FormativeiOS
//
//  ViewModel for managing job applications
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ApplicationsViewModel: ObservableObject {
    @Published var applications: [Application] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSubmitting = false

    private let apiClient = APIClient.shared

    // MARK: - Load User's Applications
    func loadApplications() async {
        isLoading = true
        errorMessage = nil

        do {
            let response: ApplicationsResponse = try await apiClient.request(
                endpoint: "/applications"
            )
            applications = response.applications
        } catch let error as APIError {
            if case .httpError(let code) = error, code == 404 {
                // Endpoint might not exist yet
                applications = []
            } else {
                errorMessage = "Failed to load applications"
            }
        } catch {
            applications = []
        }

        isLoading = false
    }

    // MARK: - Submit Application
    func submitApplication(
        opportunityId: Int,
        message: String,
        proposedRate: String?,
        portfolioLinks: [String]?
    ) async -> Bool {
        isSubmitting = true
        errorMessage = nil

        do {
            let request = SubmitApplicationRequest(
                message: message,
                coverLetter: message, // Using message as cover letter too
                proposedRate: proposedRate,
                portfolioLinks: portfolioLinks
            )

            let body = try JSONEncoder().encode(request)

            let _: ApplicationResponse = try await apiClient.request(
                endpoint: "/opportunities/\(opportunityId)/apply",
                method: "POST",
                body: body
            )

            isSubmitting = false
            return true
        } catch let error as APIError {
            switch error {
            case .httpError(let code):
                if code == 400 {
                    errorMessage = "You may have already applied to this opportunity"
                } else if code == 401 {
                    errorMessage = "Please log in to apply"
                } else {
                    errorMessage = "Failed to submit application"
                }
            default:
                errorMessage = "Failed to submit application"
            }
            isSubmitting = false
            return false
        } catch {
            errorMessage = "Failed to submit application"
            isSubmitting = false
            return false
        }
    }

    // MARK: - Withdraw Application
    func withdrawApplication(applicationId: Int) async -> Bool {
        do {
            let _: ApplicationResponse = try await apiClient.request(
                endpoint: "/applications/\(applicationId)/withdraw",
                method: "POST"
            )

            // Remove from local list
            applications.removeAll { $0.id == applicationId }
            return true
        } catch {
            errorMessage = "Failed to withdraw application"
            return false
        }
    }

    // MARK: - Filter Applications
    var pendingApplications: [Application] {
        applications.filter { $0.status == "pending" || $0.status == "reviewing" }
    }

    var acceptedApplications: [Application] {
        applications.filter { $0.status == "accepted" }
    }

    var rejectedApplications: [Application] {
        applications.filter { $0.status == "rejected" }
    }
}
