import SwiftUI
import Foundation

// MARK: - 1. Paleta de Cores Semafórica e Design System (WCAG AAA + Claymorphism Tátil)
extension Color {
    /// Fundo principal claro e descanso visual (#F8FAFC)
    static let appBackground = Color(red: 248/255, green: 250/255, blue: 252/255)
    /// Superfície de cartões (#FFFFFF)
    static let cardSurface = Color.white
    /// Texto de máximo contraste (#0F172A)
    static let inkPrimary = Color(red: 15/255, green: 23/255, blue: 42/255)
    /// Texto secundário forte (#334155)
    static let inkSecondary = Color(red: 51/255, green: 65/255, blue: 85/255)
    
    // Semáforo Semântico
    /// Verde Esmeralda (#10B981): Dinheiro entrando, Pago, Confirmar/WhatsApp
    static let semaforoVerde = Color(red: 16/255, green: 185/255, blue: 129/255)
    static let semaforoVerdeEscuro = Color(red: 5/255, green: 150/255, blue: 105/255)
    static let semaforoVerdeFundo = Color(red: 209/255, green: 250/255, blue: 229/255)
    
    /// Amarelo/Laranja (#F59E0B): Pendente, Aguardando resposta, Atenção
    static let semaforoAmarelo = Color(red: 245/255, green: 158/255, blue: 11/255)
    static let semaforoAmareloEscuro = Color(red: 217/255, green: 119/255, blue: 6/255)
    static let semaforoAmareloFundo = Color(red: 254/255, green: 243/255, blue: 199/255)
    
    /// Vermelho (#EF4444): Atrasado, Cancelar, Excluir
    static let semaforoVermelho = Color(red: 239/255, green: 68/255, blue: 68/255)
    static let semaforoVermelhoEscuro = Color(red: 220/255, green: 38/255, blue: 38/255)
    static let semaforoVermelhoFundo = Color(red: 254/255, green: 226/255, blue: 226/255)
    
    /// Azul Royal (#2563EB): Novo Cliente, Agenda, Informações
    static let semaforoAzul = Color(red: 37/255, green: 99/255, blue: 235/255)
    static let semaforoAzulEscuro = Color(red: 29/255, green: 78/255, blue: 216/255)
    static let semaforoAzulFundo = Color(red: 219/255, green: 234/255, blue: 254/255)
}

// MARK: - 2. Modificadores Visuais Físicos (Botões Clicáveis com Relevo)
struct PhysicalButtonStyle: ButtonStyle {
    var baseColor: Color
    var shadowColor: Color
    var cornerRadius: CGFloat = 22
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(shadowColor)
                        .offset(y: configuration.isPressed ? 2 : 6)
                    
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(baseColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(Color.white.opacity(0.35), lineWidth: 2)
                        )
                }
            )
            .offset(y: configuration.isPressed ? 4 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct AccessibleCardModifier: ViewModifier {
    var borderColor: Color = Color.black.opacity(0.12)
    var backgroundColor: Color = .cardSurface
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(backgroundColor)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 2.5)
            )
    }
}

extension View {
    func accessibleCard(borderColor: Color = Color.black.opacity(0.12), backgroundColor: Color = .cardSurface) -> some View {
        self.modifier(AccessibleCardModifier(borderColor: borderColor, backgroundColor: backgroundColor))
    }
}

// MARK: - 3. Modelos de Domínio (Zero Jargão)
enum StatusServico: String, CaseIterable, Identifiable, Codable {
    case combinando = "Combinando"        // Orçamentos enviados
    case fazendo = "Fazendo"              // Serviços em andamento
    case prontoCobrar = "Pronto / Cobrar" // Finalizados aguardando pagamento
    case pago = "No Bolso"                // Pagos / Recibo emitido
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .combinando: return "🗣️"
        case .fazendo: return "🔨"
        case .prontoCobrar: return "💰"
        case .pago: return "✅"
        }
    }
    
    var iconName: String {
        switch self {
        case .combinando: return "bubble.left.and.bubble.right.fill"
        case .fazendo: return "hammer.fill"
        case .prontoCobrar: return "dollarsign.circle.fill"
        case .pago: return "checkmark.seal.fill"
        }
    }
    
    var corPrincipal: Color {
        switch self {
        case .combinando: return .semaforoAmarelo
        case .fazendo: return .semaforoAzul
        case .prontoCobrar: return .semaforoAmarelo
        case .pago: return .semaforoVerde
        }
    }
    
    var corEscura: Color {
        switch self {
        case .combinando: return .semaforoAmareloEscuro
        case .fazendo: return .semaforoAzulEscuro
        case .prontoCobrar: return .semaforoAmareloEscuro
        case .pago: return .semaforoVerdeEscuro
        }
    }
}

