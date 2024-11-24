import SwiftUI
import Firebase

@main
struct Wolfpack_CommsApp: App {
    // Initialize Firebase when the app starts
    init() {
        FirebaseApp.configure()
    }

    @StateObject private var appState = AppState() // Create an instance of AppState

    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                GroupsListView()
                    .environmentObject(appState) // Pass AppState to the environment
            } else {
                LoginView()
                    .environmentObject(appState) // Pass AppState to the environment
            }
        }
    }
}
