//
//  FormativeiOSApp.swift
//  FormativeiOS
//
//  Created on [Date]
//

import SwiftUI

@main
struct FormativeiOSApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}

