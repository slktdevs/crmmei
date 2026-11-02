import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppStore()
    
    @State private var abaSelecionada: AbaPrincipalApp = .inicio
    @State private var wizardConfig: WizardSheetConfig? = nil
    
    // Controle Virtual de Mouse
    @State private var mouseAtivo: Bool = false
    @State private var posicaoMouse: CGPoint = CGPoint(x: 200, y: 350)
    
    var body: some View {
        ZStack {
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
            
            // Overlay do Mouse Flutuante (Ativável a qualquer momento)
            VirtualMouseOverlay(cursorPosition: $posicaoMouse, isEnabled: $mouseAtivo)
        }
    }
    
    private var appPrincipalView: some View {
        VStack(spacing: 0) {
            // Barra superior com atalho para ligar/desligar mouse virtual
            HStack {
                Text("CRM MEI")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundColor(.inkPrimary)
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        mouseAtivo.toggle()
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: mouseAtivo ? "cursorarrow.rays" : "cursorarrow")
                            .font(.system(size: 13, weight: .bold))
                        Text(mouseAtivo ? "Mouse Ativo" : "Mouse")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(mouseAtivo ? .white : .inkSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(mouseAtivo ? Color.semaforoAzul : Color.black.opacity(0.06))
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(Color.white)
            
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
            
            barraNavegacaoInferiorFixa
        }
        .sheet(item: $wizardConfig) { config in
            QuoteReceiptWizardView(
                store: store,
                tipoDocumento: config.tipo,
                servicoPreSelecionado: config.servicoExistente
            )
        }
    }
    
    // MARK: - Barra Inferior Fixa (Todos os 6 itens na mesma tela sem scroll)
    private var barraNavegacaoInferiorFixa: some View {
        HStack(spacing: 0) {
            botaoAbaInferior(aba: .inicio, icone: "square.grid.2x2", titulo: "Início")
            botaoAbaInferior(aba: .servicos, icone: "briefcase", titulo: "Serviços")
            botaoAbaInferior(aba: .dinheiro, icone: "creditcard", titulo: "Dinheiro")
            botaoAbaInferior(aba: .clientes, icone: "person.2", titulo: "Clientes")
            botaoAbaInferior(aba: .agenda, icone: "calendar", titulo: "Agenda")
            botaoAbaInferior(aba: .minisite, icone: "globe", titulo: "Meu Site")
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
        .padding(.bottom, 6)
        .background(
            Color.white
                .ignoresSafeArea(edges: .bottom)
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: -2)
        )
    }
    
    private func botaoAbaInferior(aba: AbaPrincipalApp, icone: String, titulo: String) -> some View {
        let ativo = abaSelecionada == aba
        return Button {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                abaSelecionada = aba
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icone)
                    .font(.system(size: 19, weight: ativo ? .bold : .medium))
                Text(titulo)
                    .font(.system(size: 10, weight: ativo ? .bold : .medium, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundColor(ativo ? Color.semaforoAzul : Color.inkSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(ativo ? Color.semaforoAzul.opacity(0.12) : Color.clear)
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
