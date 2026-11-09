import SwiftUI
import Foundation

// MARK: - Design System Clean & Minimalista (Lavamos Mais)
extension Color {
    static let lavamosFundo = Color(red: 244/255, green: 245/255, blue: 247/255) // #F4F5F7
    static let lavamosCard = Color.white
    static let lavamosBorda = Color(red: 229/255, green: 231/255, blue: 235/255) // #E5E7EB
    static let lavamosTexto = Color(red: 17/255, green: 24/255, blue: 39/255)    // #111827
    static let lavamosTextoSec = Color(red: 107/255, green: 114/255, blue: 128/255) // #6B7280
    
    // Cores Primárias Sólidas (Sem degradês artificiais)
    static let lavamosAzul = Color(red: 0/255, green: 102/255, blue: 255/255)    // #0066FF
    static let lavamosAzulEscuro = Color(red: 0/255, green: 82/255, blue: 204/255)
    static let lavamosAzulClaro = Color(red: 239/255, green: 246/255, blue: 255/255)
    
    static let lavamosSecadora = Color(red: 234/255, green: 88/255, blue: 12/255) // #EA580C
    static let lavamosSecadoraClaro = Color(red: 255/255, green: 247/255, blue: 237/255)
    
    // Status
    static let lavamosVerde = Color(red: 16/255, green: 185/255, blue: 129/255)  // #10B981
    static let lavamosVerdeClaro = Color(red: 236/255, green: 253/255, blue: 245/255)
    static let lavamosLaranja = Color(red: 245/255, green: 158/255, blue: 11/255) // #F59E0B
    static let lavamosLaranjaClaro = Color(red: 255/255, green: 251/255, blue: 235/255)
}

enum TipoMaquina: String, Codable, CaseIterable {
    case lavadora = "Lavadora"
    case secadora = "Secadora"
    
    var icone: String {
        switch self {
        case .lavadora: return "washer.fill"
        case .secadora: return "dryer.fill"
        }
    }
    
    var duracaoPadrao: Int {
        switch self {
        case .lavadora: return 35
        case .secadora: return 45
        }
    }
    
    /// Pulsos oficiais da Speed Queen (60ms LOW / 100ms HIGH)
    var pulsosMoeda: Int {
        switch self {
        case .lavadora: return 4
        case .secadora: return 6
        }
    }
}

enum StatusMaquina: String, Codable {
    case disponivel = "Livre"
    case emUso = "Ocupada"
    case manutencao = "Manutenção"
    
    var cor: Color {
        switch self {
        case .disponivel: return .lavamosVerde
        case .emUso: return .lavamosLaranja
        case .manutencao: return .gray
        }
    }
}

struct MaquinaItem: Identifiable, Codable, Hashable {
    let id: UUID
    var numero: Int
    var tipo: TipoMaquina
    var status: StatusMaquina
    var tempoRestanteMinutos: Int
    var precoCiclo: Double
    var clienteAtual: String?
    
    init(
        id: UUID = UUID(),
        numero: Int,
        tipo: TipoMaquina,
        status: StatusMaquina = .disponivel,
        tempoRestanteMinutos: Int = 0,
        precoCiclo: Double = 18.0,
        clienteAtual: String? = nil
    ) {
        self.id = id
        self.numero = numero
        self.tipo = tipo
        self.status = status
        self.tempoRestanteMinutos = tempoRestanteMinutos
        self.precoCiclo = precoCiclo
        self.clienteAtual = clienteAtual
    }
}

struct HistoricoLavagem: Identifiable, Codable, Hashable {
    let id: UUID
    var data: Date
    var descricao: String
    var valor: Double
    var tipo: TipoMaquina
    var maquinaNumero: Int
    
    init(id: UUID = UUID(), data: Date = Date(), descricao: String, valor: Double, tipo: TipoMaquina, maquinaNumero: Int) {
        self.id = id
        self.data = data
        self.descricao = descricao
        self.valor = valor
        self.tipo = tipo
        self.maquinaNumero = maquinaNumero
    }
}

