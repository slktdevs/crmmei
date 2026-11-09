import SwiftUI

struct LavamosLoginView: View {
    @ObservedObject var store: LavamosStore
    
    @State private var nomeInput: String = ""
    @State private var telefoneInput: String = ""
    
    var body: some View {
        ZStack {
            Color.lavamosFundo.ignoresSafeArea()
            
            VStack(spacing: 28) {
                Spacer()
                
                // Marca Minimalista
                VStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.lavamosAzul)
                            .frame(width: 68, height: 68)
                        
                        Image(systemName: "washer.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 4) {
                        Text("Lavamos Mais")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.lavamosTexto)
                        
                        Text("Autoatendimento simples e rápido")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.lavamosTextoSec)
                    }
                }
                
                // Card Clean de Acesso
                VStack(alignment: .leading, spacing: 14) {
                    VStack(spacing: 10) {
                        TextField("Seu nome", text: $nomeInput)
                            .font(.system(size: 16, weight: .medium))
                            .padding(15)
                            .background(Color.lavamosFundo)
                            .cornerRadius(12)
                        
                        TextField("WhatsApp (opcional)", text: $telefoneInput)
                            .keyboardType(.phonePad)
                            .font(.system(size: 16, weight: .medium))
                            .padding(15)
                            .background(Color.lavamosFundo)
                            .cornerRadius(12)
                    }
                    
                    Button {
                        entrar()
                    } label: {
                        Text("Continuar")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.lavamosAzul)
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.lavamosBorda, lineWidth: 1)
                )
                .padding(.horizontal, 20)
                
                Spacer()
                
                Text("Sabão e amaciante inclusos em todas as lavagens")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.lavamosTextoSec)
                    .padding(.bottom, 16)
            }
        }
    }
    
    private func entrar() {
        let nomeLimpo = nomeInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let telLimpo = telefoneInput.trimmingCharacters(in: .whitespacesAndNewlines)
        store.entrarComTelefone(
            nome: nomeLimpo.isEmpty ? "Cliente" : nomeLimpo,
            telefone: telLimpo
        )
    }
}
