import SwiftUI

enum FiltroMaquina: String, CaseIterable {
    case todas = "Todas"
    case lavadoras = "Lavadoras"
    case secadoras = "Secadoras"
}

// MARK: - Shape de Ondinhas de Água (Senoide Contínua)
struct OndaAguaShape: Shape {
    var fase: Double
    var nivelPreenchimento: Double // 0.0 a 1.0
    var amplitude: CGFloat = 5.0
    
    var animatableData: Double {
        get { fase }
        set { fase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let largura = rect.width
        let altura = rect.height
        let yBase = altura * CGFloat(1.0 - nivelPreenchimento)
        
        path.move(to: CGPoint(x: 0, y: altura))
        path.addLine(to: CGPoint(x: 0, y: yBase))
        
        let passo: CGFloat = 2.0
        for x in stride(from: 0, through: largura, by: passo) {
            let relX = Double(x / largura)
            let seno = sin((relX * 2.0 * .pi) + fase)
            let y = yBase + CGFloat(seno) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: largura, y: altura))
        path.closeSubpath()
        return path
    }
}

// MARK: - Shape de Onda de Calor Vertical (Secadora)
struct OndaCalorVerticalShape: Shape {
    var fase: Double
    
    var animatableData: Double {
        get { fase }
        set { fase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let h = rect.height
        let midX = rect.midX
        path.move(to: CGPoint(x: midX, y: h))
        for y in stride(from: h, through: 0, by: -2.0) {
            let relY = Double(y / h)
            let offset = sin((relY * 2.5 * .pi) + fase) * 4.5
            path.addLine(to: CGPoint(x: midX + CGFloat(offset), y: y))
        }
        return path
    }
}

// MARK: - Visor Circular (Recipiente) com Água/Bolhas ou Secagem Térmica
struct VisorTamborAnimadoView: View {
    let tipo: TipoMaquina
    let emUso: Bool
    let progresso: Double // 0.0 a 1.0
    
    @State private var faseOnda: Double = 0
    @State private var anguloTambor: Double = 0
    @State private var pulsoCalor: Bool = false
    @State private var subirBolhas: Bool = false
    
    var body: some View {
        ZStack {
            // Fundo do Visor
            Circle()
                .fill(tipo == .lavadora ? Color(red: 248/255, green: 250/255, blue: 252/255) : Color(red: 255/255, green: 247/255, blue: 237/255))
            
            if tipo == .lavadora {
                // --- LAVADORA: Água enchendo com ondinhas + bolhas ---
                let nivel = emUso ? min(0.85, 0.45 + progresso * 0.40) : 0.20
                
                // Onda traseira
                OndaAguaShape(fase: -faseOnda, nivelPreenchimento: nivel, amplitude: emUso ? 5.5 : 2.5)
                    .fill(Color.lavamosAzul.opacity(0.35))
                
                // Onda frontal
                OndaAguaShape(fase: faseOnda, nivelPreenchimento: nivel, amplitude: emUso ? 4.5 : 2.0)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 56/255, green: 189/255, blue: 248/255), Color.lavamosAzul],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Bolhas de sabão subindo quando em uso
                if emUso {
                    ZStack {
                        bolhaItem(xOffset: -18, tamanho: 8, delay: 0.0)
                        bolhaItem(xOffset: -4,  tamanho: 11, delay: 0.4)
                        bolhaItem(xOffset: 12,  tamanho: 7, delay: 0.8)
                        bolhaItem(xOffset: 20,  tamanho: 10, delay: 0.2)
                        bolhaItem(xOffset: -10, tamanho: 6, delay: 1.1)
                    }
                }
                
                // Ícone Central
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.92))
                        .frame(width: 34, height: 34)
                        .shadow(color: Color.black.opacity(0.06), radius: 4, y: 2)
                    
