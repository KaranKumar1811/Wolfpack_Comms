import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MainView: View {
    @State private var userRole = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Wolfpack_Comms")
                    .font(.title)
                    .padding()

                if userRole == "admin" {
                 /*   NavigationLink(destination: AdminView()) {
                        Text("Go to Admin Panel")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(5.0)
                    }
                    .padding(.horizontal, 30)*/
                } else {
                    Text("Regular User Interface")
                        .padding()
                }

                Button(action: logout) {
                    Text("Logout")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(5.0)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)

                Spacer()
            }
            .onAppear(perform: fetchUserRole)
            .alert(isPresented: $showError) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    func fetchUserRole() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)

        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                userRole = document.data()?["role"] as? String ?? "member"
            } else {
                userRole = "member"
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}


#Preview {
    MainView()
}
