import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isLoggedIn = false

    var body: some View {
        Group {
            if isLoggedIn {
                MainView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            // Check authentication state
            isLoggedIn = Auth.auth().currentUser != nil
            // Listen for authentication state changes
            Auth.auth().addStateDidChangeListener { auth, user in
                withAnimation {
                    isLoggedIn = user != nil
                }
            }
        }
    }
}
#Preview {
    ContentView()
}
