//
//  ContentView.swift
//  FormativeiOS
//
//  Created on [Date]
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("hasVerifiedAge") private var hasVerifiedAge = false

    var body: some View {
        Group {
            if !hasVerifiedAge {
                AgeVerificationView(hasVerifiedAge: $hasVerifiedAge)
            } else if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                NavigationStack {
                    LoginView()
                }
            }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    @AppStorage("hasRequestedNotifications") private var hasRequestedNotifications = false
    @State private var showNotificationPermission = false

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)

            OpportunitiesListView()
                .tabItem {
                    Label("Opportunities", systemImage: "briefcase.fill")
                }
                .tag(1)

            ConversationsListView()
                .tabItem {
                    Label("Messages", systemImage: "message.fill")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .onAppear {
            if !hasRequestedNotifications {
                // Delay showing notification prompt for better UX
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showNotificationPermission = true
                }
            }
        }
        .fullScreenCover(isPresented: $showNotificationPermission) {
            NotificationPermissionView(isPresented: $showNotificationPermission)
                .onDisappear {
                    hasRequestedNotifications = true
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