enum TipoDocumento: String {
    case orcamento = "Fazer Orçamento"
    case recibo = "Fazer Recibo"
    
    var tituloPDF: String {
        switch self {
        case .orcamento: return "ORÇAMENTO DE SERVIÇO"
        case .recibo: return "RECIBO DE PAGAMENTO"
        }
    }
    
    var corTema: Color {
        switch self {
        case .orcamento: return .semaforoAmarelo
        case .recibo: return .semaforoVerde
        }
    }
}

struct Cliente: Identifiable, Hashable, Codable {
    let id: UUID
    var nome: String
    var apelidoOuBairro: String
    var telefone: String
    var emojiAvatar: String
    var corAvatarHex: String
    
    init(id: UUID = UUID(), nome: String, apelidoOuBairro: String, telefone: String, emojiAvatar: String = "", corAvatarHex: String = "2563EB") {
        self.id = id
        self.nome = nome
        self.apelidoOuBairro = apelidoOuBairro
        self.telefone = telefone
        self.emojiAvatar = emojiAvatar
        self.corAvatarHex = corAvatarHex
    }
    
    var iniciais: String {
        let partes = nome.split(separator: " ")
        if partes.count >= 2 {
            return "\(partes[0].prefix(1))\(partes[1].prefix(1))".uppercased()
        }
        let limpo = nome.trimmingCharacters(in: .whitespaces)
        return limpo.isEmpty ? "CL" : String(limpo.prefix(2)).uppercased()
    }
}

struct CatalogoItem: Identifiable, Hashable {
    let id = UUID()
    let nomeCurto: String
    let iconeSistema: String
    let emoji: String
    let cor: Color
    let valorSugerido: Double
}

struct ObraPortfolioItem: Identifiable, Hashable, Codable {
    let id: UUID
    var titulo: String
    var bairro: String
    var tempoExecucao: String
    var precoBase: String
    var icone: String
    
    init(
        id: UUID = UUID(),
        titulo: String,
        bairro: String,
        tempoExecucao: String,
        precoBase: String,
        icone: String = "checkmark.seal"
    ) {
        self.id = id
        self.titulo = titulo
        self.bairro = bairro
        self.tempoExecucao = tempoExecucao
        self.precoBase = precoBase
        self.icone = icone
    }
}

struct ContaUsuarioMEI: Codable, Hashable {
    var nome: String
    var ramo: String
    var telefone: String
    var email: String
    var senha: String
}

struct LogServicoItem: Identifiable, Hashable, Codable {
    let id: UUID
    var dataHoraTexto: String
    var texto: String
    var tipo: String // "avanco", "material", "nota"
    
    init(id: UUID = UUID(), dataHoraTexto: String, texto: String, tipo: String = "nota") {
        self.id = id
        self.dataHoraTexto = dataHoraTexto
        self.texto = texto
        self.tipo = tipo
    }
}

struct ParcelaItem: Identifiable, Hashable, Codable {
    let id: UUID
    var numero: Int          // Ex: 1 (1ª parcela)
    var totalParcelas: Int   // Ex: 3 (de 3 parcelas)
    var valor: Double
    var vencimentoTexto: String // Ex: "Venceu há 4 dias", "Vence Hoje", "Dia 10/11"
    var pago: Bool
    var atrasada: Bool
    
    init(
        id: UUID = UUID(),
        numero: Int,
        totalParcelas: Int,
        valor: Double,
        vencimentoTexto: String,
        pago: Bool,
        atrasada: Bool = false
    ) {
        self.id = id
        self.numero = numero
        self.totalParcelas = totalParcelas
        self.valor = valor
        self.vencimentoTexto = vencimentoTexto
        self.pago = pago
        self.atrasada = atrasada
    }
}

struct ServicoItem: Identifiable, Hashable, Codable {
    let id: UUID
    var cliente: Cliente
    var tituloServico: String
    var iconeSistema: String
    var emoji: String
    var valor: Double
    var dataCriacao: Date
    var dataAgendada: Date
    var status: StatusServico
    var temFotoAnexa: Bool
    var observacaoFalada: String
    var parcelas: [ParcelaItem]
    var logs: [LogServicoItem]
    
