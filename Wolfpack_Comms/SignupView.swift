//
//  SignupView.swift
//  Wolfpack_Comms
//
//  Created by Karan Kumar on 2024-10-18.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignupView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    @State private var password = ""
    @State private var invitationCode = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            // Background Image (reuse the same image)
            Image("LoginBackground")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Spacer()

                // App Name or Logo
                Text("Wolfpack_Comms - Sign Up")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 40)

                // Input Fields
                CustomTextField(placeholder: "Email", text: $email, isSecure: false)
                CustomTextField(placeholder: "Password", text: $password, isSecure: true)
                CustomTextField(placeholder: "Invitation Code", text: $invitationCode, isSecure: false)

                // Sign Up Button
                Button(action: signUp) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.7))
                        .cornerRadius(10)
                }
                .padding(.top, 10)

                Spacer()
            }
            .padding(.horizontal, 30)
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Sign Up Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }

    func signUp() {
        // Validate input
        guard !email.isEmpty, !password.isEmpty, !invitationCode.isEmpty else {
            errorMessage = "Please fill in all fields."
            showError = true
            return
        }

        let db = Firestore.firestore()
        let codeRef = db.collection("invitationCodes").document(invitationCode)

        // Check if the invitation code is valid
        codeRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // Proceed with sign up
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                        showError = true
                    } else {
                        // Assign default role
                        if let user = authResult?.user {
                            let userRef = db.collection("users").document(user.uid)
                            userRef.setData([
                                "email": email,
                                "role": "member"
                            ]) { error in
                                if let error = error {
                                    errorMessage = error.localizedDescription
                                    showError = true
                                } else {
                                    // Delete used invitation code
                                    codeRef.delete()
                                    // Dismiss sign-up view
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                }
            } else {
                errorMessage = "Invalid invitation code."
                showError = true
            }
        }
    }
}



#Preview {
    SignupView()
}
