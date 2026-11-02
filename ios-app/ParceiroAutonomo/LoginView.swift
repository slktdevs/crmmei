import SwiftUI

struct LoginView: View {
    @ObservedObject var store: AppStore
    
    @State private var modoCadastro: Bool = false
    @State private var nomeInput: String = ""
    @State private var ramoInput: String = ""
    @State private var telefoneInput: String = ""
    @State private var emailInput: String = ""
    @State private var senhaInput: String = ""
    @State private var mostrarSenha: Bool = false
    @State private var manterConectado: Bool = true
    
    @State private var erroMensagem: String? = nil
    @State private var animandoLogo: Bool = false
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    Spacer(minLength: 14)
                    
                    // MARK: - 1. Logotipo Oficial CRM MEI
                    cabecalhoLogo
                    
                    // MARK: - 2. Seletor de Modo (Entrar / Criar Conta)
                    seletorModo
                    
                    // MARK: - 3. Formulário de Campos
                    formularioCampos
                    
                    // MARK: - 4. Manter Conectado (Sempre Logado)
                    HStack(spacing: 10) {
                        Button {
                            manterConectado.toggle()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: manterConectado ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.semaforoVerde)
                                Text("Manter conectado sempre que abrir o app")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.inkPrimary)
                            }
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    
                    // Mensagem de Erro
                    if let erro = erroMensagem {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.semaforoVermelho)
                            Text(erro)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.semaforoVermelho)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.semaforoVermelhoFundo)
                        .cornerRadius(14)
                        .padding(.horizontal, 22)
                    }
                    
                    // MARK: - 5. Botão Principal de Ação
                    botaoAcaoPrincipal
                    
                    // Divisor Sutil
                    HStack {
                        Rectangle()
                            .fill(Color.black.opacity(0.1))
                            .frame(height: 1)
                        Text("ACESSO DIRETO")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.inkSecondary.opacity(0.6))
                            .padding(.horizontal, 8)
                        Rectangle()
                            .fill(Color.black.opacity(0.1))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 30)
                    
                    // MARK: - 6. Botão Acesso Rápido Local
                    Button {
                        realizarEntradaRapida()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "bolt.shield.fill")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.semaforoAzul)
                            Text("Entrar Direto neste iPhone")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.inkPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.semaforoAzul.opacity(0.3), lineWidth: 1.5)
                        )
                    }
                    .padding(.horizontal, 22)
                    
                    // Rodapé de Segurança
                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.semaforoVerde)
                        Text("Sessão salva automaticamente • Dados 100% seguros")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.inkSecondary.opacity(0.8))
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            if !store.emailUsuario.isEmpty {
                emailInput = store.emailUsuario
            }
        }
    }
    
    // MARK: - 1. Logotipo Oficial CRM MEI
    private var cabecalhoLogo: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.inkPrimary, Color(red: 26/255, green: 42/255, blue: 75/255)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 92, height: 92)
                    .shadow(color: Color.semaforoAzul.opacity(0.35), radius: 14, x: 0, y: 8)
                
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.semaforoAzul, Color.semaforoAzulEscuro],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 66, height: 66)
                
                VStack(spacing: 2) {
                    Circle()
                        .fill(Color.semaforoVerde)
                        .frame(width: 10, height: 10)
                    Text("M")
                        .font(.system(size: 32, weight: .black, design: .rounded))
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
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.inkPrimary)
                    Text("MEI")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.semaforoAzul)
                    
                    Text("ALPHA PRO")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundColor(.semaforoVerdeEscuro)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.semaforoVerdeFundo)
                        .cornerRadius(6)
                }
                
                Text("Orçamentos, Recibos, Clientes e Controle Financeiro")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
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
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(!modoCadastro ? .white : .inkSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(!modoCadastro ? Color.semaforoAzul : Color.clear)
                    )
            }
            .buttonStyle(.plain)
            
            Button {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    modoCadastro = true
                    erroMensagem = nil
                }
            } label: {
                Text("Criar Conta MEI")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(modoCadastro ? .white : .inkSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(modoCadastro ? Color.semaforoAzul : Color.clear)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(4)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1.5)
        )
        .padding(.horizontal, 22)
    }
    
    // MARK: - 3. Formulário de Campos
    private var formularioCampos: some View {
        VStack(spacing: 12) {
            if modoCadastro {
                campoInput(
                    icone: "person.crop.circle.fill",
                    placeholder: "Seu Nome ou Nome da Empresa",
                    texto: $nomeInput
                )
                
                campoInput(
                    icone: "wrench.and.screwdriver.fill",
                    placeholder: "Profissão / Ramo (Ex: Eletricista, Pintor)",
                    texto: $ramoInput
                )
                
                campoInput(
                    icone: "phone.fill",
                    placeholder: "Seu WhatsApp com DDD",
                    texto: $telefoneInput,
                    teclado: .phonePad
                )
            }
            
            campoInput(
                icone: "envelope.fill",
                placeholder: "E-mail ou Telefone de Login",
                texto: $emailInput,
                teclado: .emailAddress
            )
            
            // Campo de Senha com botão Mostrar/Ocultar
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.semaforoAzul)
                    .frame(width: 24)
                
                Group {
                    if mostrarSenha {
                        TextField("Sua Senha de Acesso", text: $senhaInput)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("Sua Senha de Acesso", text: $senhaInput)
                    }
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.inkPrimary)
                
                Button {
                    mostrarSenha.toggle()
                } label: {
                    Image(systemName: mostrarSenha ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.inkSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1.5)
            )
        }
        .padding(.horizontal, 22)
    }
    
    private func campoInput(
        icone: String,
        placeholder: String,
        texto: Binding<String>,
        teclado: UIKeyboardType = .default
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icone)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.semaforoAzul)
                .frame(width: 24)
            
            TextField(placeholder, text: texto)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.inkPrimary)
                .keyboardType(teclado)
                .autocapitalization(teclado == .emailAddress ? .none : .words)
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.1), lineWidth: 1.5)
        )
    }
    
    // MARK: - 4. Botão de Ação Principal
    private var botaoAcaoPrincipal: some View {
        Button {
            processarAcao()
        } label: {
            HStack(spacing: 10) {
                Text(modoCadastro ? "Criar Conta e Entrar Agora" : "Entrar no CRM MEI")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 20, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .buttonStyle(
            PhysicalButtonStyle(
                baseColor: .semaforoVerde,
                shadowColor: .semaforoVerdeEscuro,
                cornerRadius: 18
            )
        )
        .padding(.horizontal, 22)
    }
    
    // MARK: - Ações e Validação
    private func processarAcao() {
        erroMensagem = nil
        if modoCadastro {
            let nomeLimpo = nomeInput.trimmingCharacters(in: .whitespacesAndNewlines)
            let emailLimpo = emailInput.trimmingCharacters(in: .whitespacesAndNewlines)
            if nomeLimpo.isEmpty {
                erroMensagem = "Digite seu nome ou o nome do seu negócio."
                return
            }
            if emailLimpo.isEmpty && telefoneInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                erroMensagem = "Informe seu e-mail ou telefone de acesso."
                return
            }
            
            store.cadastrarNovoUsuario(
                nome: nomeLimpo,
                ramo: ramoInput.isEmpty ? "Serviços e Orçamentos" : ramoInput,
                telefone: telefoneInput,
                email: emailLimpo.isEmpty ? telefoneInput : emailLimpo,
                senha: senhaInput
            )
        } else {
            let loginLimpo = emailInput.trimmingCharacters(in: .whitespacesAndNewlines)
            if loginLimpo.isEmpty {
                erroMensagem = "Digite seu e-mail ou telefone para entrar."
                return
            }
            let sucesso = store.autenticarUsuario(email: loginLimpo, senha: senhaInput)
            if !sucesso {
                erroMensagem = "Senha incorreta para esta conta. Verifique ou crie uma nova conta."
            }
        }
    }
    
    private func realizarEntradaRapida() {
        erroMensagem = nil
        store.iniciarModoVisitanteProducao()
    }
}

#Preview {
    LoginView(store: AppStore())
}