    init(
        id: UUID = UUID(),
        cliente: Cliente,
        tituloServico: String,
        iconeSistema: String,
        emoji: String,
        valor: Double,
        dataCriacao: Date = Date(),
        dataAgendada: Date = Date(),
        status: StatusServico,
        temFotoAnexa: Bool = false,
        observacaoFalada: String = "",
        parcelas: [ParcelaItem] = [],
        logs: [LogServicoItem] = []
    ) {
        self.id = id
        self.cliente = cliente
        self.tituloServico = tituloServico
        self.iconeSistema = iconeSistema
        self.emoji = emoji
        self.valor = valor
        self.dataCriacao = dataCriacao
        self.dataAgendada = dataAgendada
        self.status = status
        self.temFotoAnexa = temFotoAnexa
        self.observacaoFalada = observacaoFalada
        self.logs = logs
        if parcelas.isEmpty {
            self.parcelas = [
                ParcelaItem(
                    numero: 1,
                    totalParcelas: 1,
                    valor: valor,
                    vencimentoTexto: status == .pago ? "Pago" : "À Vista",
                    pago: status == .pago,
                    atrasada: false
                )
            ]
        } else {
            self.parcelas = parcelas
        }
    }
    
    var valorJaPago: Double {
        parcelas.filter { $0.pago }.reduce(0) { $0 + $1.valor }
    }
    
    var valorFaltaReceber: Double {
        parcelas.filter { !$0.pago }.reduce(0) { $0 + $1.valor }
    }
    
    var temParcelaAtrasada: Bool {
        parcelas.contains { !$0.pago && $0.atrasada }
    }
    
    var qtdParcelasPagas: Int {
        parcelas.filter { $0.pago }.count
    }
}

// MARK: - Snapshot Codable Completo para Persistência Atômica em Disco
struct EstadoCompletoCRM: Codable {
    var usuarioLogado: Bool
    var emailUsuario: String
    var nomeProfissional: String
    var profissaoProfissional: String
    var telefoneProfissional: String
    var valorMesPassado: Double
    var sloganMiniSite: String
    var slugMiniSite: String
    var regiaoMiniSite: String
    var anosExperienciaMiniSite: String
    var clientes: [Cliente]
    var servicos: [ServicoItem]
    var obrasPortfolio: [ObraPortfolioItem]
    var contasRegistradas: [ContaUsuarioMEI]
}

// MARK: - 4. Store Global de Produção com Persistência Dupla (Disco + UserDefaults)
@MainActor
final class AppStore: ObservableObject {
    private var estaCarregando: Bool = false
    
    // MARK: - Estado de Autenticação Persistente
    @Published var usuarioLogado: Bool = false {
        didSet {
            guard !estaCarregando else { return }
            UserDefaults.standard.set(usuarioLogado, forKey: "crmmei_usuario_logado")
            salvarEstadoEmDisco()
        }
    }
    @Published var emailUsuario: String = "" {
        didSet {
            guard !estaCarregando else { return }
            UserDefaults.standard.set(emailUsuario, forKey: "crmmei_email_usuario")
            salvarEstadoEmDisco()
        }
    }
    
    @Published var nomeProfissional: String = "Meu Negócio MEI" {
        didSet {
            guard !estaCarregando else { return }
            UserDefaults.standard.set(nomeProfissional, forKey: "crmmei_nome_profissional")
            salvarEstadoEmDisco()
        }
    }
    @Published var profissaoProfissional: String = "Serviços e Orçamentos" {
        didSet {
            guard !estaCarregando else { return }
            UserDefaults.standard.set(profissaoProfissional, forKey: "crmmei_profissao_profissional")
            salvarEstadoEmDisco()
        }
    }
    @Published var telefoneProfissional: String = "" {
        didSet {
            guard !estaCarregando else { return }
            UserDefaults.standard.set(telefoneProfissional, forKey: "crmmei_telefone_profissional")
            salvarEstadoEmDisco()
        }
    }
    
    @Published var valorMesPassado: Double = 0.0 {
        didSet {
            guard !estaCarregando else { return }
            UserDefaults.standard.set(valorMesPassado, forKey: "crmmei_valor_mes_passado")
            salvarEstadoEmDisco()
        }
    }
    
