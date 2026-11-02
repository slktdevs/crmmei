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
    case combinando = "Combinando"     // Orçamentos enviados
    case fazendo = "Fazendo"           // Serviços em andamento
    case prontoCobrar = "Pronto / Cobrar" // Finalizados aguardando pagamento
    case pago = "No Bolso"             // Pagos / Recibo emitido
    
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
    
    init(id: UUID = UUID(), nome: String, apelidoOuBairro: String, telefone: String, emojiAvatar: String, corAvatarHex: String = "2563EB") {
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
        return String(nome.prefix(2)).uppercased()
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

// MARK: - 4. Store Global com Dados Mockados Realistas
@MainActor
final class AppStore: ObservableObject {
    // MARK: - Estado de Autenticação em Produção
    @Published var usuarioLogado: Bool = false {
        didSet {
            UserDefaults.standard.set(usuarioLogado, forKey: "crmmei_usuario_logado")
        }
    }
    @Published var emailUsuario: String = "" {
        didSet {
            UserDefaults.standard.set(emailUsuario, forKey: "crmmei_email_usuario")
        }
    }
    
    @Published var nomeProfissional: String = "Meu Negócio" {
        didSet {
            UserDefaults.standard.set(nomeProfissional, forKey: "crmmei_nome_profissional")
        }
    }
    @Published var profissaoProfissional: String = "Serviços Gerais" {
        didSet {
            UserDefaults.standard.set(profissaoProfissional, forKey: "crmmei_profissao_profissional")
        }
    }
    @Published var telefoneProfissional: String = "" {
        didSet {
            UserDefaults.standard.set(telefoneProfissional, forKey: "crmmei_telefone_profissional")
        }
    }
    
    @Published var valorMesPassado: Double = 0.0 {
        didSet {
            UserDefaults.standard.set(valorMesPassado, forKey: "crmmei_valor_mes_passado")
        }
    }
    
    @Published var clientes: [Cliente] = [] {
        didSet {
            salvarDadosLocais()
        }
    }
    @Published var servicos: [ServicoItem] = [] {
        didSet {
            salvarDadosLocais()
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
    
    init() {
        carregarEstadoInicial()
    }
    
    func carregarEstadoInicial() {
        let logado = UserDefaults.standard.bool(forKey: "crmmei_usuario_logado")
        self.usuarioLogado = logado
        
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
        
        // Carrega serviços e clientes do disco local (dados de produção do zero)
        carregarDadosLocais()
    }
    
    // MARK: - Autenticação e Gestão de Conta
    func cadastrarNovoUsuario(nome: String, ramo: String, telefone: String, email: String) {
        self.nomeProfissional = nome
        self.profissaoProfissional = ramo
        self.telefoneProfissional = telefone
        self.emailUsuario = email
        
        // Zera todos os dados para começar 100% limpo em produção
        self.clientes = []
        self.servicos = []
        self.valorMesPassado = 0.0
        self.usuarioLogado = true
        salvarDadosLocais()
    }
    
    func autenticarUsuario(email: String) {
        self.emailUsuario = email
        if self.nomeProfissional == "Meu Negócio" && !email.isEmpty {
            let prefixo = email.components(separatedBy: "@").first ?? "Empreendedor"
            self.nomeProfissional = prefixo.capitalized
        }
        self.usuarioLogado = true
    }
    
    func iniciarModoVisitanteProducao() {
        self.usuarioLogado = true
    }
    
    func encerrarSessao() {
        self.usuarioLogado = false
    }
    
    // MARK: - Persistência Segura de Dados do Zero
    private func salvarDadosLocais() {
        let encoder = JSONEncoder()
        if let dadosClientes = try? encoder.encode(clientes) {
            UserDefaults.standard.set(dadosClientes, forKey: "crmmei_clientes_producao")
        }
        if let dadosServicos = try? encoder.encode(servicos) {
            UserDefaults.standard.set(dadosServicos, forKey: "crmmei_servicos_producao")
        }
    }
    
    private func carregarDadosLocais() {
        let decoder = JSONDecoder()
        if let dadosClientes = UserDefaults.standard.data(forKey: "crmmei_clientes_producao"),
           let clientesCarregados = try? decoder.decode([Cliente].self, from: dadosClientes) {
            self.clientes = clientesCarregados
        } else {
            self.clientes = []
        }
        
        if let dadosServicos = UserDefaults.standard.data(forKey: "crmmei_servicos_producao"),
           let servicosCarregados = try? decoder.decode([ServicoItem].self, from: dadosServicos) {
            self.servicos = servicosCarregados
        } else {
            self.servicos = []
        }
    }
    
    // Caso o usuário queira carregar exemplos manualmente no futuro:
    func carregarDadosMockados() {

        let donaMaria = Cliente(
            nome: "Dona Maria",
            apelidoOuBairro: "Casa Verde - Portão Azul",
            telefone: "(11) 99123-4567",
            emojiAvatar: "👵🏽"
        )
        let seuCarlos = Cliente(
            nome: "Seu Carlos",
            apelidoOuBairro: "Padaria da Esquina",
            telefone: "(11) 99234-5678",
            emojiAvatar: "👨🏻"
        )
        let donaNeide = Cliente(
            nome: "Dona Neide",
            apelidoOuBairro: "Sobrado Amarelo",
            telefone: "(11) 99345-6789",
            emojiAvatar: "👩🏾"
        )
        let oficinaRoberto = Cliente(
            nome: "Roberto Mecânico",
            apelidoOuBairro: "Perto do Mercado",
            telefone: "(11) 99456-7890",
            emojiAvatar: "🧔🏽"
        )
        let draPaula = Cliente(
            nome: "Doutora Paula",
            apelidoOuBairro: "Condomínio Flores",
            telefone: "(11) 99567-8901",
            emojiAvatar: "👩🏼‍⚕️"
        )
        
        self.clientes = [donaMaria, seuCarlos, donaNeide, oficinaRoberto, draPaula]
        
        let hoje = Date()
        let cal = Calendar.current
        
        self.servicos = [
            // 1. Serviço Parcelado em 2x (1ª paga, 2ª atrasada!) -> Dona Neide
            ServicoItem(
                cliente: donaNeide,
                tituloServico: "Conserto do Telhado",
                iconeSistema: "house.fill",
                emoji: "🏠",
                valor: 400.00,
                dataCriacao: cal.date(byAdding: .day, value: -15, to: hoje) ?? hoje,
                dataAgendada: cal.date(byAdding: .day, value: -5, to: hoje) ?? hoje,
                status: .prontoCobrar,
                temFotoAnexa: true,
                observacaoFalada: "Troca de telhas quebradas combinada em 2 vezes de 200 reais",
                parcelas: [
                    ParcelaItem(numero: 1, totalParcelas: 2, valor: 200.00, vencimentoTexto: "Entrada (Paga)", pago: true, atrasada: false),
                    ParcelaItem(numero: 2, totalParcelas: 2, valor: 200.00, vencimentoTexto: "Atrasada há 4 dias", pago: false, atrasada: true)
                ]
            ),
            
            // 2. Serviço Parcelado em 3x (1ª paga, 2ª vence hoje, 3ª mês que vem) -> Seu Carlos
            ServicoItem(
                cliente: seuCarlos,
                tituloServico: "Pintura da Fachada",
                iconeSistema: "paintbrush.pointed.fill",
                emoji: "🎨",
                valor: 1200.00,
                dataCriacao: cal.date(byAdding: .day, value: -10, to: hoje) ?? hoje,
                dataAgendada: cal.date(byAdding: .day, value: -8, to: hoje) ?? hoje,
                status: .prontoCobrar,
                temFotoAnexa: true,
                observacaoFalada: "Pintura completa da frente da padaria em 3 parcelas de 400 reais",
                parcelas: [
                    ParcelaItem(numero: 1, totalParcelas: 3, valor: 400.00, vencimentoTexto: "1ª Parcela (Paga)", pago: true, atrasada: false),
                    ParcelaItem(numero: 2, totalParcelas: 3, valor: 400.00, vencimentoTexto: "Vence HOJE", pago: false, atrasada: false),
                    ParcelaItem(numero: 3, totalParcelas: 3, valor: 400.00, vencimentoTexto: "Dia 15 (Mês que vem)", pago: false, atrasada: false)
                ]
            ),
            
            // 3. Serviço Parcelado em 2x (Entrada paga, falta 2ª parcela na entrega) -> Roberto Mecânico
            ServicoItem(
                cliente: oficinaRoberto,
                tituloServico: "Tomadas Trifásicas",
                iconeSistema: "bolt.fill",
                emoji: "⚡",
                valor: 500.00,
                dataCriacao: cal.date(byAdding: .day, value: -2, to: hoje) ?? hoje,
                dataAgendada: cal.date(byAdding: .day, value: 1, to: hoje) ?? hoje,
                status: .fazendo,
                temFotoAnexa: false,
                observacaoFalada: "Metade de entrada e metade quando terminar",
                parcelas: [
                    ParcelaItem(numero: 1, totalParcelas: 2, valor: 250.00, vencimentoTexto: "Entrada (Paga)", pago: true, atrasada: false),
                    ParcelaItem(numero: 2, totalParcelas: 2, valor: 250.00, vencimentoTexto: "Na Entrega (Amanhã)", pago: false, atrasada: false)
                ]
            ),
            
            // 4. Serviço À Vista Aguardando Pagamento -> Dona Maria
            ServicoItem(
                cliente: donaMaria,
                tituloServico: "Pintura da Sala",
                iconeSistema: "paintbrush.pointed.fill",
                emoji: "🎨",
                valor: 300.00,
                dataCriacao: cal.date(byAdding: .day, value: -2, to: hoje) ?? hoje,
                dataAgendada: hoje,
                status: .prontoCobrar,
                temFotoAnexa: true,
                observacaoFalada: "Pintura da sala da Dona Maria trezentos reais",
                parcelas: [
                    ParcelaItem(numero: 1, totalParcelas: 1, valor: 300.00, vencimentoTexto: "Vence HOJE", pago: false, atrasada: false)
                ]
            ),
            
            // 5. Já Recebidos 100% (No Bolso)
            ServicoItem(
                cliente: donaMaria,
                tituloServico: "Troca de Fiação",
                iconeSistema: "bolt.fill",
                emoji: "⚡",
                valor: 250.00,
                dataCriacao: cal.date(byAdding: .day, value: -5, to: hoje) ?? hoje,
                dataAgendada: cal.date(byAdding: .day, value: -4, to: hoje) ?? hoje,
                status: .pago,
                temFotoAnexa: true,
                observacaoFalada: "Troca de fiação do chuveiro e duas tomadas da cozinha",
                parcelas: [
                    ParcelaItem(numero: 1, totalParcelas: 1, valor: 250.00, vencimentoTexto: "Pago à Vista", pago: true, atrasada: false)
                ]
            ),
            ServicoItem(
                cliente: draPaula,
                tituloServico: "Muro dos Fundos",
                iconeSistema: "building.2.crop.circle.fill",
                emoji: "🧱",
                valor: 2000.00,
                dataCriacao: cal.date(byAdding: .day, value: -14, to: hoje) ?? hoje,
                dataAgendada: cal.date(byAdding: .day, value: -12, to: hoje) ?? hoje,
                status: .pago,
                temFotoAnexa: false,
                observacaoFalada: "Reboco e acerto do muro dos fundos em 2 vezes pagas",
                parcelas: [
                    ParcelaItem(numero: 1, totalParcelas: 2, valor: 1000.00, vencimentoTexto: "1ª Parcela (Paga)", pago: true, atrasada: false),
                    ParcelaItem(numero: 2, totalParcelas: 2, valor: 1000.00, vencimentoTexto: "2ª Parcela (Paga)", pago: true, atrasada: false)
                ]
            ),
            
            // 6. Orçamentos enviados (Combinando)
            ServicoItem(
                cliente: seuCarlos,
                tituloServico: "Cano da Pia",
                iconeSistema: "drop.fill",
                emoji: "🚰",
                valor: 180.00,
                dataCriacao: hoje,
                dataAgendada: cal.date(byAdding: .day, value: 2, to: hoje) ?? hoje,
                status: .combinando,
                temFotoAnexa: true,
                observacaoFalada: "Tirar vazamento embaixo do balcão"
            ),
            ServicoItem(
                cliente: draPaula,
                tituloServico: "Podar Jardim",
                iconeSistema: "leaf.fill",
                emoji: "🌿",
                valor: 350.00,
                dataCriacao: hoje,
                dataAgendada: cal.date(byAdding: .day, value: 3, to: hoje) ?? hoje,
                status: .combinando,
                temFotoAnexa: false,
                observacaoFalada: "Cortar grama e podar cerca viva da frente"
            )
        ]
    }
    
    // MARK: - Cálculos Financeiros Claros (Por Parcelas!)
    /// Soma todas as parcelas já pagas (mesmo que o serviço ainda tenha parcelas futuras)
    var totalNoBolso: Double {
        servicos
            .filter { $0.status != .combinando }
            .reduce(0) { $0 + $1.valorJaPago }
    }
    
    /// Soma todas as parcelas em aberto de serviços em andamento ou finalizados
    var totalParaReceber: Double {
        servicos
            .filter { $0.status == .prontoCobrar || $0.status == .fazendo }
            .reduce(0) { $0 + $1.valorFaltaReceber }
    }
    
    /// Soma apenas parcelas vencidas/atrasadas (Cor Vermelha Semafórica)
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
    }
    
    func marcarComoPago(_ servico: ServicoItem) {
        guard let idx = servicos.firstIndex(where: { $0.id == servico.id }) else { return }
        for i in servicos[idx].parcelas.indices {
            servicos[idx].parcelas[i].pago = true
            servicos[idx].parcelas[i].atrasada = false
        }
        servicos[idx].status = .pago
    }
    
    func adicionarServico(_ novo: ServicoItem) {
        servicos.insert(novo, at: 0)
    }
    
    func adicionarCliente(_ cliente: Cliente) {
        clientes.insert(cliente, at: 0)
    }
    
    var resumoFaladoDoMes: String {
        let bolsoFormatado = FormatadorMoeda.falarReais(totalNoBolso)
        let receberFormatado = FormatadorMoeda.falarReais(totalParaReceber)
        let comparacao = subiuNesteMes
            ? "Parabéns \(nomeProfissional)! Neste mês você já ganhou mais do que no mês passado!"
            : "Atenção \(nomeProfissional), falta um pouquinho para alcançar o mês passado. Você tem \(receberFormatado) na rua para receber."
        
        return "Olá, \(nomeProfissional)! Aqui é o resumo do seu mês. No bolso, você já recebeu \(bolsoFormatado). Para receber na rua, você tem \(receberFormatado). \(comparacao)"
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
