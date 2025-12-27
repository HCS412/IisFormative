//
//  Spacing.swift
//  FormativeiOS
//
//  Design System - Spacing Scale
//

import SwiftUI

extension CGFloat {
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 12
    static let spacingL: CGFloat = 16
    static let spacingXL: CGFloat = 20
    static let spacing2XL: CGFloat = 24
    static let spacing3XL: CGFloat = 32
    static let spacing4XL: CGFloat = 40
    static let spacing5XL: CGFloat = 48
    static let spacing6XL: CGFloat = 64
}

extension View {
    func spacingXS() -> some View {
        self.padding(.spacingXS)
    }
    
    func spacingS() -> some View {
        self.padding(.spacingS)
    }
    
    func spacingM() -> some View {
        self.padding(.spacingM)
    }
    
    func spacingL() -> some View {
        self.padding(.spacingL)
    }
    
    func spacingXL() -> some View {
        self.padding(.spacingXL)
    }
}

extension EdgeInsets {
    static let cardPadding = EdgeInsets(
        top: .spacingL,
        leading: .spacingL,
        bottom: .spacingL,
        trailing: .spacingL
    )
    
    static let screenPadding = EdgeInsets(
        top: .spacingXL,
        leading: .spacingL,
        bottom: .spacingXL,
        trailing: .spacingL
    )
}

