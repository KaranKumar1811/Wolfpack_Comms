//
//  Wolfpack_CommsApp.swift
//  Wolfpack_Comms
//
//  Created by Karan Kumar on 2024-10-18.
//
import SwiftUI
import Firebase

@main
struct Wolfpack_CommsApp: App {
    // Initialize Firebase when the app starts
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

