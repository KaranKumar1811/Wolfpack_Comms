import SwiftUI
import FirebaseAuth

struct InviteAcceptanceView: View {
    var inviteToken: String
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var isKeyboardVisible: Bool = false
    @Environment(\.presentationMode) var presentationMode

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

                    if isLoading {
                        ProgressView()
                    } else {
                        // Password Field Container
                        VStack(spacing: 20) {
                            SecureField("Create a Password", text: $password)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)

                            Button(action: {
                                acceptInvite()
                            }) {
                                Text("Accept Invite")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]), startPoint: .leading, endPoint: .trailing))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.blue.opacity(0.4), radius: 5, x: 0, y: 5)
                            }
                            .padding(.top, 10)

                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .padding(.top, 10)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.85))
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .padding(.horizontal, 32)
                    }

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

    private func acceptInvite() {
        guard !password.isEmpty else {
            errorMessage = "Password cannot be empty."
            return
        }

        isLoading = true
        errorMessage = ""

        let url = URL(string: "https://your-production-url.com/accept-invite")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["token": inviteToken, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = "Error: \(error.localizedDescription)"
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    // Handle successful account creation
                    // Redirect to Login View after successful account creation
                    if let window = UIApplication.shared.windows.first {
                        window.rootViewController = UIHostingController(rootView: LoginView())
                        window.makeKeyAndVisible()
                    }
                } else {
                    errorMessage = "Failed to create account. Please try again."
                }
            }
        }.resume()
    }
}

struct InviteAcceptanceView_Previews: PreviewProvider {
    static var previews: some View {
        InviteAcceptanceView(inviteToken: "sample-token")
    }
}
