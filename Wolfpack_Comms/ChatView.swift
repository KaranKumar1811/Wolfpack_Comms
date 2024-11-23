import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct ChatView: View {
    var group: Group

    @State private var messageText = ""
    @State private var messages: [Message] = []
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Chatting in \(group.name)") // Display the group name for reference
                    .font(.headline)
                    .padding()

                ScrollView {
                    ForEach(messages) { message in
                        HStack {
                            if message.isCurrentUser {
                                Spacer()
                            }
                            VStack(alignment: .leading) {
                                if let imageUrl = message.imageUrl, let url = URL(string: imageUrl) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxWidth: 200)
                                                .cornerRadius(10)
                                        case .failure:
                                            Image(systemName: "xmark.octagon")
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                                Text(message.text)
                                    .padding(10)
                                    .background(message.isCurrentUser ? Color.blue : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            if !message.isCurrentUser {
                                Spacer()
                            }
                        }
                        .padding(10)
                    }
                }
                HStack {
                    Button(action: {
                        isImagePickerPresented = true
                    }) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 24))
                            .padding(8)
                            .background(Color.blue.opacity(0.5))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .sheet(isPresented: $isImagePickerPresented) {
                        ImagePicker(selectedImage: $selectedImage, onImagePicked: { image in
                            uploadImage(image) { imageUrl in
                                if let imageUrl = imageUrl {
                                    sendMessage(text: "", imageUrl: imageUrl)
                                }
                            }
                        })
                    }
                    TextField("Enter message...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        if !messageText.isEmpty || selectedImage != nil {
                            sendMessage(text: messageText, imageUrl: nil)
                        }
                    }) {
                        Text("Send")
                            .padding(10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(10)
            }
            .navigationBarTitle(group.name, displayMode: .inline)
            .onAppear {
                fetchMessages()
            }
        }
    }

    func sendMessage(text: String, imageUrl: String?) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let messageData: [String: Any] = [
            "text": text,
            "imageUrl": imageUrl ?? "",
            "userId": userId,
            "timestamp": Timestamp()
        ]
        db.collection("groups").document(group.id).collection("messages").addDocument(data: messageData) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                messageText = ""
            }
        }
    }

    func fetchMessages() {
        let db = Firestore.firestore()
        db.collection("groups").document(group.id).collection("messages").order(by: "timestamp", descending: false).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching messages: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else { return }
            self.messages = documents.compactMap { document -> Message? in
                let data = document.data()
                let id = document.documentID
                let text = data["text"] as? String ?? ""
                let imageUrl = data["imageUrl"] as? String
                let userId = data["userId"] as? String ?? ""
                let isCurrentUser = userId == Auth.auth().currentUser?.uid
                return Message(id: id, text: text, imageUrl: imageUrl, isCurrentUser: isCurrentUser)
            }
        }
    }

    func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("images/\(UUID().uuidString).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
            } else {
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                        completion(nil)
                    } else {
                        completion(url?.absoluteString)
                    }
                }
            }
        }
    }
}

struct Message: Identifiable {
    let id: String
    let text: String
    let imageUrl: String?
    let isCurrentUser: Bool
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var onImagePicked: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.onImagePicked(image)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    ChatView(group: Group(id: UUID().uuidString, name: "Sample Group", latestMessage: "Welcome!", timestamp: Date()))
}
