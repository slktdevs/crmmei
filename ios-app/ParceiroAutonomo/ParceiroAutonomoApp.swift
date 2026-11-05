import SwiftUI

struct ContentView: View {
    @StateObject private var store = LavamosStore()
    
    var body: some View {
        Group {
            if !store.usuarioLogado {
                LavamosLoginView(store: store)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                LavamosMainView(store: store)
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: store.usuarioLogado)
    }
}

@main
struct ParceiroAutonomoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#Preview {
    ContentView()
}
