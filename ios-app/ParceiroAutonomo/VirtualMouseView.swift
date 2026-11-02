import SwiftUI

// MARK: - Virtual Pointer / Mouse Overlay
/// Permite controlar um cursor de mouse na tela através de um D-Pad / Joystick flutuante
/// ideal para uso com uma mão, controle remoto ou assistência motora.
struct VirtualMouseOverlay: View {
    @Binding var cursorPosition: CGPoint
    @Binding var isEnabled: Bool
    
    @State private var joystickOffset: CGSize = .zero
    @State private var isClicking: Bool = false
    @State private var timer: Timer? = nil
    
    // Posição do controle flutuante na tela
    @State private var padPosition: CGPoint = CGPoint(x: 80, y: 550)
    
    var body: some View {
        if isEnabled {
            ZStack {
                // 1. CURSOR DO MOUSE
                ZStack {
                    // Círculo de clique / onda de pulso
                    Circle()
                        .stroke(Color.semaforoAzul, lineWidth: 2)
                        .frame(width: isClicking ? 46 : 28, height: isClicking ? 46 : 28)
                        .opacity(isClicking ? 0.9 : 0.4)
                        .scaleEffect(isClicking ? 1.2 : 1.0)
                        .animation(.spring(response: 0.18, dampingFraction: 0.6), value: isClicking)
                    
                    // Ponteiro clássico com seta
                    Image(systemName: "cursorarrow")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.6), radius: 3, x: 1, y: 2)
                        .overlay(
                            Image(systemName: "cursorarrow")
                                .font(.system(size: 24, weight: .regular))
                                .foregroundColor(.inkPrimary)
                        )
                        .offset(x: 8, y: 8)
                }
                .position(cursorPosition)
                .allowsHitTesting(false)
                
                // 2. CONTROLE FLUTUANTE (D-PAD / JOYSTICK DE CONTROLE)
                VStack(spacing: 8) {
                    // Barra de arraste do controle + Fechar
                    HStack {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("MOUSE")
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                isEnabled = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 4)
                    
                    // Joystick Analógico
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.35))
                            .frame(width: 86, height: 86)
                            .overlay(
                                Circle().stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                            )
                        
                        // Botão central do joystick
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.semaforoAzul, Color.semaforoAzulEscuro],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 38, height: 38)
                            .shadow(color: Color.black.opacity(0.3), radius: 3, y: 2)
                            .offset(joystickOffset)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { val in
                                        let translation = val.translation
                                        let maxDist: CGFloat = 32
                                        let dist = hypot(translation.width, translation.height)
                                        let angle = atan2(translation.height, translation.width)
                                        let limitedDist = min(dist, maxDist)
                                        
                                        joystickOffset = CGSize(
                                            width: cos(angle) * limitedDist,
                                            height: sin(angle) * limitedDist
                                        )
                                        
                                        iniciarMovimentoContinuo(dx: joystickOffset.width / 5.5, dy: joystickOffset.height / 5.5)
                                    }
                                    .onEnded { _ in
                                        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                            joystickOffset = .zero
                                        }
                                        pararMovimentoContinuo()
                                    }
                            )
                    }
                    
                    // Botão de Clique do Mouse
                    Button {
                        executarClique()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 13, weight: .bold))
                            Text("CLICAR")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(isClicking ? Color.semaforoVerdeEscuro : Color.semaforoVerde)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 2, y: 1)
                    }
                    .padding(.horizontal, 6)
                    .padding(.bottom, 6)
                }
                .frame(width: 114)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.92))
                        .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .position(padPosition)
                .gesture(
                    DragGesture()
                        .onChanged { val in
                            padPosition = CGPoint(
                                x: min(max(val.location.x, 60), UIScreen.main.bounds.width - 60),
                                y: min(max(val.location.y, 100), UIScreen.main.bounds.height - 120)
                            )
                        }
                )
            }
        }
    }
    
    private func iniciarMovimentoContinuo(dx: CGFloat, dy: CGFloat) {
        pararMovimentoContinuo()
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            let screenW = UIScreen.main.bounds.width
            let screenH = UIScreen.main.bounds.height
            
            let novoX = min(max(cursorPosition.x + dx, 10), screenW - 10)
            let novoY = min(max(cursorPosition.y + dy, 40), screenH - 40)
            cursorPosition = CGPoint(x: novoX, y: novoY)
        }
    }
    
    private func pararMovimentoContinuo() {
        timer?.invalidate()
        timer = nil
    }
    
    private func executarClique() {
        isClicking = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            isClicking = false
        }
    }
}
