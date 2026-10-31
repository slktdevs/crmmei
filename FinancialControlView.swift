import SwiftUI

enum FiltroFinanceiro: String, CaseIterable, Identifiable {
    case faltaReceber = "Falta Receber"
    case atrasados = "Atrasados"
    case noBolso = "Já Recebi"
    
    var id: String { rawValue }
    
    var icone: String {
        switch self {
        case .faltaReceber: return "clock"
        case .atrasados: return "exclamationmark.triangle"
        case .noBolso: return "checkmark.circle"
        }
    }
    
    var cor: Color {
        switch self {
        case .faltaReceber: return .semaforoAmarelo
        case .atrasados: return .semaforoVermelho
        case .noBolso: return .semaforoVerde
        }
    }
    
    var corEscura: Color {
        switch self {
        case .faltaReceber: return .semaforoAmareloEscuro
        case .atrasados: return .semaforoVermelhoEscuro
        case .noBolso: return .semaforoVerdeEscuro
        }
    }
}

struct FinancialControlView: View {
    @ObservedObject var store: AppStore
    
    @State private var filtroAtivo: FiltroFinanceiro = .faltaReceber
    @State private var alertaCobrancaTexto: String? = nil
    
    let aoGerarReciboDeParcela: (ServicoItem) -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                cabecalhoFinanceiro
                placarSemaforicoTriplo
                abasFiltroFinanceiro
                listaCartoesParcelas
            }
            .padding(18)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .alert("Cobrança Enviada no WhatsApp", isPresented: Binding(
            get: { alertaCobrancaTexto != nil },
            set: { if !$0 { alertaCobrancaTexto = nil } }
        )) {
            Button("Fechar") {
                alertaCobrancaTexto = nil
            }
        } message: {
            Text(alertaCobrancaTexto ?? "")
        }
    }
    
    // MARK: - 1. Cabeçalho Minimalista
    private var cabecalhoFinanceiro: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Meu Dinheiro")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.inkPrimary)
                Text("Acompanhamento de parcelas e cobranças")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.inkSecondary)
            }
            Spacer()
        }
    }
    
    // MARK: - 2. Placar Semafórico Triplo (Verde, Laranja e Vermelho)
    private var placarSemaforicoTriplo: some View {
        HStack(spacing: 8) {
            blocoResumoCor(
                titulo: "Já Recebi",
                valor: store.totalNoBolso,
                corTexto: .semaforoVerdeEscuro,
                corBorda: .semaforoVerde,
                corFundo: .semaforoVerdeFundo
            ) {
                filtroAtivo = .noBolso
            }
            
            blocoResumoCor(
                titulo: "Na Rua",
                valor: store.totalParaReceber,
                corTexto: .semaforoAmareloEscuro,
                corBorda: .semaforoAmarelo,
                corFundo: .semaforoAmareloFundo
            ) {
                filtroAtivo = .faltaReceber
            }
            
            blocoResumoCor(
                titulo: "Atrasado",
                valor: store.totalAtrasado,
                corTexto: .semaforoVermelhoEscuro,
                corBorda: .semaforoVermelho,
                corFundo: .semaforoVermelhoFundo
            ) {
                filtroAtivo = .atrasados
            }
        }
    }
    
    private func blocoResumoCor(
        titulo: String,
        valor: Double,
        corTexto: Color,
        corBorda: Color,
        corFundo: Color,
        acao: @escaping () -> Void
    ) -> some View {
        Button(action: acao) {
            VStack(alignment: .leading, spacing: 6) {
                Text(titulo)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.inkSecondary)
                    .lineLimit(1)
                
                Text(FormatadorMoeda.string(valor))
                    .font(.system(size: 19, weight: .heavy, design: .rounded))
                    .foregroundColor(corTexto)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(corFundo.opacity(0.65))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(corBorda, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 3. Abas de Filtro Minimalistas
    private var abasFiltroFinanceiro: some View {
        HStack(spacing: 8) {
            ForEach(FiltroFinanceiro.allCases) { filtro in
                let selecionado = filtroAtivo == filtro
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.78)) {
                        filtroAtivo = filtro
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: filtro.icone)
                            .font(.system(size: 18, weight: .semibold))
                        Text(filtro.rawValue)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundColor(selecionado ? .white : .inkPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(selecionado ? filtro.cor : Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(selecionado ? filtro.corEscura : Color.black.opacity(0.1), lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - 4. Lista de Cartões com Controle Visual de Parcelas
    private var servicosFiltrados: [ServicoItem] {
        switch filtroAtivo {
        case .faltaReceber:
            return store.servicos.filter { $0.status != .combinando && $0.valorFaltaReceber > 0 }
        case .atrasados:
            return store.servicos.filter { $0.status != .combinando && $0.temParcelaAtrasada }
        case .noBolso:
            return store.servicos.filter { $0.status != .combinando && $0.valorJaPago > 0 }
        }
    }
    
    private var listaCartoesParcelas: some View {
        VStack(spacing: 16) {
            if servicosFiltrados.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(.semaforoVerde)
                    Text("Nenhuma conta nesta lista.")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundColor(.inkPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(32)
                .accessibleCard()
            } else {
                ForEach(servicosFiltrados) { servico in
                    cartaoFinanceiroComParcelas(servico)
                }
            }
        }
    }
    
    private func cartaoFinanceiroComParcelas(_ servico: ServicoItem) -> some View {
        let corBorda: Color = servico.temParcelaAtrasada
            ? .semaforoVermelho
            : (servico.valorFaltaReceber > 0 ? .semaforoAmarelo : .semaforoVerde)
        
        return VStack(alignment: .leading, spacing: 14) {
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
                    HStack(spacing: 8) {
                        Text(servico.cliente.nome)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.inkPrimary)
                        
                        if servico.temParcelaAtrasada {
                            Text("ATRASADO")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color.semaforoVermelho))
                        }
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: servico.iconeSistema)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.semaforoAzul)
                        Text(servico.tituloServico)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.inkSecondary)
                    }
                }
                
                Spacer()
            }
            
            // Caixas Lado a Lado ("Já Pagou" vs "Falta Receber")
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Já Pagou")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.inkSecondary)
                    Text(FormatadorMoeda.string(servico.valorJaPago))
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(.semaforoVerdeEscuro)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.semaforoVerdeFundo))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Falta Receber")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.inkSecondary)
                    Text(FormatadorMoeda.string(servico.valorFaltaReceber))
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(servico.temParcelaAtrasada ? .semaforoVermelhoEscuro : .semaforoAmareloEscuro)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(servico.temParcelaAtrasada ? Color.semaforoVermelhoFundo : Color.semaforoAmareloFundo)
                )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Parcelas (\(servico.qtdParcelasPagas) de \(servico.parcelas.count) pagas)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.inkPrimary)
                
                ForEach(servico.parcelas) { parcela in
                    linhaParcelaVisual(servico: servico, parcela: parcela)
                }
            }
        }
        .padding(18)
        .accessibleCard(borderColor: corBorda)
    }
    
    // MARK: - Linha Individual de Cada Parcela
    private func linhaParcelaVisual(servico: ServicoItem, parcela: ParcelaItem) -> some View {
        let iconeStatus = parcela.pago ? "checkmark.circle.fill" : (parcela.atrasada ? "exclamationmark.circle.fill" : "clock")
        let corIcone: Color = parcela.pago ? .semaforoVerde : (parcela.atrasada ? .semaforoVermelho : .semaforoAmareloEscuro)
        let corFundoLinha: Color = parcela.pago
            ? Color.semaforoVerdeFundo.opacity(0.45)
            : (parcela.atrasada ? Color.semaforoVermelhoFundo.opacity(0.55) : Color.appBackground)
        
        return VStack(spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: iconeStatus)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(corIcone)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(parcela.numero)ª de \(parcela.totalParcelas) • \(FormatadorMoeda.string(parcela.valor))")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.inkPrimary)
                    
                    Text(parcela.vencimentoTexto)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(parcela.atrasada ? .semaforoVermelhoEscuro : (parcela.pago ? .semaforoVerdeEscuro : .inkSecondary))
                }
                
                Spacer()
                
                if parcela.pago {
                    Text("PAGO")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.semaforoVerde))
                }
            }
            
            if !parcela.pago {
                HStack(spacing: 8) {
                    Button {
                        withAnimation {
                            store.receberParcela(servicoId: servico.id, parcelaId: parcela.id)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                            Text("Recebi Agora")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(
                        PhysicalButtonStyle(
                            baseColor: .semaforoVerde,
                            shadowColor: .semaforoVerdeEscuro,
                            cornerRadius: 12
                        )
                    )
                    
                    Button {
                        alertaCobrancaTexto = "Mensagem pronta para \(servico.cliente.nome): \"Olá \(servico.cliente.nome), tudo bem? Passando para lembrar da \(parcela.numero)ª parcela do serviço de \(servico.tituloServico) no valor de \(FormatadorMoeda.string(parcela.valor)).\""
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "paperplane")
                                .font(.system(size: 16, weight: .bold))
                            Text("Cobrar no WhatsApp")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(
                        PhysicalButtonStyle(
                            baseColor: parcela.atrasada ? .semaforoVermelho : .semaforoAmarelo,
                            shadowColor: parcela.atrasada ? .semaforoVermelhoEscuro : .semaforoAmareloEscuro,
                            cornerRadius: 12
                        )
                    )
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(corFundoLinha)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.black.opacity(0.08), lineWidth: 1.5)
        )
    }
}