@MainActor
final class LavamosStore: ObservableObject {
    @Published var usuarioLogado: Bool = false {
        didSet { salvarEstado() }
    }
    @Published var nomeCliente: String = "Cliente" {
        didSet { salvarEstado() }
    }
    @Published var telefoneCliente: String = "" {
        didSet { salvarEstado() }
    }
    @Published var saldoReais: Double = 36.0 {
        didSet { salvarEstado() }
    }
    
    @Published var totemHost: String = "192.168.15.23" {
        didSet { salvarEstado() }
    }
    @Published var totemPorta: String = "8080" {
        didSet { salvarEstado() }
    }
    @Published var esp32Conectado: Bool = false
    
    @Published var maquinas: [MaquinaItem] = [] {
        didSet { salvarEstado() }
    }
    
    @Published var cicloAtivoMaquinaNumero: Int? = nil {
        didSet { salvarEstado() }
    }
    @Published var cicloAtivoTipo: TipoMaquina = .lavadora {
        didSet { salvarEstado() }
    }
    @Published var cicloAtivoSegundosRestantes: Int = 0 {
        didSet { salvarEstado() }
    }
    
    @Published var historico: [HistoricoLavagem] = [] {
        didSet { salvarEstado() }
    }
    
    private var timerLoop: Timer? = nil
    
