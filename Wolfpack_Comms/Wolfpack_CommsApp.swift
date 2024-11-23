import SwiftUI
import FirebaseCore
import Firebase
import FirebaseAuth

@main
struct Wolfpack_CommsApp: App {
    // Initialize Firebase when the app starts
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            SplashView() // Start with SplashView
        }
    }
}
