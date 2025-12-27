//
//  Typography.swift
//  FormativeiOS
//
//  Design System - Typography
//

import SwiftUI

extension Font {
    // MARK: - Display
    static let display = Font.system(size: 34, weight: .bold, design: .default)
    
    // MARK: - Titles
    static let title1 = Font.system(size: 28, weight: .bold, design: .default)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .default)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .default)
    
    // MARK: - Headlines
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    
    // MARK: - Body
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let subhead = Font.system(size: 15, weight: .regular, design: .default)
    
    // MARK: - Footnotes
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
}

// MARK: - Text Style Modifiers
extension View {
    func displayStyle() -> some View {
        self.font(.display)
    }
    
    func title1Style() -> some View {
        self.font(.title1)
    }
    
    func title2Style() -> some View {
        self.font(.title2)
    }
    
    func title3Style() -> some View {
        self.font(.title3)
    }
    
    func headlineStyle() -> some View {
        self.font(.headline)
    }
    
    func bodyStyle() -> some View {
        self.font(.body)
    }
    
    func calloutStyle() -> some View {
        self.font(.callout)
    }
    
    func subheadStyle() -> some View {
        self.font(.subhead)
    }
    
    func footnoteStyle() -> some View {
        self.font(.footnote)
    }
    
    func captionStyle() -> some View {
        self.font(.caption)
    }
}