    private var urlArquivo: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return docs.appendingPathComponent("lavamos_mais_state_v2.json")
    }
    
    init() {
        carregarEstado()
        iniciarTimerGlobal()
        verificarConexaoTotem()
    }
    
    func carregarEstado() {
        if let data = try? Data(contentsOf: urlArquivo),
           let obj = try? JSONDecoder().decode(LavamosStateCodable.self, from: data) {
            self.usuarioLogado = obj.usuarioLogado || UserDefaults.standard.bool(forKey: "lavamos_logado")
            self.nomeCliente = obj.nomeCliente
            self.telefoneCliente = obj.telefoneCliente
            self.saldoReais = obj.saldoReais
            self.totemHost = obj.totemHost ?? "192.168.15.23"
            self.totemPorta = obj.totemPorta ?? "8080"
            self.maquinas = obj.maquinas
            self.cicloAtivoMaquinaNumero = obj.cicloAtivoMaquinaNumero
            self.cicloAtivoTipo = obj.cicloAtivoTipo
            self.cicloAtivoSegundosRestantes = obj.cicloAtivoSegundosRestantes
            self.historico = obj.historico
        } else {
            self.usuarioLogado = UserDefaults.standard.bool(forKey: "lavamos_logado")
            self.maquinas = [
                MaquinaItem(numero: 1, tipo: .lavadora, status: .disponivel, tempoRestanteMinutos: 0, precoCiclo: 18.0),
                MaquinaItem(numero: 2, tipo: .lavadora, status: .disponivel, tempoRestanteMinutos: 0, precoCiclo: 18.0),
                MaquinaItem(numero: 3, tipo: .secadora, status: .disponivel, tempoRestanteMinutos: 0, precoCiclo: 18.0),
                MaquinaItem(numero: 4, tipo: .secadora, status: .disponivel, tempoRestanteMinutos: 0, precoCiclo: 18.0)
            ]
        }
    }
    
    func salvarEstado() {
        let codable = LavamosStateCodable(
            usuarioLogado: usuarioLogado,
            nomeCliente: nomeCliente,
            telefoneCliente: telefoneCliente,
            saldoReais: saldoReais,
            totemHost: totemHost,
            totemPorta: totemPorta,
            maquinas: maquinas,
            cicloAtivoMaquinaNumero: cicloAtivoMaquinaNumero,
            cicloAtivoTipo: cicloAtivoTipo,
            cicloAtivoSegundosRestantes: cicloAtivoSegundosRestantes,
            historico: historico
        )
        if let data = try? JSONEncoder().encode(codable) {
            try? data.write(to: urlArquivo, options: .atomic)
        }
        UserDefaults.standard.set(usuarioLogado, forKey: "lavamos_logado")
    }
    
    func entrarComTelefone(nome: String, telefone: String) {
        self.nomeCliente = nome.isEmpty ? "Cliente" : nome
        self.telefoneCliente = telefone
        self.usuarioLogado = true
        salvarEstado()
    }
    
    func encerrarSessao() {
        self.usuarioLogado = false
        salvarEstado()
    }
    
    func adicionarSaldo(valor: Double) {
        self.saldoReais += valor
        salvarEstado()
    }
    
    func verificarConexaoTotem() {
        guard let url = URL(string: "http://\(totemHost):\(totemPorta)/api/status") else { return }
        Task {
            var req = URLRequest(url: url)
            req.timeoutInterval = 2.0
            do {
                let (_, resp) = try await URLSession.shared.data(for: req)
                if let httpResp = resp as? HTTPURLResponse, httpResp.statusCode == 200 {
                    self.esp32Conectado = true
                } else {
                    self.esp32Conectado = false
                }
            } catch {
                self.esp32Conectado = false
            }
        }
    }
    
    func ativarMaquina(numero: Int) -> (sucesso: Bool, mensagem: String) {
        guard let idx = maquinas.firstIndex(where: { $0.numero == numero }) else {
            return (false, "Máquina #0\(numero) não encontrada.")
        }
        
        let m = maquinas[idx]
        if m.status == .emUso {
            return (false, "A \(m.tipo.rawValue) #0\(numero) já está em uso.")
        }
        
        if saldoReais < m.precoCiclo {
            return (false, "Saldo insuficiente. Adicione créditos para iniciar.")
        }
        
        saldoReais -= m.precoCiclo
        
        let duracaoMinutos = m.tipo.duracaoPadrao
        maquinas[idx].status = .emUso
        maquinas[idx].tempoRestanteMinutos = duracaoMinutos
        maquinas[idx].clienteAtual = nomeCliente
        
        cicloAtivoMaquinaNumero = numero
        cicloAtivoTipo = m.tipo
        cicloAtivoSegundosRestantes = duracaoMinutos * 60
        
        let pulsos = m.tipo.pulsosMoeda
        dispararPulsoFisicoESP32(quantidade: pulsos)
        
        historico.insert(
            HistoricoLavagem(
                descricao: "\(m.tipo.rawValue) #0\(numero)",
                valor: m.precoCiclo,
                tipo: m.tipo,
                maquinaNumero: numero
            ),
            at: 0
        )
        
        salvarEstado()
        return (true, "\(m.tipo.rawValue) #0\(numero) liberada! Pressione START na máquina.")
    }
    
    private func dispararPulsoFisicoESP32(quantidade: Int) {
        guard let url = URL(string: "http://\(totemHost):\(totemPorta)/api/pulse?count=\(quantidade)") else { return }
        Task {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.timeoutInterval = 3.5
            _ = try? await URLSession.shared.data(for: request)
            self.verificarConexaoTotem()
        }
    }
    
    private func iniciarTimerGlobal() {
        timerLoop?.invalidate()
        timerLoop = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if self.cicloAtivoSegundosRestantes > 0 {
                    self.cicloAtivoSegundosRestantes -= 1
                    if self.cicloAtivoSegundosRestantes == 0 {
                        if let num = self.cicloAtivoMaquinaNumero,
                           let idx = self.maquinas.firstIndex(where: { $0.numero == num }) {
                            self.maquinas[idx].status = .disponivel
                            self.maquinas[idx].tempoRestanteMinutos = 0
                            self.maquinas[idx].clienteAtual = nil
                        }
                        self.cicloAtivoMaquinaNumero = nil
                    }
                }
            }
        }
    }
}

struct LavamosStateCodable: Codable {
    var usuarioLogado: Bool
    var nomeCliente: String
    var telefoneCliente: String
    var saldoReais: Double
    var totemHost: String?
    var totemPorta: String?
    var maquinas: [MaquinaItem]
    var cicloAtivoMaquinaNumero: Int?
    var cicloAtivoTipo: TipoMaquina
    var cicloAtivoSegundosRestantes: Int
    var historico: [HistoricoLavagem]
}