                    Image(systemName: "drop.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.lavamosAzul)
                        .rotationEffect(.degrees(emUso ? (pulsoCalor ? 18 : -18) : 0))
                }
            } else {
                // --- SECADORA: Tambor girando + Ondas de ar quente subindo ---
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.lavamosSecadora.opacity(emUso ? (pulsoCalor ? 0.35 : 0.15) : 0.08),
                                Color.clear
                            ],
                            center: .bottom,
                            startRadius: 4,
                            endRadius: 46
                        )
                    )
                
                // Anel do tambor perfurado girando
                Circle()
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 2.2, dash: [6, 5])
                    )
                    .foregroundColor(Color.lavamosSecadora.opacity(emUso ? 0.65 : 0.28))
                    .padding(10)
                    .rotationEffect(.degrees(anguloTambor))
                
                // Ondas de calor subindo quando em uso
                if emUso {
                    HStack(spacing: 10) {
                        OndaCalorVerticalShape(fase: faseOnda)
                            .stroke(Color.lavamosSecadora.opacity(0.55), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .frame(width: 10, height: 38)
                        
                        OndaCalorVerticalShape(fase: faseOnda + 1.5)
                            .stroke(Color.lavamosSecadora.opacity(0.75), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .frame(width: 10, height: 42)
                        
                        OndaCalorVerticalShape(fase: faseOnda + 3.0)
                            .stroke(Color.lavamosSecadora.opacity(0.55), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .frame(width: 10, height: 38)
                    }
                    .offset(y: 6)
                }
                
                // Ícone Central
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.92))
                        .frame(width: 34, height: 34)
                        .shadow(color: Color.black.opacity(0.06), radius: 4, y: 2)
                    
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.lavamosSecadora)
                        .rotationEffect(.degrees(anguloTambor))
                }
            }
        }
        .frame(width: 86, height: 86)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(
                    emUso ? (tipo == .lavadora ? Color(red: 56/255, green: 189/255, blue: 248/255) : Color.lavamosSecadora) : Color.lavamosBorda,
                    lineWidth: 3.5
                )
        )
        .onAppear {
            iniciarAnimacoes()
        }
        .onChange(of: emUso) { _ in
            iniciarAnimacoes()
        }
    }
    
    private func bolhaItem(xOffset: CGFloat, tamanho: CGFloat, delay: Double) -> some View {
        Circle()
            .fill(Color.white.opacity(0.85))
            .frame(width: tamanho, height: tamanho)
            .offset(x: xOffset, y: subirBolhas ? -32 : 34)
            .opacity(subirBolhas ? 0.0 : 0.95)
            .animation(
                .easeIn(duration: 1.9).repeatForever(autoreverses: false).delay(delay),
                value: subirBolhas
            )
    }
    
    private func iniciarAnimacoes() {
        withAnimation(.linear(duration: 2.2).repeatForever(autoreverses: false)) {
            faseOnda = .pi * 2
        }
        if emUso {
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                anguloTambor = 360
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulsoCalor = true
            }
            subirBolhas = true
        } else {
            anguloTambor = 0
            pulsoCalor = false
            subirBolhas = false
        }
    }
}

struct LavamosMainView: View {
    @ObservedObject var store: LavamosStore
    
    @State private var filtroAtual: FiltroMaquina = .todas
    @State private var maquinaParaAtivar: MaquinaItem? = nil
    @State private var exibirRecarga: Bool = false
    @State private var exibirAjustes: Bool = false
    @State private var totemHostInput: String = ""
    @State private var totemPortaInput: String = ""
    @State private var mensagemToast: String? = nil
    @State private var faseOndaCard: Double = 0
    
