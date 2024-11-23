import SwiftUI
import Firebase
import FirebaseAuth

struct SplashView: View {
    @State private var isActive = false
    @State private var isFirebaseConfigured = false
    @State private var isLoggedIn: Bool = false

    var body: some View {
        if isFirebaseConfigured {
            if isLoggedIn {
                GroupsListView() // Navigate to GroupsListView if user is logged in
            } else {
                LoginView() // Navigate to LoginView if user is not logged in
            }
        } else {
            ZStack {
                // Background color or gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Company Logo
                    Image("wolfpackLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)

                    Text("Wolfpack Comms")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                }
            }
            .onAppear {
                initializeFirebase()
            }
        }
    }

    private func initializeFirebase() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure() // Initialize Firebase if not already configured
        }
        
        // Delay a bit to simulate splash screen loading (or wait for Firebase to complete)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Check if a user is logged in after Firebase is configured
            if let user = Auth.auth().currentUser {
                isLoggedIn = true
            }
            isFirebaseConfigured = true
        }
    }
}

#Preview {
    SplashView()
}
