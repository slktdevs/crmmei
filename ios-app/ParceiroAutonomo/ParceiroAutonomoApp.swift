import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppStore()
    
    @State private var abaSelecionada: AbaPrincipalApp = .inicio
    @State private var wizardConfig: WizardSheetConfig? = nil
    
    var body: some View {
        Group {
            if !store.usuarioLogado {
                LoginView(store: store)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                appPrincipalView
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: store.usuarioLogado)
    }
    
    private var appPrincipalView: some View {
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
    
    // MARK: - Barra Inferior com Scroll Horizontal Inteligente (Otimizada para iPhone 11 e telas estreitas)
    private var barraNavegacaoInferiorAcessivel: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    botaoAbaInferior(
                        aba: .inicio,
                        icone: "square.grid.2x2",
                        titulo: "Início"
                    )
                    .id(AbaPrincipalApp.inicio)
                    
                    botaoAbaInferior(
                        aba: .servicos,
                        icone: "briefcase",
                        titulo: "Serviços"
                    )
                    .id(AbaPrincipalApp.servicos)
                    
                    botaoAbaInferior(
                        aba: .dinheiro,
                        icone: "creditcard",
                        titulo: "Dinheiro"
                    )
                    .id(AbaPrincipalApp.dinheiro)
                    
                    botaoAbaInferior(
                        aba: .clientes,
                        icone: "person.2",
                        titulo: "Clientes"
                    )
                    .id(AbaPrincipalApp.clientes)
                    
                    botaoAbaInferior(
                        aba: .agenda,
                        icone: "calendar",
                        titulo: "Agenda"
                    )
                    .id(AbaPrincipalApp.agenda)
                    
                    botaoAbaInferior(
                        aba: .minisite,
                        icone: "globe",
                        titulo: "Meu Site"
                    )
                    .id(AbaPrincipalApp.minisite)
                }
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 6)
            }
            .onChange(of: abaSelecionada) { novaAba in
                withAnimation {
                    proxy.scrollTo(novaAba, anchor: .center)
                }
            }
        }
        .background(
            Color.white
                .ignoresSafeArea(edges: .bottom)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: -3)
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
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .foregroundColor(ativo ? .white : .inkSecondary)
            .padding(.horizontal, 14)
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
