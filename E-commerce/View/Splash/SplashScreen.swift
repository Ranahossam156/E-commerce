import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false

    var body: some View {
        ZStack {
            if isActive {
                ContentView()
            } else {
                Color.white.ignoresSafeArea()

                VStack {
                    Spacer()
                    
                    LottieView(animationName: "Animation")
                        .frame(width: 300, height: 300)

                    Text("Shoppigo")
                        .foregroundColor(Color("primary"))
                        .font(.title)
                        .padding(.top, 16)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) 
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    isActive = true
                }
            }
        }
    }
}
