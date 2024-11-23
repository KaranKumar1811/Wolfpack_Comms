import Firebase
import FirebaseAuth
import SwiftUICore
import Foundation
import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var isKeyboardVisible: Bool = false

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
                        .padding(.bottom, isKeyboardVisible ? 10 : 20)
                        .animation(.easeInOut, value: isKeyboardVisible)

                    // Login Form Container
                    VStack(spacing: 20) {
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .foregroundColor(.black) // Set text color to black
                            .accentColor(.gray) // Set cursor color

                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .foregroundColor(.black) // Set text color to black
                            .accentColor(.gray) // Set cursor color

                        Button(action: {
                            login()
                        }) {
                            Text("Sign In")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]), startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(color: Color.blue.opacity(0.4), radius: 5, x: 0, y: 5)
                        }
                        .padding(.top, 10)
                        .background(
                            NavigationLink(destination: GroupsListView(), isActive: $isLoggedIn) {
                                EmptyView()
                            }
                            .hidden()
                        )

                        if !errorMessage.isEmpty {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding()
                            .background(Color.white.opacity(0.85))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding(.top, 10)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.85)) // Container to improve contrast
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .padding(.horizontal, 16) // Make form container wider

                    Spacer()
                }
                .padding()
            }
        }
        .onTapGesture {
            // Dismiss the keyboard when tapping outside
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                isKeyboardVisible = true
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                isKeyboardVisible = false
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }

    private func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                self.errorMessage = getFriendlyErrorMessage(error)
            } else {
                print("Login successful")
                self.isLoggedIn = true
            }
        }
    }

    private func getFriendlyErrorMessage(_ error: Error) -> String {
        let errorCode = AuthErrorCode(rawValue: (error as NSError).code)
        switch errorCode {
        case .wrongPassword:
            return "The password you entered is incorrect. Please try again."
        case .invalidEmail:
            return "The email address you entered is not valid. Please check and try again."
        case .userNotFound:
            return "No account found with this email. Please check or sign up."
        case .networkError:
            return "Network error. Please check your connection and try again."
        default:
            return "An unknown error occurred. Please try again later."
        }
    }
}

#Preview {
    LoginView()
}
