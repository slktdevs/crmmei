import SwiftUI

struct LoginView: View {
    @ObservedObject var store: AppStore
    
    @State private var modoCadastro: Bool = false
    @State private var nomeInput: String = ""
    @State private var ramoInput: String = ""
    @State private var telefoneInput: String = ""
    @State private var emailInput: String = ""
    @State private var senhaInput: String = ""
    
    @State private var erroMensagem: String? = nil
    @State private var animandoLogo: Bool = false
    
    var body: some View {
        ZStack {
            // Fundo moderno com gradiente sutil
            Color.appBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer(minLength: 20)
                    
                    // MARK: - LOGOTIPO MODERNO CRM MEI
                    cabecalhoLogo
                    
                    // MARK: - SELETOR DE MODO (ENTRAR / CRIAR CONTA)
                    seletorModo
                    
                    // MARK: - FORMULÁRIO COM DESIGN CLAYMORPHISM TÁTIL
                    formularioCampos
                    
                    // MENSAGEM DE ERRO
                    if let erro = erroMensagem {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.semaforoVermelho)
                            Text(erro)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.semaforoVermelho)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.semaforoVermelhoFundo)
                        .cornerRadius(12)
                    }
                    
                    // MARK: - BOTÃO PRINCIPAL DE AÇÃO
                    botaoAcaoPrincipal
                    
                    // DIVISOR SUTIL
                    HStack {
                        Rectangle()
                            .fill(Color.black.opacity(0.1))
                            .frame(height: 1)
                        Text("OU")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.inkSecondary.opacity(0.6))
                            .padding(.horizontal, 8)
                        Rectangle()
                            .fill(Color.black.opacity(0.1))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 4)
                    
                    // MARK: - BOTÃO MODO DEMO / INÍCIO RÁPIDO
                    Button {
                        realizarEntradaRapida()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Entrar como Visitante (Produção Local)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.inkSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.black.opacity(0.08), lineWidth: 1.5)
                        )
                    }
                    .padding(.horizontal, 22)
                    
                    // RODAPÉ DE SEGURANÇA E PRIVACIDADE
                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.semaforoVerde)
                        Text("Dados 100% seguros e criptografados no seu iPhone")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.inkSecondary.opacity(0.7))
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 30)
                }
            }
        }
    }
    
    // MARK: - 1. Logotipo Oficial CRM MEI
    private var cabecalhoLogo: some View {
        VStack(spacing: 14) {
            ZStack {
                // Glow azul de fundo
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.semaforoAzul, Color.semaforoAzulEscuro],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)
                    .shadow(color: Color.semaforoAzul.opacity(0.35), radius: 14, x: 0, y: 8)
                
                // Emblema Central: "M" estilizado geométrico
                VStack(spacing: 2) {
                    Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .scaleEffect(animandoLogo ? 1.03 : 0.98)
            .animation(
                .easeInOut(duration: 2.2).repeatForever(autoreverses: true),
                value: animandoLogo
            )
            .onAppear {
                animandoLogo = true
            }
            
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Text("CRM")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundColor(.inkPrimary)
                    Text("MEI")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundColor(.semaforoAzul)
                    
                    // Badge Pro
                    Text("PRODUÇÃO")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundColor(.semaforoVerdeEscuro)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.semaforoVerdeFundo)
                        .cornerRadius(6)
                }
                
                Text("Gestão e Finanças para o Empreendedor Autônomo")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.inkSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - 2. Seletor de Modo
    private var seletorModo: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    modoCadastro = false
                    erroMensagem = nil
                }
            } label: {
                Text("Entrar na Conta")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(!modoCadastro ? .inkPrimary : .inkSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(!modoCadastro ? Color.white : Color.clear)
                            .shadow(color: !modoCadastro ? Color.black.opacity(0.06) : Color.clear, radius: 4, x: 0, y: 2)
                    )
            }
            
            Button {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    modoCadastro = true
                    erroMensagem = nil
                }
            } label: {
                Text("Novo Cadastro MEI")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(modoCadastro ? .inkPrimary : .inkSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(modoCadastro ? Color.white : Color.clear)
                            .shadow(color: modoCadastro ? Color.black.opacity(0.06) : Color.clear, radius: 4, x: 0, y: 2)
                    )
            }
        }
        .padding(4)
        .background(Color.black.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal, 24)
    }
    
    // MARK: - 3. Formulário de Campos
    private var formularioCampos: some View {
        VStack(spacing: 14) {
            if modoCadastro {
                campoInput(
                    icone: "person.crop.circle.fill",
                    placeholder: "Seu Nome ou Nome do Negócio",
                    texto: $nomeInput
                )
                
                campoInput(
                    icone: "wrench.and.screwdriver.fill",
                    placeholder: "Ramo (Ex: Elétrica, Manutenção, Beleza)",
                    texto: $ramoInput
                )
                
                campoInput(
                    icone: "phone.fill",
                    placeholder: "WhatsApp com DDD",
                    texto: $telefoneInput,
                    teclado: .phonePad
                )
            }
            
            campoInput(
                icone: "envelope.fill",
                placeholder: "Seu E-mail ou Telefone",
                texto: $emailInput,
                teclado: .emailAddress
            )
            
            campoInput(
                icone: "lock.fill",
                placeholder: "Sua Senha de Acesso",
                texto: $senhaInput,
                isSecure: true
            )
        }
        .padding(.horizontal, 22)
    }
    
    private func campoInput(
        icone: String,
        placeholder: String,
        texto: Binding<String>,
        isSecure: Bool = false,
        teclado: UIKeyboardType = .default
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icone)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.semaforoAzul)
                .frame(width: 24)
            
            if isSecure {
                SecureField(placeholder, text: texto)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
            } else {
                TextField(placeholder, text: texto)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .keyboardType(teclado)
                    .autocapitalization(teclado == .emailAddress ? .none : .words)
                    .disableAutocorrection(true)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - 4. Botão de Ação Principal
    private var botaoAcaoPrincipal: some View {
        Button {
            processarAcao()
        } label: {
            HStack(spacing: 10) {
                Text(modoCadastro ? "Criar Minha Conta MEI" : "Acessar CRM MEI")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.semaforoAzul, Color.semaforoAzulEscuro],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(18)
            .shadow(color: Color.semaforoAzul.opacity(0.35), radius: 8, x: 0, y: 5)
        }
        .padding(.horizontal, 22)
    }
    
    // MARK: - Ações e Validação
    private func processarAcao() {
        if modoCadastro {
            if nomeInput.trimmingCharacters(in: .whitespaces).isEmpty {
                erroMensagem = "Por favor, digite seu nome ou negócio."
                return
            }
            if emailInput.trimmingCharacters(in: .whitespaces).isEmpty {
                erroMensagem = "Por favor, digite seu e-mail."
                return
            }
            if senhaInput.count < 4 {
                erroMensagem = "A senha deve ter pelo menos 4 dígitos."
                return
            }
            
            // Cadastra conta zerada
            store.cadastrarNovoUsuario(
                nome: nomeInput,
                ramo: ramoInput.isEmpty ? "Serviços Autônomos" : ramoInput,
                telefone: telefoneInput.isEmpty ? "(11) 99999-9999" : telefoneInput,
                email: emailInput
            )
        } else {
            if emailInput.trimmingCharacters(in: .whitespaces).isEmpty || senhaInput.isEmpty {
                erroMensagem = "Informe seu login e senha para entrar."
                return
            }
            
            // Login no sistema
            store.autenticarUsuario(email: emailInput)
        }
    }
    
    private func realizarEntradaRapida() {
        store.iniciarModoVisitanteProducao()
    }
}

#Preview {
    LoginView(store: AppStore())
}
