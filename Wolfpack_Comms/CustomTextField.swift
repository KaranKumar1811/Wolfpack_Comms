//
//  CustomTextField.swift
//  Wolfpack_Comms
//
//  Created by Karan Kumar on 2024-10-18.
//

import SwiftUICore
import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.8))
                .frame(height: 50)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding(.horizontal)
                    .autocapitalization(.none)
            } else {
                TextField(placeholder, text: $text)
                    .padding(.horizontal)
                    .autocapitalization(.none)
                    .keyboardType(placeholder == "Email" ? .emailAddress : .default)
            }
        }
        .padding(.horizontal, 10)
    }
}
