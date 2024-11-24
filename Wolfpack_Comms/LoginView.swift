import Firebase
import FirebaseAuth
import SwiftUICore
import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
}

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isKeyboardVisible: Bool = false
    @State private var isProcessing: Bool = false
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ZStack {
                // Background color or gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // Company Logo
                    Image("wolfpackLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: isKeyboardVisible ? 100 : 200, height: isKeyboardVisible ? 100 : 200)
                        .padding(.bottom, 20)
                        .animation(.easeInOut, value: isKeyboardVisible)

                    // Login Form Container
                    VStack(spacing: 20) {
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)

                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)

                        Button(action: {
                            login()
                        }) {
                            if isProcessing {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]), startPoint: .leading, endPoint: .trailing))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.blue.opacity(0.4), radius: 5, x: 0, y: 5)
                            } else {
                                Text("Sign In")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]), startPoint: .leading, endPoint: .trailing))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.blue.opacity(0.4), radius: 5, x: 0, y: 5)
                            }
                        }
                        .disabled(isProcessing)
                        .padding(.top, 10)

                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.top, 10)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.85)) // Container to improve contrast
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .padding(.horizontal, 32)

                    Spacer()
                }
                .padding()
            }
        }
        .onTapGesture {
            // Dismiss the keyboard when tapping outside
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
    }

    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Please enter both email and password."
            return
        }

        isProcessing = true
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isProcessing = false
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                // Handle successful login (e.g., navigate to main view)
                print("Login successful")
                appState.isLoggedIn = true // Set the app state to logged in, which triggers navigation to GroupsListView
            }
        }
    }
}

#Preview {
    LoginView().environmentObject(AppState())
}