    private let colunasGrid = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    private var maquinasFiltradas: [MaquinaItem] {
        switch filtroAtual {
        case .todas:
            return store.maquinas
        case .lavadoras:
            return store.maquinas.filter { $0.tipo == .lavadora }
        case .secadoras:
            return store.maquinas.filter { $0.tipo == .secadora }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                barraSuperior
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        if store.cicloAtivoSegundosRestantes > 0 {
                            bannerCicloAtivo
                        }
                        
                        barraFiltros
                        
                        LazyVGrid(columns: colunasGrid, spacing: 12) {
                            ForEach(maquinasFiltradas) { maquina in
                                cardMaquina(maquina)
                            }
                        }
                        
                        if !store.historico.isEmpty {
                            secaoRecentes
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
            }
            .background(Color.lavamosFundo.ignoresSafeArea())
            
            if let toast = mensagemToast {
                Text(toast)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.lavamosTexto)
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.15), radius: 10, y: 4)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                faseOndaCard = .pi * 2
            }
        }
        .sheet(item: $maquinaParaAtivar) { maquina in
            sheetConfirmarMaquina(maquina)
        }
        .sheet(isPresented: $exibirRecarga) {
            sheetRecarregarSaldo
        }
        .sheet(isPresented: $exibirAjustes) {
            sheetAjustesConexao
        }
    }
    
    // MARK: - Barra Superior Clean
    private var barraSuperior: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Lavamos Mais")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(.lavamosTexto)
                Text("Toque na máquina para iniciar")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.lavamosTextoSec)
            }
            
            Spacer()
            
            Button {
                exibirRecarga = true
            } label: {
                HStack(spacing: 6) {
                    Text("R$ \(Int(store.saldoReais))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.lavamosAzul)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(Color.lavamosAzul)
                        .clipShape(Circle())
                }
                .padding(.leading, 12)
                .padding(.trailing, 6)
                .padding(.vertical, 6)
                .background(Color.lavamosAzulClaro)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            
            Button {
                totemHostInput = store.totemHost
                totemPortaInput = store.totemPorta
                exibirAjustes = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.lavamosTextoSec)
                        .frame(width: 34, height: 34)
                        .background(Color.lavamosFundo)
                        .clipShape(Circle())
                    
                    Circle()
                        .fill(store.esp32Conectado ? Color.lavamosVerde : Color.lavamosLaranja)
                        .frame(width: 8, height: 8)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(Color.lavamosBorda)
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Banner Dinâmico de Ciclo em Andamento
    private var bannerCicloAtivo: some View {
        let min = store.cicloAtivoSegundosRestantes / 60
        let seg = store.cicloAtivoSegundosRestantes % 60
        let num = store.cicloAtivoMaquinaNumero ?? 1
        let isSec = store.cicloAtivoTipo == .secadora
        
        return HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(isSec ? Color.lavamosSecadora : Color(red: 56/255, green: 189/255, blue: 248/255))
                        .frame(width: 8, height: 8)
                    Text(isSec ? "SECANDO COM AR QUENTE" : "LAVANDO COM ÁGUA E SABÃO")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(isSec ? Color.lavamosSecadora : Color(red: 56/255, green: 189/255, blue: 248/255))
                }
                
                Text("\(store.cicloAtivoTipo.rawValue) #0\(num)")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text(String(format: "%02d:%02d", min, seg))
                .font(.system(size: 26, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(16)
        .background(Color.lavamosTexto)
        .cornerRadius(16)
    }
    
    // MARK: - Filtros Rápidos
    private var barraFiltros: some View {
        HStack(spacing: 8) {
            ForEach(FiltroMaquina.allCases, id: \.self) { item in
                let selecionado = filtroAtual == item
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        filtroAtual = item
                    }
                } label: {
                    Text(item.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(selecionado ? .white : .lavamosTextoSec)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(selecionado ? Color.lavamosTexto : Color.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(selecionado ? Color.lavamosTexto : Color.lavamosBorda, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }
    
    // MARK: - Card da Máquina com Recipiente Enchendo / Secando
    private func cardMaquina(_ maquina: MaquinaItem) -> some View {
        let livre = maquina.status == .disponivel
        let isSecadora = maquina.tipo == .secadora
        let corDestaque = isSecadora ? Color.lavamosSecadora : Color.lavamosAzul
        
        // Calcula progresso se for a máquina ativa
        let totalSeg = Double(maquina.tipo.duracaoPadrao * 60)
        let progresso: Double = {
            if !livre {
                if store.cicloAtivoMaquinaNumero == maquina.numero && store.cicloAtivoSegundosRestantes > 0 {
                    return max(0.15, (totalSeg - Double(store.cicloAtivoSegundosRestantes)) / totalSeg)
                }
                return 0.55
            }
            return 0.0
        }()
        
        return Button {
            if livre {
                maquinaParaAtivar = maquina
            } else {
                mostrarToast("\(maquina.tipo.rawValue) #0\(maquina.numero) está em andamento.")
            }
        } label: {
            ZStack(alignment: .bottom) {
                Color.white
                
                // Recipiente suave subindo no fundo do card quando em uso
                if !livre {
                    OndaAguaShape(
                        fase: faseOndaCard,
                        nivelPreenchimento: min(0.85, 0.35 + progresso * 0.45),
                        amplitude: 4.0
                    )
                    .fill(
                        LinearGradient(
                            colors: isSecadora
                                ? [Color.lavamosSecadora.opacity(0.08), Color.lavamosSecadora.opacity(0.18)]
                                : [Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.10), Color.lavamosAzul.opacity(0.20)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                
                VStack(spacing: 12) {
                    // Topo: Número + Badge
                    HStack {
                        Text("#0\(maquina.numero)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.lavamosTexto)
                        
                        Spacer()
                        
                        Text(livre ? "Livre" : (isSecadora ? "Secando" : "Lavando"))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(
                                livre
                                ? Color(red: 6/255, green: 95/255, blue: 70/255)
                                : corDestaque
                            )
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(
                                livre
                                ? Color.lavamosVerdeClaro
                                : (isSecadora ? Color.lavamosSecadoraClaro : Color.lavamosAzulClaro)
                            )
                            .clipShape(Capsule())
                    }
                    
                    // Tambor / Recipiente Central Animado
                    VisorTamborAnimadoView(
                        tipo: maquina.tipo,
                        emUso: !livre,
                        progresso: progresso
                    )
                    .padding(.vertical, 2)
                    
                    // Nome e Tempo
                    VStack(spacing: 2) {
                        Text(maquina.tipo.rawValue)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.lavamosTexto)
                        
                        if livre {
                            Text("\(maquina.tipo.duracaoPadrao) min • R$ \(Int(maquina.precoCiclo))")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.lavamosTextoSec)
                        } else if store.cicloAtivoMaquinaNumero == maquina.numero {
                            let m = store.cicloAtivoSegundosRestantes / 60
                            let s = store.cicloAtivoSegundosRestantes % 60
                            Text(String(format: "Restam %02d:%02d", m, s))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(corDestaque)
                        } else {
                            Text("Restam ~\(maquina.tempoRestanteMinutos) min")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(corDestaque)
                        }
                    }
                    
                    // Botão de Ação
                    Text(livre ? "Iniciar" : "Em uso")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(livre ? .white : .lavamosTextoSec)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(livre ? corDestaque : Color.black.opacity(0.06))
                        .cornerRadius(10)
                }
                .padding(14)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        livre ? Color.lavamosBorda : corDestaque.opacity(0.45),
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Seção Compacta de Últimos Usos
    private var secaoRecentes: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Últimos ciclos")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.lavamosTextoSec)
                .padding(.top, 6)
            
            ForEach(store.historico.prefix(3)) { item in
                HStack {
                    Image(systemName: item.tipo.icone)
                        .font(.system(size: 15))
                        .foregroundColor(.lavamosTextoSec)
                        .frame(width: 28, height: 28)
                        .background(Color.lavamosFundo)
                        .clipShape(Circle())
                    
                    Text(item.descricao)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.lavamosTexto)
                    
                    Spacer()
                    
                    Text("R$ \(Int(item.valor))")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.lavamosTextoSec)
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.lavamosBorda, lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Sheet de Confirmação
    private func sheetConfirmarMaquina(_ maquina: MaquinaItem) -> some View {
        let temSaldo = store.saldoReais >= maquina.precoCiclo
        
        return VStack(spacing: 18) {
            Capsule()
                .fill(Color.lavamosBorda)
                .frame(width: 38, height: 5)
                .padding(.top, 8)
            
            VStack(spacing: 6) {
                Text("\(maquina.tipo.rawValue) #0\(maquina.numero)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.lavamosTexto)
                
                Text("Ciclo de \(maquina.tipo.duracaoPadrao) minutos • R$ \(Int(maquina.precoCiclo)),00")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.lavamosTextoSec)
            }
            
            if temSaldo {
                Button {
                    let num = maquina.numero
                    maquinaParaAtivar = nil
                    let res = store.ativarMaquina(numero: num)
                    mostrarToast(res.mensagem)
                } label: {
                    Text("Confirmar e Liberar Máquina")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.lavamosVerde)
                        .cornerRadius(14)
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    store.adicionarSaldo(valor: maquina.precoCiclo)
                    let num = maquina.numero
                    maquinaParaAtivar = nil
                    let res = store.ativarMaquina(numero: num)
                    mostrarToast(res.mensagem)
                } label: {
                    Text("Pagar R$ \(Int(maquina.precoCiclo)) via PIX e Liberar")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.lavamosAzul)
                        .cornerRadius(14)
                }
                .buttonStyle(.plain)
            }
            
            Button {
                maquinaParaAtivar = nil
            } label: {
                Text("Cancelar")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.lavamosTextoSec)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .presentationDetents([.height(260)])
    }
    
    // MARK: - Sheet de Recarga Rápida
    private var sheetRecarregarSaldo: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.lavamosBorda)
                .frame(width: 38, height: 5)
                .padding(.top, 8)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Adicionar Saldo")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.lavamosTexto)
                    Text("Saldo atual: R$ \(Int(store.saldoReais)),00")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.lavamosTextoSec)
                }
                Spacer()
            }
            
            VStack(spacing: 10) {
                botaoRecargaRapida(titulo: "1 Ciclo (Lavar ou Secar)", valor: 18)
                botaoRecargaRapida(titulo: "2 Ciclos (Lavar + Secar)", valor: 36)
                botaoRecargaRapida(titulo: "4 Ciclos", valor: 72)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .presentationDetents([.height(320)])
    }
    
    private func botaoRecargaRapida(titulo: String, valor: Double) -> some View {
        Button {
            store.adicionarSaldo(valor: valor)
            exibirRecarga = false
            mostrarToast("+ R$ \(Int(valor)),00 adicionados ao saldo")
        } label: {
            HStack {
                Text(titulo)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.lavamosTexto)
                Spacer()
                Text("+ R$ \(Int(valor))")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.lavamosAzul)
            }
            .padding(16)
            .background(Color.lavamosFundo)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Sheet de Ajustes do Totem
    private var sheetAjustesConexao: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.lavamosBorda)
                .frame(width: 38, height: 5)
                .padding(.top, 8)
            
            HStack {
                Text("Conexão do Totem")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.lavamosTexto)
                Spacer()
                HStack(spacing: 6) {
                    Circle()
                        .fill(store.esp32Conectado ? Color.lavamosVerde : Color.lavamosLaranja)
                        .frame(width: 8, height: 8)
                    Text(store.esp32Conectado ? "Online" : "Simulador")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.lavamosTextoSec)
                }
            }
            
            HStack(spacing: 10) {
                TextField("IP (ex: 192.168.15.23)", text: $totemHostInput)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .padding(12)
                    .background(Color.lavamosFundo)
                    .cornerRadius(10)
                
                TextField("Porta", text: $totemPortaInput)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .frame(width: 80)
                    .padding(12)
                    .background(Color.lavamosFundo)
                    .cornerRadius(10)
            }
            
            Button {
                store.totemHost = totemHostInput.trimmingCharacters(in: .whitespacesAndNewlines)
                store.totemPorta = totemPortaInput.trimmingCharacters(in: .whitespacesAndNewlines)
                store.salvarEstado()
                store.verificarConexaoTotem()
                exibirAjustes = false
                mostrarToast("Configuração salva")
            } label: {
                Text("Salvar Conexão")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.lavamosAzul)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
            
            Divider()
            
            Button {
                exibirAjustes = false
                store.encerrarSessao()
            } label: {
                Text("Trocar de usuário / Sair")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.red)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .presentationDetents([.height(310)])
    }
    
    private func mostrarToast(_ texto: String) {
        withAnimation {
            mensagemToast = texto
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation {
                if mensagemToast == texto {
                    mensagemToast = nil
                }
            }
        }
    }
}
