import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppStore()
    
    @State private var abaSelecionada: AbaPrincipalApp = .inicio
    @State private var wizardConfig: WizardSheetConfig? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch abaSelecionada {
                case .inicio:
                    DashboardView(
                        store: store,
                        aoAbrirFluxoDocumento: { tipo in
                            wizardConfig = WizardSheetConfig(tipo: tipo)
                        },
                        aoAbrirClientes: {
                            abaSelecionada = .clientes
                        },
                        aoAbrirAgenda: {
                            abaSelecionada = .agenda
                        },
                        aoAbrirCRM: {
                            abaSelecionada = .dinheiro
                        }
                    )
                case .servicos:
                    CRMVisualBoardView(
                        store: store,
                        aoTransformarEmReciboPDF: { servico in
                            wizardConfig = WizardSheetConfig(tipo: .recibo, servicoExistente: servico)
                        }
                    )
                case .dinheiro:
                    FinancialControlView(
                        store: store,
                        aoGerarReciboDeParcela: { servico in
                            wizardConfig = WizardSheetConfig(tipo: .recibo, servicoExistente: servico)
                        }
                    )
                case .clientes:
                    ClientsScheduleView(
                        store: store,
                        aoIniciarOrcamentoParaCliente: { _ in
                            wizardConfig = WizardSheetConfig(tipo: .orcamento)
                        }
                    )
                case .agenda:
                    ServiceScheduleView(
                        store: store
                    )
                case .minisite:
                    PortfolioMiniSiteView(
                        store: store
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            barraNavegacaoInferiorAcessivel
        }
        .sheet(item: $wizardConfig) { config in
            QuoteReceiptWizardView(
                store: store,
                tipoDocumento: config.tipo,
                servicoPreSelecionado: config.servicoExistente
            )
        }
    }
    
    // MARK: - Barra Inferior Minimalista de Alto Contraste
    private var barraNavegacaoInferiorAcessivel: some View {
        HStack(spacing: 4) {
            botaoAbaInferior(
                aba: .inicio,
                icone: "square.grid.2x2",
                titulo: "Início"
            )
            
            botaoAbaInferior(
                aba: .servicos,
                icone: "briefcase",
                titulo: "Serviços"
            )
            
            botaoAbaInferior(
                aba: .dinheiro,
                icone: "creditcard",
                titulo: "Dinheiro"
            )
            
            botaoAbaInferior(
                aba: .clientes,
                icone: "person.2",
                titulo: "Clientes"
            )
            
            botaoAbaInferior(
                aba: .agenda,
                icone: "calendar",
                titulo: "Agenda"
            )
            
            botaoAbaInferior(
                aba: .minisite,
                icone: "globe",
                titulo: "Meu Site"
            )
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: -2)
        )
    }
    
    private func botaoAbaInferior(aba: AbaPrincipalApp, icone: String, titulo: String) -> some View {
        let ativo = abaSelecionada == aba
        return Button {
            withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                abaSelecionada = aba
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icone)
                    .font(.system(size: 20, weight: .semibold))
                Text(titulo)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            }
            .foregroundColor(ativo ? .white : .inkSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(ativo ? Color.semaforoAzul : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

enum AbaPrincipalApp: Int {
    case inicio = 0
    case servicos = 1
    case dinheiro = 2
    case clientes = 3
    case agenda = 4
    case minisite = 5
}

struct WizardSheetConfig: Identifiable {
    let id = UUID()
    let tipo: TipoDocumento
    var servicoExistente: ServicoItem? = nil
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
