import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                // Background Image
                Image("LoginBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50) // Reduced size
                    .padding(.bottom, 20) // Adjusted padding
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Spacer().frame(height: 60) // Adjust as needed

                    // Logo or App Name
                    Text("Wolfpack_Comms")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.bottom, 20)

                    // Or if using an image:
                    /*
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .padding(.bottom, 20)
                    */

                    // Input Fields
                    CustomTextField(placeholder: "Email", text: $email, isSecure: false)
                    CustomTextField(placeholder: "Password", text: $password, isSecure: true)

                    // Login Button
                    Button(action: login) {
                        Text("Login")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.7))
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)

                    // Sign Up Link
                    NavigationLink(destination: SignupView()) {
                        Text("Don't have an account? Sign Up")
                            .foregroundColor(.white)
                    }
                    .padding(.top, 10)

                    Spacer()
                }
                .padding(.horizontal, 30)
            }
            .alert(isPresented: $showError) {
                Alert(title: Text("Login Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    func login() {
        // Your login function
    }
}

#Preview {
    LoginView()
}
