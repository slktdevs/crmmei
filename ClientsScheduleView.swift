import SwiftUI

// MARK: - 1. Tela Minimalista "Meus Clientes"
struct ClientsScheduleView: View {
    @ObservedObject var store: AppStore
    let aoIniciarOrcamentoParaCliente: (Cliente) -> Void
    
    @State private var novoNome: String = ""
    @State private var novoBairro: String = ""
    @State private var mostrarFormularioNovoCliente: Bool = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                HStack {
                    Text("Meus Clientes")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.inkPrimary)
                    Spacer()
                    Button {
                        withAnimation {
                            mostrarFormularioNovoCliente.toggle()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Novo")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(
                        PhysicalButtonStyle(
                            baseColor: .semaforoAzul,
                            shadowColor: .semaforoAzulEscuro,
                            cornerRadius: 14
                        )
                    )
                }
                
                if mostrarFormularioNovoCliente {
                    VStack(spacing: 12) {
                        TextField("Nome do Cliente", text: $novoNome)
                            .font(.system(size: 19, weight: .semibold, design: .rounded))
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.appBackground))
                        
                        TextField("Bairro ou Referência", text: $novoBairro)
                            .font(.system(size: 19, weight: .semibold, design: .rounded))
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.appBackground))
                        
                        Button {
                            guard !novoNome.isEmpty else { return }
                            let novo = Cliente(
                                nome: novoNome,
                                apelidoOuBairro: novoBairro.isEmpty ? "Cliente Cadastrado" : novoBairro,
                                telefone: "(11) 99888-7766",
                                emojiAvatar: ""
                            )
                            store.adicionarCliente(novo)
                            novoNome = ""
                            novoBairro = ""
                            mostrarFormularioNovoCliente = false
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 18, weight: .bold))
                                Text("Salvar Cliente")
                                    .font(.system(size: 19, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(
                            PhysicalButtonStyle(
                                baseColor: .semaforoVerde,
                                shadowColor: .semaforoVerdeEscuro,
                                cornerRadius: 16
                            )
                        )
                    }
                    .padding(16)
                    .accessibleCard()
                }
                
                ForEach(store.clientes) { cliente in
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.semaforoAzulFundo)
                                    .frame(width: 54, height: 54)
                                Text(cliente.iniciais)
                                    .font(.system(size: 19, weight: .bold, design: .rounded))
                                    .foregroundColor(.semaforoAzul)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(cliente.nome)
                                    .font(.system(size: 21, weight: .bold, design: .rounded))
                                    .foregroundColor(.inkPrimary)
                                Text(cliente.apelidoOuBairro)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.inkSecondary)
                                Text(cliente.telefone)
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.semaforoAzul)
                            }
                            Spacer()
                        }
                        
                        Button {
                            aoIniciarOrcamentoParaCliente(cliente)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "doc.badge.plus")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Fazer Orçamento para \(cliente.nome)")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding(14)
                        }
                        .buttonStyle(
                            PhysicalButtonStyle(
                                baseColor: .semaforoVerde,
                                shadowColor: .semaforoVerdeEscuro,
                                cornerRadius: 14
                            )
                        )
                    }
                    .padding(18)
                    .accessibleCard()
                }
            }
            .padding(18)
        }
        .background(Color.appBackground.ignoresSafeArea())
    }
}

// MARK: - 2. Tela Minimalista "Agenda de Serviços"
struct ServiceScheduleView: View {
    @ObservedObject var store: AppStore
    
    private var servicosAgendados: [ServicoItem] {
        store.servicos.filter { $0.status != .pago }
    }
    
    private func formatarDia(_ data: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(data) { return "HOJE" }
        if cal.isDateInTomorrow(data) { return "AMANHÃ" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: data)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                HStack {
                    Text("Agenda de Serviços")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.inkPrimary)
                    Spacer()
                }
                
                ForEach(servicosAgendados) { item in
                    HStack(spacing: 14) {
                        VStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                            Text(formatarDia(item.dataAgendada))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .frame(width: 82, height: 82)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.semaforoAzul)
                        )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.cliente.nome)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.inkPrimary)
                            
                            HStack(spacing: 6) {
                                Image(systemName: item.iconeSistema)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.semaforoAzul)
                                Text(item.tituloServico)
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                    .foregroundColor(.inkSecondary)
                            }
                            
                            Text(FormatadorMoeda.string(item.valor))
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .foregroundColor(.semaforoVerdeEscuro)
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .accessibleCard()
                }
            }
            .padding(18)
        }
        .background(Color.appBackground.ignoresSafeArea())
    }
}
