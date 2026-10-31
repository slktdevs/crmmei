import SwiftUI

struct DashboardView: View {
    @ObservedObject var store: AppStore
    
    let aoAbrirFluxoDocumento: (TipoDocumento) -> Void
    let aoAbrirClientes: () -> Void
    let aoAbrirAgenda: () -> Void
    let aoAbrirCRM: () -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // 1. TOPO: Saudação Minimalista com Ícone Vetorial
                cabecalhoProfissional
                
                // 2. CARTÕES GIGANTES DE RESUMO FINANCEIRO (No Bolso + Para Receber)
                cartoesFinanceirosGigantes
                
                // 3. GRÁFICO DE BARRAS SUPER SIMPLES (Mês Passado vs Este Mês)
                graficoComparativoSimples
                
                // 4. GRADE DE AÇÕES RÁPIDAS (4 Botões Quadrados Gigantes)
                gradeAcoesRapidas
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .background(Color.appBackground.ignoresSafeArea())
    }
    
    // MARK: - 1. Topo Minimalista
    private var cabecalhoProfissional: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.inkPrimary)
                    .frame(width: 58, height: 58)
                
                Image(systemName: "wrench.and.screwdriver")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Olá, \(store.nomeProfissional)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.inkPrimary)
                
                Text(store.profissaoProfissional)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.inkSecondary)
            }
            
            Spacer()
        }
        .padding(18)
        .accessibleCard()
    }
    
    // MARK: - 2. Cartões Gigantes de Resumo ("No Bolso" em Verde e "Para Receber" em Laranja)
    private var cartoesFinanceirosGigantes: some View {
        VStack(spacing: 14) {
            // Cartão 1: "No Bolso (Já Recebi)" -> Verde Esmeralda (#10B981)
            Button {
                aoAbrirCRM()
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.semaforoVerde)
                            .frame(width: 60, height: 60)
                        Image(systemName: "arrow.down.left")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("No Bolso (Já Recebi)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.inkSecondary)
                        
                        Text(FormatadorMoeda.string(store.totalNoBolso))
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundColor(.semaforoVerdeEscuro)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.semaforoVerdeEscuro)
                }
                .padding(18)
                .accessibleCard(borderColor: .semaforoVerde, backgroundColor: .semaforoVerdeFundo.opacity(0.6))
            }
            .buttonStyle(.plain)
            
            // Cartão 2: "Para Receber (Na Rua)" -> Amarelo/Laranja (#F59E0B)
            Button {
                aoAbrirCRM()
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.semaforoAmarelo)
                            .frame(width: 60, height: 60)
                        Image(systemName: "clock")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Para Receber (Na Rua)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.inkSecondary)
                        
                        Text(FormatadorMoeda.string(store.totalParaReceber))
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundColor(.semaforoAmareloEscuro)
                        
                        Text("Ver parcelas e cobranças")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.semaforoAmareloEscuro)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.semaforoAmareloEscuro)
                }
                .padding(18)
                .accessibleCard(borderColor: .semaforoAmarelo, backgroundColor: .semaforoAmareloFundo.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - 3. Gráfico de Barras Super Simples (Mês Passado vs Este Mês)
    private var graficoComparativoSimples: some View {
        let maiorValor = max(store.valorMesPassado, store.totalNoBolso, 1)
        let proporcaoPassado = CGFloat(store.valorMesPassado / maiorValor)
        let proporcaoAtual = CGFloat(store.totalNoBolso / maiorValor)
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.semaforoAzul)
                    Text("Quanto Ganhei")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.inkPrimary)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: store.subiuNesteMes ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis")
                        .font(.system(size: 16, weight: .bold))
                    Text(store.subiuNesteMes ? "Subiu este mês" : "Abaixo do mês passado")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .foregroundColor(store.subiuNesteMes ? .semaforoVerdeEscuro : .semaforoAmareloEscuro)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(store.subiuNesteMes ? Color.semaforoVerdeFundo : Color.semaforoAmareloFundo)
                )
            }
            
            HStack(alignment: .bottom, spacing: 24) {
                // Barra 1: Mês Passado
                VStack(spacing: 8) {
                    Text(FormatadorMoeda.string(store.valorMesPassado))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.inkSecondary)
                    
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.appBackground)
                            .frame(height: 120)
                        
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.inkSecondary.opacity(0.4))
                            .frame(height: max(32, 120 * proporcaoPassado))
                    }
                    
                    Text("Mês Passado")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.inkSecondary)
                }
                .frame(maxWidth: .infinity)
                
                // Barra 2: Este Mês
                VStack(spacing: 8) {
                    Text(FormatadorMoeda.string(store.totalNoBolso))
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(store.subiuNesteMes ? .semaforoVerdeEscuro : .semaforoAmareloEscuro)
                    
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.appBackground)
                            .frame(height: 120)
                        
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(store.subiuNesteMes ? Color.semaforoVerde : Color.semaforoAmarelo)
                            .frame(height: max(32, 120 * proporcaoAtual))
                    }
                    
                    Text("Este Mês")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.inkPrimary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(18)
        .accessibleCard()
    }
    
    // MARK: - 4. Grade de Ações Rápidas (4 Botões Quadrados Gigantes)
    private var gradeAcoesRapidas: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ações Rápidas")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.inkPrimary)
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 14),
                    GridItem(.flexible(), spacing: 14)
                ],
                spacing: 14
            ) {
                BotaoAcaoQuadradoGigante(
                    iconePrincipal: "doc.badge.plus",
                    titulo: "Fazer\nOrçamento",
                    corBase: .semaforoAmarelo,
                    corSombra: .semaforoAmareloEscuro,
                    acao: { aoAbrirFluxoDocumento(.orcamento) }
                )
                
                BotaoAcaoQuadradoGigante(
                    iconePrincipal: "checkmark.circle",
                    titulo: "Fazer\nRecibo",
                    corBase: .semaforoVerde,
                    corSombra: .semaforoVerdeEscuro,
                    acao: { aoAbrirFluxoDocumento(.recibo) }
                )
                
                BotaoAcaoQuadradoGigante(
                    iconePrincipal: "person.2",
                    titulo: "Meus\nClientes",
                    corBase: .semaforoAzul,
                    corSombra: .semaforoAzulEscuro,
                    acao: aoAbrirClientes
                )
                
                BotaoAcaoQuadradoGigante(
                    iconePrincipal: "calendar",
                    titulo: "Agenda de\nServiços",
                    corBase: .semaforoAzul,
                    corSombra: .semaforoAzulEscuro,
                    acao: aoAbrirAgenda
                )
            }
        }
    }
}

// MARK: - Componente de Botão Quadrado Minimalista
struct BotaoAcaoQuadradoGigante: View {
    let iconePrincipal: String
    let titulo: String
    let corBase: Color
    let corSombra: Color
    let acao: () -> Void
    
    var body: some View {
        Button(action: acao) {
            VStack(spacing: 14) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.22))
                            .frame(width: 48, height: 48)
                        Image(systemName: iconePrincipal)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Text(titulo)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
            }
            .padding(18)
            .frame(minHeight: 140)
        }
        .buttonStyle(
            PhysicalButtonStyle(
                baseColor: corBase,
                shadowColor: corSombra,
                cornerRadius: 22
            )
        )
    }
}
