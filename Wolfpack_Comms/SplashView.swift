import SwiftUI

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            ContentView() // After splash, navigate to the main content
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
                // Delay of 2 seconds before transitioning to the main content
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
