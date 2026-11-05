import SwiftUI
import Foundation

// MARK: - Design System Lavamos Mais (Tons de Ciano / Oceano / Água Limpa)
extension Color {
    static let lavamosFundo = Color(red: 240/255, green: 249/255, blue: 255/255) // #F0F9FF
    static let lavamosCard = Color.white
    static let lavamosTexto = Color(red: 15/255, green: 23/255, blue: 42/255)
    static let lavamosTextoSec = Color(red: 71/255, green: 85/255, blue: 105/255)
    
    // Azul Ciano Lavanderia
    static let lavamosAzul = Color(red: 14/255, green: 165/255, blue: 233/255) // #0EA5E9
    static let lavamosAzulEscuro = Color(red: 2/255, green: 132/255, blue: 199/255) // #0284C7
    static let lavamosAzulClaro = Color(red: 224/255, green: 242/255, blue: 254/255)
    
    // Status Máquinas
    static let lavamosVerde = Color(red: 16/255, green: 185/255, blue: 129/255) // Disponível
    static let lavamosVerdeClaro = Color(red: 209/255, green: 250/255, blue: 229/255)
    static let lavamosLaranja = Color(red: 245/255, green: 158/255, blue: 11/255) // Em uso
    static let lavamosLaranjaClaro = Color(red: 254/255, green: 243/255, blue: 199/255)
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
}

enum StatusMaquina: String, Codable {
    case disponivel = "Disponível"
    case emUso = "Em Ciclo"
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

// MARK: - Estado Global Persistente do Cliente Lavamos Mais
@MainActor
final class LavamosStore: ObservableObject {
    @Published var usuarioLogado: Bool = false {
        didSet { salvarEstado() }
    }
    @Published var nomeCliente: String = "Cliente Lavamos Mais" {
        didSet { salvarEstado() }
    }
    @Published var telefoneCliente: String = "" {
        didSet { salvarEstado() }
    }
    @Published var saldoReais: Double = 36.0 {
        didSet { salvarEstado() }
    }
    
    // Máquinas da Loja
    @Published var maquinas: [MaquinaItem] = [] {
        didSet { salvarEstado() }
    }
    
    // Ciclo Ativo do Cliente (Timer)
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
        return docs.appendingPathComponent("lavamos_mais_state_v1.json")
    }
    
    init() {
        carregarEstado()
        iniciarTimerGlobal()
    }
    
    func carregarEstado() {
        if let data = try? Data(contentsOf: urlArquivo),
           let obj = try? JSONDecoder().decode(LavamosStateCodable.self, from: data) {
            self.usuarioLogado = obj.usuarioLogado || UserDefaults.standard.bool(forKey: "lavamos_logado")
            self.nomeCliente = obj.nomeCliente
            self.telefoneCliente = obj.telefoneCliente
            self.saldoReais = obj.saldoReais
            self.maquinas = obj.maquinas
            self.cicloAtivoMaquinaNumero = obj.cicloAtivoMaquinaNumero
            self.cicloAtivoTipo = obj.cicloAtivoTipo
            self.cicloAtivoSegundosRestantes = obj.cicloAtivoSegundosRestantes
            self.historico = obj.historico
        } else {
            // Inicialização padrão com 6 máquinas (3 lavadoras + 3 secadoras)
            self.usuarioLogado = UserDefaults.standard.bool(forKey: "lavamos_logado")
            self.maquinas = [
                MaquinaItem(numero: 1, tipo: .lavadora, status: .disponivel, tempoRestanteMinutos: 0, precoCiclo: 18.0),
                MaquinaItem(numero: 2, tipo: .lavadora, status: .disponivel, tempoRestanteMinutos: 0, precoCiclo: 18.0),
                MaquinaItem(numero: 3, tipo: .lavadora, status: .emUso, tempoRestanteMinutos: 14, precoCiclo: 18.0),
                MaquinaItem(numero: 4, tipo: .secadora, status: .disponivel, tempoRestanteMinutos: 0, precoCiclo: 18.0),
                MaquinaItem(numero: 5, tipo: .secadora, status: .disponivel, tempoRestanteMinutos: 0, precoCiclo: 18.0),
                MaquinaItem(numero: 6, tipo: .secadora, status: .emUso, tempoRestanteMinutos: 22, precoCiclo: 18.0)
            ]
        }
    }
    
    func salvarEstado() {
        let codable = LavamosStateCodable(
            usuarioLogado: usuarioLogado,
            nomeCliente: nomeCliente,
            telefoneCliente: telefoneCliente,
            saldoReais: saldoReais,
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
    
    // Iniciar sessão
    func entrarComTelefone(nome: String, telefone: String) {
        self.nomeCliente = nome.isEmpty ? "Cliente Lavamos Mais" : nome
        self.telefoneCliente = telefone
        self.usuarioLogado = true
        salvarEstado()
    }
    
    func encerrarSessao() {
        self.usuarioLogado = false
        salvarEstado()
    }
    
    // Adicionar saldo
    func adicionarSaldo(valor: Double) {
        self.saldoReais += valor
        salvarEstado()
    }
    
    // Ativar máquina (Débito e início de ciclo de 35 min)
    func ativarMaquina(numero: Int) -> (sucesso: Bool, mensagem: String) {
        guard let idx = maquinas.firstIndex(where: { $0.numero == numero }) else {
            return (false, "Máquina número \(numero) não encontrada.")
        }
        
        let m = maquinas[idx]
        if m.status == .emUso {
            return (false, "Máquina \(numero) já está em ciclo! Tempo restante: \(m.tempoRestanteMinutos) min.")
        }
        
        if saldoReais < m.precoCiclo {
            return (false, "Saldo insuficiente. Você tem R$ \(Int(saldoReais)),00 e o ciclo custa R$ \(Int(m.precoCiclo)),00.")
        }
        
        // Debita saldo
        saldoReais -= m.precoCiclo
        
        let duracaoMinutos = (m.tipo == .lavadora) ? 35 : 45
        maquinas[idx].status = .emUso
        maquinas[idx].tempoRestanteMinutos = duracaoMinutos
        maquinas[idx].clienteAtual = nomeCliente
        
        // Define ciclo ativo para acompanhamento
        cicloAtivoMaquinaNumero = numero
        cicloAtivoTipo = m.tipo
        cicloAtivoSegundosRestantes = duracaoMinutos * 60
        
        // Adiciona ao histórico
        historico.insert(
            HistoricoLavagem(
                descricao: "\(m.tipo.rawValue) #\(numero) iniciada",
                valor: m.precoCiclo,
                tipo: m.tipo,
                maquinaNumero: numero
            ),
            at: 0
        )
        
        salvarEstado()
        return (true, "Máquina \(numero) liberada com sucesso! O ciclo iniciou.")
    }
    
    private func iniciarTimerGlobal() {
        timerLoop?.invalidate()
        timerLoop = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if self.cicloAtivoSegundosRestantes > 0 {
                    self.cicloAtivoSegundosRestantes -= 1
                    if self.cicloAtivoSegundosRestantes == 0 {
                        // Ciclo finalizou!
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
    var maquinas: [MaquinaItem]
    var cicloAtivoMaquinaNumero: Int?
    var cicloAtivoTipo: TipoMaquina
    var cicloAtivoSegundosRestantes: Int
    var historico: [HistoricoLavagem]
}
