import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct GroupsListView: View {
    @State private var groups: [Group] = []
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if groups.isEmpty {
                    Text("No groups available.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(groups) { group in
                        NavigationLink(destination: ChatView(group: group)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(group.name)
                                        .font(.headline)
                                    Text(group.latestMessage)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Text(group.timestamp, style: .time)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(5)
                        }
                    }
                }
            }
            .navigationBarTitle("Groups", displayMode: .inline)
            .onAppear(perform: fetchGroups)
            .alert(isPresented: $showError) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func fetchGroups() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let db = Firestore.firestore()
        db.collection("groups").whereField("members", arrayContains: user.uid).addSnapshotListener { snapshot, error in
            if let error = error {
                self.errorMessage = "Error loading groups: \(error.localizedDescription)"
                self.showError = true
            } else {
                if let snapshot = snapshot {
                    self.groups = snapshot.documents.map { doc in
                        let data = doc.data()
                        let groupId = doc.documentID
                        let groupName = data["name"] as? String ?? "Unknown Group"
                        let latestMessage = data["latestMessage"] as? String ?? "No messages yet"
                        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                        return Group(id: groupId, name: groupName, latestMessage: latestMessage, timestamp: timestamp)
                    }
                }
            }
        }
    }
}

struct Group: Identifiable {
    var id: String
    var name: String
    var latestMessage: String
    var timestamp: Date
}

#Preview {
    GroupsListView()
}
