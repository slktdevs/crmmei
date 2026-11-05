import SwiftUI

struct LavamosLoginView: View {
    @ObservedObject var store: LavamosStore
    
    @State private var nomeInput: String = ""
    @State private var telefoneInput: String = ""
    @State private var erroMsg: String? = nil
    
    var body: some View {
        ZStack {
            Color.lavamosFundo.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer(minLength: 30)
                    
                    // Logotipo Lavamos Mais
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.lavamosAzul, Color.lavamosAzulEscuro],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 96, height: 96)
                                .shadow(color: Color.lavamosAzul.opacity(0.35), radius: 12, y: 6)
                            
                            Image(systemName: "washer.fill")
                                .font(.system(size: 46, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 4) {
                            Text("LAVAMOS MAIS")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(.lavamosTexto)
                            
                            Text("Lavanderia Self-Service Inteligente")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.lavamosTextoSec)
                        }
                    }
                    
                    // Card de Identificação
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Bem-vindo(a)!")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.lavamosTexto)
                        
                        Text("Informe seu nome e WhatsApp para liberar máquinas e acompanhar seus ciclos em tempo real.")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.lavamosTextoSec)
                        
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.lavamosAzul)
                                TextField("Seu Nome", text: $nomeInput)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .padding(14)
                            .background(Color.lavamosFundo)
                            .cornerRadius(14)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.lavamosAzul)
                                TextField("WhatsApp com DDD", text: $telefoneInput)
                                    .keyboardType(.phonePad)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .padding(14)
                            .background(Color.lavamosFundo)
                            .cornerRadius(14)
                        }
                        
                        if let erro = erroMsg {
                            Text(erro)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.red)
                        }
                        
                        Button {
                            entrar()
                        } label: {
                            HStack {
                                Text("Acessar Lavanderia")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 17, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                LinearGradient(
                                    colors: [Color.lavamosAzul, Color.lavamosAzulEscuro],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.lavamosAzul.opacity(0.3), radius: 6, y: 3)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(22)
                    .shadow(color: Color.black.opacity(0.06), radius: 10, y: 4)
                    .padding(.horizontal, 20)
                    
                    // Rodapé
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 13))
                            .foregroundColor(.lavamosAzul)
                        Text("Sabão e amaciante já inclusos automaticamente")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.lavamosTextoSec)
                    }
                    .padding(.top, 10)
                }
            }
        }
    }
    
    private func entrar() {
        let nomeLimpo = nomeInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let telLimpo = telefoneInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if nomeLimpo.isEmpty && telLimpo.isEmpty {
            store.entrarComTelefone(nome: "Cliente", telefone: "(11) 99999-9999")
            return
        }
        store.entrarComTelefone(nome: nomeLimpo.isEmpty ? "Cliente" : nomeLimpo, telefone: telLimpo)
    }
}
