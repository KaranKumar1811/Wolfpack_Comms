import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ChatView: View {
    @State private var message: String = ""
    @State private var messages: [Message] = []
    @State private var currentUserID: String = ""
    
    let db = Firestore.firestore()

    var body: some View {
        VStack {
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(messages) { message in
                            HStack {
                                if message.senderID == currentUserID {
                                    Spacer()
                                    Text(message.text)
                                        .padding()
                                        .background(Color.blue.opacity(0.7))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .frame(maxWidth: 250, alignment: .trailing)
                                } else {
                                    Text(message.text)
                                        .padding()
                                        .background(Color.gray.opacity(0.3))
                                        .foregroundColor(.black)
                                        .cornerRadius(10)
                                        .frame(maxWidth: 250, alignment: .leading)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .onChange(of: messages.count) { _ in
                    if !messages.isEmpty {
                        withAnimation {
                            scrollView.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                }
            }
            .padding(.top)
            
            HStack {
                TextField("Enter your message", text: $message)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .onAppear(perform: setupChat)
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func setupChat() {
        if let userID = Auth.auth().currentUser?.uid {
            currentUserID = userID
        }
        fetchMessages()
    }

    private func sendMessage() {
        guard !message.isEmpty, let userID = Auth.auth().currentUser?.uid else { return }
        
        let newMessage = Message(text: message, senderID: userID, timestamp: Date())
        do {
            try db.collection("messages").addDocument(from: newMessage)
            message = ""
        } catch let error {
            print("Error sending message: \(error.localizedDescription)")
        }
    }

    private func fetchMessages() {
        db.collection("messages").order(by: "timestamp", descending: false).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching messages: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else { return }
            self.messages = documents.compactMap { document in
                try? document.data(as: Message.self)
            }
        }
    }
}

struct Message: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    var text: String
    var senderID: String
    var timestamp: Date
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