    // MARK: - Dados do Mini Site Profissional
    @Published var sloganMiniSite: String = "Serviço de qualidade, rápido e com garantia." {
        didSet {
            guard !estaCarregando else { return }
            salvarEstadoEmDisco()
        }
    }
    @Published var slugMiniSite: String = "meu-negocio" {
        didSet {
            guard !estaCarregando else { return }
            salvarEstadoEmDisco()
        }
    }
    @Published var regiaoMiniSite: String = "Atendimento em toda a região" {
        didSet {
            guard !estaCarregando else { return }
            salvarEstadoEmDisco()
        }
    }
    @Published var anosExperienciaMiniSite: String = "Profissional Verificado" {
        didSet {
            guard !estaCarregando else { return }
            salvarEstadoEmDisco()
        }
    }
    
    @Published var clientes: [Cliente] = [] {
        didSet {
            guard !estaCarregando else { return }
            salvarEstadoEmDisco()
        }
    }
    @Published var servicos: [ServicoItem] = [] {
        didSet {
            guard !estaCarregando else { return }
            salvarEstadoEmDisco()
        }
    }
    @Published var obrasPortfolio: [ObraPortfolioItem] = [] {
        didSet {
            guard !estaCarregando else { return }
            salvarEstadoEmDisco()
        }
    }
    
    @Published var contasRegistradas: [ContaUsuarioMEI] = [] {
        didSet {
            guard !estaCarregando else { return }
            salvarEstadoEmDisco()
        }
    }
    
    let catalogoServicos: [CatalogoItem] = [
        CatalogoItem(nomeCurto: "Pintura", iconeSistema: "paintbrush.pointed.fill", emoji: "🎨", cor: .semaforoAzul, valorSugerido: 300),
        CatalogoItem(nomeCurto: "Elétrica", iconeSistema: "bolt.fill", emoji: "⚡", cor: .semaforoAmarelo, valorSugerido: 250),
        CatalogoItem(nomeCurto: "Alvenaria", iconeSistema: "building.2.crop.circle.fill", emoji: "🧱", cor: .semaforoVermelho, valorSugerido: 450),
        CatalogoItem(nomeCurto: "Encanamento", iconeSistema: "drop.fill", emoji: "🚰", cor: .semaforoAzul, valorSugerido: 180),
        CatalogoItem(nomeCurto: "Faxina", iconeSistema: "sparkles", emoji: "🧹", cor: .semaforoVerde, valorSugerido: 200),
        CatalogoItem(nomeCurto: "Jardim", iconeSistema: "leaf.fill", emoji: "🌿", cor: .semaforoVerde, valorSugerido: 150),
        CatalogoItem(nomeCurto: "Montagem", iconeSistema: "wrench.and.screwdriver.fill", emoji: "🔧", cor: .semaforoAmarelo, valorSugerido: 120),
        CatalogoItem(nomeCurto: "Telhado", iconeSistema: "house.fill", emoji: "🏠", cor: .semaforoVermelho, valorSugerido: 380)
    ]
    
