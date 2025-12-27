//
//  FormTextField.swift
//  FormativeiOS
//
//  Form Text Field Component
//

import SwiftUI

struct FormTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var icon: String? = nil
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var errorMessage: String? = nil
    
    @FocusState private var isFocused: Bool
    @State private var showPassword: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingS) {
            Text(title)
                .font(.subhead)
                .fontWeight(.medium)
                .foregroundColor(.adaptiveTextPrimary())
            
            HStack(spacing: .spacingM) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(.textSecondary)
                        .frame(width: 20)
                }
                
                Group {
                    if isSecure && !showPassword {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                            .autocapitalization(.none)
                    }
                }
                .focused($isFocused)
                
                if isSecure {
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .padding(.spacingM)
            .background(Color.adaptiveSurface())
            .cornerRadius(.radiusSmall)
            .overlay(
                RoundedRectangle(cornerRadius: .radiusSmall)
                    .stroke(
                        isFocused ? Color.brandPrimary : Color.clear,
                        lineWidth: 2
                    )
            )
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.error)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        FormTextField(
            title: "Email",
            text: .constant(""),
            placeholder: "Enter your email",
            icon: "envelope.fill",
            keyboardType: .emailAddress
        )
        
        FormTextField(
            title: "Password",
            text: .constant(""),
            placeholder: "Enter your password",
            icon: "lock.fill",
            isSecure: true
        )
        
        FormTextField(
            title: "Email with Error",
            text: .constant("invalid"),
            placeholder: "Enter your email",
            errorMessage: "Please enter a valid email address"
        )
    }
    .padding()
}

