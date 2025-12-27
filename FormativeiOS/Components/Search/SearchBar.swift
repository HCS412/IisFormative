//
//  SearchBar.swift
//  FormativeiOS
//
//  Animated Search Bar Component
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search..."
    var onSearchButtonClicked: (() -> Void)? = nil
    
    @FocusState private var isFocused: Bool
    @State private var isExpanded = false
    
    var body: some View {
        HStack(spacing: .spacingM) {
            if isExpanded {
                HStack(spacing: .spacingM) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.textSecondary)
                    
                    TextField(placeholder, text: $text)
                        .focused($isFocused)
                        .submitLabel(.search)
                        .onSubmit {
                            onSearchButtonClicked?()
                        }
                    
                    if !text.isEmpty {
                        Button(action: {
                            withAnimation(.springSmooth) {
                                text = ""
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                .padding(.spacingM)
                .background(Color.adaptiveSurface())
                .cornerRadius(.radiusMedium)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                Button(action: {
                    withAnimation(.springSmooth) {
                        isExpanded = true
                        isFocused = true
                    }
                    Haptics.selection()
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                        .foregroundColor(.adaptiveTextPrimary())
                        .frame(width: 44, height: 44)
                        .background(Color.adaptiveSurface())
                        .cornerRadius(.radiusMedium)
                }
            }
            
            if isExpanded {
                Button(action: {
                    withAnimation(.springSmooth) {
                        isExpanded = false
                        isFocused = false
                        text = ""
                    }
                    Haptics.selection()
                }) {
                    Text("Cancel")
                        .font(.subhead)
                        .foregroundColor(.brandPrimary)
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.springSmooth, value: isExpanded)
    }
}

#Preview {
    VStack {
        SearchBar(text: .constant(""))
        SearchBar(text: .constant("test search"))
    }
    .padding()
}