    private var urlArquivoEstado: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return docs.appendingPathComponent("crmmei_production_state_v1.json")
    }
    
    init() {
        carregarEstadoInicial()
    }
    
    func carregarEstadoInicial() {
        estaCarregando = true
        defer { estaCarregando = false }
        
        let decoder = JSONDecoder()
        
        // 1. Tenta carregar do arquivo JSON atômico no DocumentDirectory
        if let data = try? Data(contentsOf: urlArquivoEstado),
           let estado = try? decoder.decode(EstadoCompletoCRM.self, from: data) {
            self.usuarioLogado = estado.usuarioLogado || UserDefaults.standard.bool(forKey: "crmmei_usuario_logado")
            self.emailUsuario = estado.emailUsuario
            self.nomeProfissional = estado.nomeProfissional
            self.profissaoProfissional = estado.profissaoProfissional
            self.telefoneProfissional = estado.telefoneProfissional
            self.valorMesPassado = estado.valorMesPassado
            self.sloganMiniSite = estado.sloganMiniSite
            self.slugMiniSite = estado.slugMiniSite
            self.regiaoMiniSite = estado.regiaoMiniSite
            self.anosExperienciaMiniSite = estado.anosExperienciaMiniSite
            self.clientes = estado.clientes
            self.servicos = estado.servicos
            self.obrasPortfolio = estado.obrasPortfolio
            self.contasRegistradas = estado.contasRegistradas
            return
        }
        
        // 2. Fallback para UserDefaults caso venha de versão anterior
        self.usuarioLogado = UserDefaults.standard.bool(forKey: "crmmei_usuario_logado")
        
        if let nomeSalvo = UserDefaults.standard.string(forKey: "crmmei_nome_profissional"), !nomeSalvo.isEmpty {
            self.nomeProfissional = nomeSalvo
        }
        if let profSalvo = UserDefaults.standard.string(forKey: "crmmei_profissao_profissional"), !profSalvo.isEmpty {
            self.profissaoProfissional = profSalvo
        }
        if let telSalvo = UserDefaults.standard.string(forKey: "crmmei_telefone_profissional"), !telSalvo.isEmpty {
            self.telefoneProfissional = telSalvo
        }
        if let emailSalvo = UserDefaults.standard.string(forKey: "crmmei_email_usuario"), !emailSalvo.isEmpty {
            self.emailUsuario = emailSalvo
        }
        self.valorMesPassado = UserDefaults.standard.double(forKey: "crmmei_valor_mes_passado")
        
        if let dadosClientes = UserDefaults.standard.data(forKey: "crmmei_clientes_producao"),
           let clientesCarregados = try? decoder.decode([Cliente].self, from: dadosClientes) {
            self.clientes = clientesCarregados
        }
        if let dadosServicos = UserDefaults.standard.data(forKey: "crmmei_servicos_producao"),
           let servicosCarregados = try? decoder.decode([ServicoItem].self, from: dadosServicos) {
            self.servicos = servicosCarregados
        }
    }
    
    func salvarEstadoEmDisco() {
        guard !estaCarregando else { return }
        let estado = EstadoCompletoCRM(
            usuarioLogado: usuarioLogado,
            emailUsuario: emailUsuario,
            nomeProfissional: nomeProfissional,
            profissaoProfissional: profissaoProfissional,
            telefoneProfissional: telefoneProfissional,
            valorMesPassado: valorMesPassado,
            sloganMiniSite: sloganMiniSite,
            slugMiniSite: slugMiniSite,
            regiaoMiniSite: regiaoMiniSite,
            anosExperienciaMiniSite: anosExperienciaMiniSite,
            clientes: clientes,
            servicos: servicos,
            obrasPortfolio: obrasPortfolio,
            contasRegistradas: contasRegistradas
        )
        
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(estado) {
            try? data.write(to: urlArquivoEstado, options: .atomic)
            UserDefaults.standard.set(data, forKey: "crmmei_estado_completo_v1")
        }
        UserDefaults.standard.set(usuarioLogado, forKey: "crmmei_usuario_logado")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Autenticação e Gestão de Conta (Sessão Sempre Persistente)
    func cadastrarNovoUsuario(nome: String, ramo: String, telefone: String, email: String, senha: String = "") {
        let nomeLimpo = nome.trimmingCharacters(in: .whitespacesAndNewlines)
        let ramoLimpo = ramo.trimmingCharacters(in: .whitespacesAndNewlines)
        let telLimpo = telefone.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailLimpo = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        estaCarregando = true
        self.nomeProfissional = nomeLimpo.isEmpty ? "Meu Negócio MEI" : nomeLimpo
        self.profissaoProfissional = ramoLimpo.isEmpty ? "Serviços Autônomos" : ramoLimpo
        self.telefoneProfissional = telLimpo
        self.emailUsuario = emailLimpo
        
        // Gera slug personalizado com base no nome
        let slugGerado = nomeLimpo
            .lowercased()
            .folding(options: .diacriticInsensitive, locale: Locale(identifier: "pt_BR"))
            .replacingOccurrences(of: " ", with: "-")
            .filter { $0.isLetter || $0.isNumber || $0 == "-" }
        if !slugGerado.isEmpty {
            self.slugMiniSite = slugGerado
        }
        
        // Salva na lista de contas registradas
        let novaConta = ContaUsuarioMEI(
            nome: self.nomeProfissional,
            ramo: self.profissaoProfissional,
            telefone: self.telefoneProfissional,
            email: emailLimpo,
            senha: senha
        )
        contasRegistradas.removeAll { $0.email.lowercased() == emailLimpo }
        contasRegistradas.append(novaConta)
        
        self.usuarioLogado = true
        estaCarregando = false
        salvarEstadoEmDisco()
    }
    
    func autenticarUsuario(email: String, senha: String = "") -> Bool {
        let loginLimpo = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !loginLimpo.isEmpty else { return false }
        
        estaCarregando = true
        // Verifica se já existe conta registrada com este e-mail ou telefone
        if let conta = contasRegistradas.first(where: {
            $0.email.lowercased() == loginLimpo || $0.telefone == loginLimpo
        }) {
            if !conta.senha.isEmpty && !senha.isEmpty && conta.senha != senha {
                estaCarregando = false
                return false
            }
            self.nomeProfissional = conta.nome
            self.profissaoProfissional = conta.ramo
            self.telefoneProfissional = conta.telefone
            self.emailUsuario = conta.email
        } else {
            self.emailUsuario = loginLimpo
            if self.nomeProfissional == "Meu Negócio MEI" || self.nomeProfissional == "Meu Negócio" {
                let prefixo = loginLimpo.components(separatedBy: "@").first ?? "Empreendedor"
                self.nomeProfissional = prefixo.capitalized
            }
            let novaConta = ContaUsuarioMEI(
                nome: self.nomeProfissional,
                ramo: self.profissaoProfissional,
                telefone: self.telefoneProfissional,
                email: loginLimpo,
                senha: senha
            )
            contasRegistradas.append(novaConta)
        }
        
        self.usuarioLogado = true
        estaCarregando = false
        salvarEstadoEmDisco()
        return true
    }
    
    func iniciarModoVisitanteProducao() {
        self.usuarioLogado = true
        salvarEstadoEmDisco()
    }
    
    func encerrarSessao() {
        self.usuarioLogado = false
        salvarEstadoEmDisco()
    }
    
    // MARK: - Cálculos Financeiros Claros (Por Parcelas!)
    var totalNoBolso: Double {
        servicos
            .filter { $0.status != .combinando }
            .reduce(0) { $0 + $1.valorJaPago }
    }
    
    var totalParaReceber: Double {
        servicos
            .filter { $0.status == .prontoCobrar || $0.status == .fazendo }
            .reduce(0) { $0 + $1.valorFaltaReceber }
    }
    
    var totalAtrasado: Double {
        servicos
            .filter { $0.status != .combinando }
            .flatMap { $0.parcelas }
            .filter { !$0.pago && $0.atrasada }
            .reduce(0) { $0 + $1.valor }
    }
    
    var subiuNesteMes: Bool {
        totalNoBolso >= valorMesPassado
    }
    
    func servicos(por status: StatusServico) -> [ServicoItem] {
        servicos.filter { $0.status == status }
    }
    
    /// Marca uma única parcela como paga e, se todas estiverem pagas, conclui o serviço
    func receberParcela(servicoId: UUID, parcelaId: UUID) {
        guard let sIdx = servicos.firstIndex(where: { $0.id == servicoId }),
              let pIdx = servicos[sIdx].parcelas.firstIndex(where: { $0.id == parcelaId }) else { return }
        
        servicos[sIdx].parcelas[pIdx].pago = true
        servicos[sIdx].parcelas[pIdx].atrasada = false
        servicos[sIdx].parcelas[pIdx].vencimentoTexto = "Pago ✅"
        
        let todasPagas = servicos[sIdx].parcelas.allSatisfy { $0.pago }
        if todasPagas {
            servicos[sIdx].status = .pago
        }
        salvarEstadoEmDisco()
    }
    
    /// Alterna o estado de atraso de uma parcela em aberto
    func alternarAtrasoParcela(servicoId: UUID, parcelaId: UUID) {
        guard let sIdx = servicos.firstIndex(where: { $0.id == servicoId }),
              let pIdx = servicos[sIdx].parcelas.firstIndex(where: { $0.id == parcelaId }) else { return }
        guard !servicos[sIdx].parcelas[pIdx].pago else { return }
        
        servicos[sIdx].parcelas[pIdx].atrasada.toggle()
        if servicos[sIdx].parcelas[pIdx].atrasada {
            servicos[sIdx].parcelas[pIdx].vencimentoTexto = "Parcela em Atraso"
        } else {
            servicos[sIdx].parcelas[pIdx].vencimentoTexto = "\(servicos[sIdx].parcelas[pIdx].numero)ª Parcela (Em aberto)"
        }
        salvarEstadoEmDisco()
    }
    
    func avancarStatus(_ servico: ServicoItem) {
        guard let idx = servicos.firstIndex(where: { $0.id == servico.id }) else { return }
        switch servicos[idx].status {
        case .combinando:
            servicos[idx].status = .fazendo
        case .fazendo:
            servicos[idx].status = .prontoCobrar
        case .prontoCobrar:
            marcarComoPago(servico)
        case .pago:
            break
        }
        salvarEstadoEmDisco()
    }
    
    func atualizarDataServico(_ servico: ServicoItem, novaData: Date) {
        guard let idx = servicos.firstIndex(where: { $0.id == servico.id }) else { return }
        servicos[idx].dataAgendada = novaData
        salvarEstadoEmDisco()
    }
    
    func marcarComoPago(_ servico: ServicoItem) {
        guard let idx = servicos.firstIndex(where: { $0.id == servico.id }) else { return }
        for i in servicos[idx].parcelas.indices {
            servicos[idx].parcelas[i].pago = true
            servicos[idx].parcelas[i].atrasada = false
            servicos[idx].parcelas[i].vencimentoTexto = "Pago ✅"
        }
        servicos[idx].status = .pago
        salvarEstadoEmDisco()
    }
    
    func adicionarServico(_ novo: ServicoItem) {
        if let idx = servicos.firstIndex(where: { $0.id == novo.id }) {
            servicos[idx] = novo
        } else {
            servicos.insert(novo, at: 0)
        }
        salvarEstadoEmDisco()
    }
    
    func removerServico(_ servico: ServicoItem) {
        servicos.removeAll { $0.id == servico.id }
        salvarEstadoEmDisco()
    }
    
    func adicionarCliente(_ cliente: Cliente) {
        if let idx = clientes.firstIndex(where: { $0.id == cliente.id }) {
            clientes[idx] = cliente
        } else {
            clientes.insert(cliente, at: 0)
        }
        salvarEstadoEmDisco()
    }
    
    func removerCliente(_ cliente: Cliente) {
        clientes.removeAll { $0.id == cliente.id }
        salvarEstadoEmDisco()
    }
    
    func adicionarObraPortfolio(_ obra: ObraPortfolioItem) {
        obrasPortfolio.insert(obra, at: 0)
        salvarEstadoEmDisco()
    }
    
    func removerObraPortfolio(_ obra: ObraPortfolioItem) {
        obrasPortfolio.removeAll { $0.id == obra.id }
        salvarEstadoEmDisco()
    }
    
    var resumoFaladoDoMes: String {
        let bolsoFormatado = FormatadorMoeda.falarReais(totalNoBolso)
        let receberFormatado = FormatadorMoeda.falarReais(totalParaReceber)
        let comparacao = subiuNesteMes
            ? "Parabéns \(nomeProfissional)! Neste mês você já ganhou mais do que no mês passado!"
            : "Atenção \(nomeProfissional), falta um pouquinho para alcançar o mês passado. Você tem \(receberFormatado) na rua para receber."
        
        return "Olá, \(nomeProfissional)! Aqui é o resumo do seu mês. No bolso, você já recebeu \(bolsoFormatado). Para receber na rua, você tem \(receberFormatado). \(comparacao)"
    }
    
    // MARK: - Utilitário de Abertura Direta do WhatsApp
    static func abrirWhatsApp(telefone: String, mensagem: String) {
        let digitos = telefone.filter { $0.isNumber }
        let ddiTelefone: String
        if digitos.isEmpty {
            ddiTelefone = ""
        } else if digitos.hasPrefix("55") && digitos.count >= 12 {
            ddiTelefone = digitos
        } else {
            ddiTelefone = "55" + digitos
        }
        
        let msgEncoded = mensagem.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlStr = ddiTelefone.isEmpty
            ? "https://wa.me/?text=\(msgEncoded)"
            : "https://wa.me/\(ddiTelefone)?text=\(msgEncoded)"
        
        #if os(iOS)
        UIPasteboard.general.string = mensagem
        if let url = URL(string: urlStr) {
            UIApplication.shared.open(url)
        }
        #endif
    }
}

// MARK: - 5. Formatador de Moeda e Texto Falado em Português
enum FormatadorMoeda {
    static func string(_ valor: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.maximumFractionDigits = valor.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
        return formatter.string(from: NSNumber(value: valor)) ?? "R$ \(Int(valor))"
    }
    
    static func falarReais(_ valor: Double) -> String {
        let inteiro = Int(valor)
        return "\(inteiro) reais"
    }
}
