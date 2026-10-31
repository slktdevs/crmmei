import SwiftUI

struct CRMVisualBoardView: View {
    @ObservedObject var store: AppStore
    
    @State private var abaSelecionada: StatusServico = .prontoCobrar
    let aoTransformarEmReciboPDF: (ServicoItem) -> Void
    
    private let abasCRM: [StatusServico] = [.combinando, .fazendo, .prontoCobrar]
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Três Abas Visuais no Topo com Ícones Minimalistas (SF Symbols)
            seletorAbasMinimalista
            
            // 2. Lista de Cartões Visuais de Serviços da Aba Selecionada
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    resumoTopoAba
                    
                    let itens = store.servicos(por: abaSelecionada)
                    if itens.isEmpty {
                        estadoVazioVisual
                    } else {
                        ForEach(itens) { servico in
                            cartaoServicoVisual(servico)
                        }
                    }
                }
                .padding(18)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
    }
    
    // MARK: - 1. Seletor de 3 Abas Visuais Minimalistas
    private var seletorAbasMinimalista: some View {
        HStack(spacing: 8) {
            ForEach(abasCRM) { status in
                let ativo = abaSelecionada == status
                let quantidade = store.servicos(por: status).count
                
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.78)) {
                        abaSelecionada = status
                    }
                } label: {
                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: status.iconName)
                                .font(.system(size: 18, weight: .semibold))
                            Text("\(quantidade)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(ativo ? Color.white.opacity(0.24) : Color.black.opacity(0.08))
                                )
                        }
                        
                        Text(status.rawValue)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundColor(ativo ? .white : .inkPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(ativo ? status.corPrincipal : Color.appBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(ativo ? status.corEscura : Color.black.opacity(0.1), lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    // MARK: - 2. Resumo da Aba
    private var resumoTopoAba: some View {
        let itens = store.servicos(por: abaSelecionada)
        let soma = itens.reduce(0) { $0 + $1.valor }
        
        return HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(abaSelecionada.rawValue)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.inkSecondary)
                Text("Total: \(FormatadorMoeda.string(soma))")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.inkPrimary)
            }
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.semaforoAzulFundo)
                    .frame(width: 48, height: 48)
                Image(systemName: abaSelecionada.iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.semaforoAzul)
            }
        }
        .padding(16)
        .accessibleCard()
    }
    
    // MARK: - 3. Cartão Visual de Cada Serviço
    private func cartaoServicoVisual(_ servico: ServicoItem) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.semaforoAzulFundo)
                        .frame(width: 54, height: 54)
                    Text(servico.cliente.iniciais)
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundColor(.semaforoAzul)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(servico.cliente.nome)
                        .font(.system(size: 21, weight: .bold, design: .rounded))
                        .foregroundColor(.inkPrimary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: servico.iconeSistema)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.semaforoAzul)
                        Text(servico.tituloServico)
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(.inkSecondary)
                    }
                }
                
                Spacer()
            }
            
            HStack {
                Text("Valor Total")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.inkSecondary)
                Spacer()
                Text(FormatadorMoeda.string(servico.valor))
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.semaforoVerdeEscuro)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.semaforoVerdeFundo)
            )
            
            if servico.status == .combinando {
                Button {
                    withAnimation {
                        store.avancarStatus(servico)
                        abaSelecionada = .fazendo
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 18, weight: .bold))
                        Text("Começar Serviço")
                            .font(.system(size: 19, weight: .bold, design: .rounded))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(16)
                }
                .buttonStyle(
                    PhysicalButtonStyle(
                        baseColor: .semaforoAzul,
                        shadowColor: .semaforoAzulEscuro,
                        cornerRadius: 18
                    )
                )
            } else if servico.status == .fazendo {
                Button {
                    withAnimation {
                        store.avancarStatus(servico)
                        abaSelecionada = .prontoCobrar
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                        Text("Terminei! Pronto p/ Cobrar")
                            .font(.system(size: 19, weight: .bold, design: .rounded))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(16)
                }
                .buttonStyle(
                    PhysicalButtonStyle(
                        baseColor: .semaforoAmarelo,
                        shadowColor: .semaforoAmareloEscuro,
                        cornerRadius: 18
                    )
                )
            } else if servico.status == .prontoCobrar {
                Button {
                    aoTransformarEmReciboPDF(servico)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.badge.checkmark")
                            .font(.system(size: 24, weight: .semibold))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Gerar Recibo PDF")
                                .font(.system(size: 19, weight: .bold, design: .rounded))
                            Text("1 toque para receber e enviar no WhatsApp")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .opacity(0.9)
                        }
                        Spacer()
                        Image(systemName: "paperplane")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(16)
                }
                .buttonStyle(
                    PhysicalButtonStyle(
                        baseColor: .semaforoVerde,
                        shadowColor: .semaforoVerdeEscuro,
                        cornerRadius: 18
                    )
                )
            }
        }
        .padding(18)
        .accessibleCard()
    }
    
    private var estadoVazioVisual: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 36, weight: .semibold))
                .foregroundColor(.semaforoVerde)
            Text("Nenhum serviço nesta etapa.")
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundColor(.inkPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .accessibleCard()
    }
}
