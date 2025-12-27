//
//  CornerRadius.swift
//  FormativeiOS
//
//  Design System - Corner Radius
//

import SwiftUI

extension CGFloat {
    static let radiusSmall: CGFloat = 8
    static let radiusMedium: CGFloat = 12
    static let radiusLarge: CGFloat = 16
    static let radiusXLarge: CGFloat = 24
    static let radiusFull: CGFloat = 9999
}

extension View {
    func cornerRadiusSmall() -> some View {
        self.cornerRadius(.radiusSmall)
    }
    
    func cornerRadiusMedium() -> some View {
        self.cornerRadius(.radiusMedium)
    }
    
    func cornerRadiusLarge() -> some View {
        self.cornerRadius(.radiusLarge)
    }
    
    func cornerRadiusXLarge() -> some View {
        self.cornerRadius(.radiusXLarge)
    }
    
    func cornerRadiusFull() -> some View {
        self.cornerRadius(.radiusFull)
    }
}

