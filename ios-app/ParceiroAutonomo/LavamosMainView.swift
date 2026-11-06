import SwiftUI

struct LavamosMainView: View {
    @ObservedObject var store: LavamosStore
    
    @State private var abaSelecionada: Int = 0 // 0 = Início, 1 = Máquinas, 2 = Recarga, 3 = Histórico
    @State private var exibirModalAtivacao: Bool = false
    @State private var maquinaSelecionadaParaAtivar: MaquinaItem? = nil
    @State private var numeroDigitado: String = ""
    @State private var alertaResultado: (titulo: String, mensagem: String)? = nil
    @State private var exibirModalConfigTotem: Bool = false
    @State private var totemHostInput: String = ""
    @State private var totemPortaInput: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Topo Fixo com Identidade Lavamos Mais + Saldo
            cabecalhoSuperior
            
            // Conteúdo da Aba
            Group {
                if abaSelecionada == 0 {
                    abaInicio
                } else if abaSelecionada == 1 {
                    abaMaquinas
                } else if abaSelecionada == 2 {
                    abaRecarga
                } else {
                    abaHistorico
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Menu Inferior Fixo Sem Scroll
            menuInferior
        }
        .background(Color.lavamosFundo.ignoresSafeArea())
        .sheet(item: $maquinaSelecionadaParaAtivar) { maquina in
            modalConfirmarAtivacao(maquina)
        }
        .sheet(isPresented: $exibirModalConfigTotem) {
            modalConfiguracaoTotem
        }
        .alert(alertaResultado?.titulo ?? "", isPresented: Binding(
            get: { alertaResultado != nil },
            set: { if !$0 { alertaResultado = nil } }
        )) {
            Button("OK") { alertaResultado = nil }
        } message: {
            Text(alertaResultado?.mensagem ?? "")
        }
    }
    
    // MARK: - Cabeçalho
    private var cabecalhoSuperior: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("LAVAMOS MAIS")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.lavamosTexto)
                Text("Olá, \(store.nomeCliente)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.lavamosTextoSec)
            }
            
            Spacer()
            
            // Pílula de Saldo
            Button {
                abaSelecionada = 2
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.lavamosAzul)
                    Text("R$ \(Int(store.saldoReais)),00")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundColor(.lavamosTexto)
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.lavamosAzul)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
            }
            .buttonStyle(.plain)
            
            // Status Totem / Configuração de Conexão
            Button {
                totemHostInput = store.totemHost
                totemPortaInput = store.totemPorta
                exibirModalConfigTotem = true
            } label: {
                HStack(spacing: 5) {
                    Circle()
                        .fill(store.esp32Conectado ? Color.lavamosVerde : Color.lavamosLaranja)
                        .frame(width: 8, height: 8)
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(store.esp32Conectado ? .lavamosVerde : .lavamosTextoSec)
                }
                .padding(8)
                .background(Color.white)
                .clipShape(Circle())
            }

            // Sair
            Button {
                store.encerrarSessao()
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.lavamosTextoSec)
                    .padding(8)
                    .background(Color.white)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.03), radius: 4, y: 2)
    }
    
    // MARK: - Aba 0: Início
    private var abaInicio: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                // Timer de Ciclo Ativo (Se houver ciclo em andamento)
                if store.cicloAtivoSegundosRestantes > 0 {
                    cardCicloEmAndamento
                }
                
                // Botão Gigante de Ativar Máquina (QR Code / Número)
                cardAtivacaoRapida
                
                // Status da Loja em Tempo Real
                cardStatusLoja
                
                // Dicas de Lavagem
                cardDicas
            }
            .padding(18)
        }
    }
    
    private var cardCicloEmAndamento: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.lavamosVerde)
                        .frame(width: 10, height: 10)
                    Text("SEU CICLO ESTÁ RODANDO")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(.lavamosVerde)
                }
                Spacer()
                Text("\(store.cicloAtivoTipo.rawValue) #\(store.cicloAtivoMaquinaNumero ?? 1)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.lavamosTexto)
            }
            
            // Contagem Regressiva
            let min = store.cicloAtivoSegundosRestantes / 60
            let seg = store.cicloAtivoSegundosRestantes % 60
            
            HStack(spacing: 12) {
                Image(systemName: store.cicloAtivoTipo.icone)
                    .font(.system(size: 42))
                    .foregroundColor(.lavamosAzul)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(format: "%02d:%02d", min, seg))
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                        .foregroundColor(.lavamosTexto)
                    Text("Tempo restante estimado")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.lavamosTextoSec)
                }
                Spacer()
            }
            .padding(14)
            .background(Color.lavamosAzulClaro.opacity(0.5))
            .cornerRadius(16)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.lavamosVerde, lineWidth: 2)
        )
    }
    
    private var cardAtivacaoRapida: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ativar Máquina")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.lavamosTexto)
                    Text("Digite o número da lavadora ou secadora")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.lavamosTextoSec)
                }
                Spacer()
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 28))
                    .foregroundColor(.lavamosAzul)
            }
            
            HStack(spacing: 10) {
                TextField("Ex: 1, 2, 3...", text: $numeroDigitado)
                    .keyboardType(.numberPad)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .padding(14)
                    .background(Color.lavamosFundo)
                    .cornerRadius(14)
                
                Button {
                    if let n = Int(numeroDigitado) {
                        let res = store.ativarMaquina(numero: n)
                        alertaResultado = (res.sucesso ? "Tudo Certo!" : "Atenção", res.mensagem)
                        if res.sucesso { numeroDigitado = "" }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                        Text("Iniciar")
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color.lavamosAzul)
                    .cornerRadius(14)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
    }
    
    private var cardStatusLoja: some View {
        let livresLav = store.maquinas.filter { $0.tipo == .lavadora && $0.status == .disponivel }.count
        let livresSec = store.maquinas.filter { $0.tipo == .secadora && $0.status == .disponivel }.count
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Disponibilidade Agora")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.lavamosTexto)
            
            HStack(spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.lavamosVerdeClaro)
                            .frame(width: 48, height: 48)
                        Image(systemName: "washer.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.lavamosVerde)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(livresLav) Livres")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.lavamosTexto)
                        Text("Lavadoras")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.lavamosTextoSec)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.white)
                .cornerRadius(16)
                
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.lavamosVerdeClaro)
                            .frame(width: 48, height: 48)
                        Image(systemName: "dryer.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.lavamosVerde)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(livresSec) Livres")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.lavamosTexto)
                        Text("Secadoras")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.lavamosTextoSec)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.white)
                .cornerRadius(16)
            }
        }
    }
    
    private var cardDicas: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.lavamosAzul)
                Text("Como Usar a Lavanderia")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.lavamosTexto)
            }
            
            Text("1. Coloque as roupas na máquina e feche a trava.\n2. Sabão e amaciante são dosados automaticamente.\n3. Digite o número da máquina e toque em Iniciar.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.lavamosTextoSec)
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(18)
    }
    
    // MARK: - Aba 1: Máquinas
    private var abaMaquinas: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                HStack {
                    Text("Todas as Máquinas")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.lavamosTexto)
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                
                ForEach(store.maquinas) { maquina in
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(maquina.status == .disponivel ? Color.lavamosVerdeClaro : Color.lavamosLaranjaClaro)
                                .frame(width: 58, height: 58)
                            Image(systemName: maquina.tipo.icone)
                                .font(.system(size: 26))
                                .foregroundColor(maquina.status.cor)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Text("\(maquina.tipo.rawValue) #\(maquina.numero)")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.lavamosTexto)
                                
                                Text(maquina.status.rawValue)
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(maquina.status.cor)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(maquina.status.cor.opacity(0.12))
                                    .cornerRadius(6)
                            }
                            
                            if maquina.status == .emUso {
                                Text("Resta aprox. \(maquina.tempoRestanteMinutos) min")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(.lavamosLaranja)
                            } else {
                                Text("R$ \(Int(maquina.precoCiclo)),00 por ciclo")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.lavamosTextoSec)
                            }
                        }
                        
                        Spacer()
                        
                        if maquina.status == .disponivel {
                            Button {
                                maquinaSelecionadaParaAtivar = maquina
                            } label: {
                                Text("Ativar")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.lavamosVerde)
                                    .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(14)
                    .background(Color.white)
                    .cornerRadius(18)
                    .padding(.horizontal, 18)
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Aba 2: Recarga / Créditos
    private var abaRecarga: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Cartão Saldo Atual
                VStack(spacing: 8) {
                    Text("Seu Saldo Disponível")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                    Text("R$ \(Int(store.saldoReais)),00")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("Equivale a \(Int(store.saldoReais / 18)) ciclos de lavagem/secagem")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(
                    LinearGradient(
                        colors: [Color.lavamosAzul, Color.lavamosAzulEscuro],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(22)
                .shadow(color: Color.lavamosAzul.opacity(0.35), radius: 10, y: 5)
                
                Text("Escolha um Pacote de Créditos")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.lavamosTexto)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Pacotes
                pacoteItem(titulo: "1 Ciclo (Lavagem ou Secagem)", valor: 18.0, destaque: false)
                pacoteItem(titulo: "Combo Lavar + Secar (2 Ciclos)", valor: 36.0, destaque: true)
                pacoteItem(titulo: "Pacote Familiar (4 Ciclos)", valor: 70.0, destaque: false)
            }
            .padding(18)
        }
    }
    
    private func pacoteItem(titulo: String, valor: Double, destaque: Bool) -> some View {
        Button {
            store.adicionarSaldo(valor: valor)
            alertaResultado = ("Recarga Concluída!", "R$ \(Int(valor)),00 adicionados com sucesso ao seu saldo!")
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(titulo)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.lavamosTexto)
                    Text("Liberação instantânea via PIX / Cartão")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.lavamosTextoSec)
                }
                Spacer()
                Text("R$ \(Int(valor)),00")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(.lavamosAzulEscuro)
            }
            .padding(18)
            .background(Color.white)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(destaque ? Color.lavamosAzul : Color.clear, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Aba 3: Histórico
    private var abaHistorico: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                HStack {
                    Text("Histórico de Ciclos")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.lavamosTexto)
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                
                if store.historico.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 36))
                            .foregroundColor(.lavamosTextoSec)
                        Text("Nenhum ciclo realizado ainda.")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.lavamosTexto)
                    }
                    .padding(40)
                } else {
                    ForEach(store.historico) { item in
                        HStack(spacing: 14) {
                            Image(systemName: item.tipo.icone)
                                .font(.system(size: 22))
                                .foregroundColor(.lavamosAzul)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.descricao)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.lavamosTexto)
                                Text("Ciclo concluído")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.lavamosVerde)
                            }
                            
                            Spacer()
                            
                            Text("- R$ \(Int(item.valor)),00")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.lavamosTextoSec)
                        }
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal, 18)
                    }
                }
            }
        }
    }
    
    // MARK: - Menu Inferior Fixo
    private var menuInferior: some View {
        HStack(spacing: 0) {
            itemMenu(indice: 0, icone: "house.fill", titulo: "Início")
            itemMenu(indice: 1, icone: "washer.fill", titulo: "Máquinas")
            itemMenu(indice: 2, icone: "creditcard.fill", titulo: "Créditos")
            itemMenu(indice: 3, icone: "clock.fill", titulo: "Histórico")
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 6)
        .background(
            Color.white
                .ignoresSafeArea(edges: .bottom)
                .shadow(color: Color.black.opacity(0.06), radius: 6, y: -2)
        )
    }
    
    private func itemMenu(indice: Int, icone: String, titulo: String) -> some View {
        let ativo = abaSelecionada == indice
        return Button {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                abaSelecionada = indice
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icone)
                    .font(.system(size: 20, weight: ativo ? .bold : .medium))
                Text(titulo)
                    .font(.system(size: 11, weight: ativo ? .bold : .medium, design: .rounded))
            }
            .foregroundColor(ativo ? Color.lavamosAzul : Color.lavamosTextoSec)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(ativo ? Color.lavamosAzulClaro.opacity(0.6) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
    
    // Modal de Confirmação de Ativação
    private func modalConfirmarAtivacao(_ maquina: MaquinaItem) -> some View {
        VStack(spacing: 20) {
            Image(systemName: maquina.tipo.icone)
                .font(.system(size: 48))
                .foregroundColor(.lavamosAzul)
            
            Text("Iniciar \(maquina.tipo.rawValue) #\(maquina.numero)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.lavamosTexto)
            
            Text("O valor de R$ \(Int(maquina.precoCiclo)),00 será debitado do seu saldo. A máquina começará a funcionar imediatamente.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.lavamosTextoSec)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Button {
                maquinaSelecionadaParaAtivar = nil
                let res = store.ativarMaquina(numero: maquina.numero)
                alertaResultado = (res.sucesso ? "Tudo Certo!" : "Atenção", res.mensagem)
            } label: {
                Text("Confirmar e Iniciar Ciclo")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.lavamosVerde)
                    .cornerRadius(16)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
        }
        .padding(24)
        .presentationDetents([.fraction(0.45)])
    }
    
    // Modal de Configuração do Totem ESP32
    private var modalConfiguracaoTotem: some View {
        VStack(spacing: 20) {
            Image(systemName: "cpu.fill")
                .font(.system(size: 44))
                .foregroundColor(.lavamosAzul)
            
            Text("Conexão Totem Speed Queen")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.lavamosTexto)
            
            HStack(spacing: 8) {
                Circle()
                    .fill(store.esp32Conectado ? Color.lavamosVerde : Color.lavamosLaranja)
                    .frame(width: 10, height: 10)
                Text(store.esp32Conectado ? "ESP32 Conectado e Operacional" : "Totem ESP32 Offline / Aguardando")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(store.esp32Conectado ? .lavamosVerde : .lavamosLaranja)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(store.esp32Conectado ? Color.lavamosVerdeClaro : Color.lavamosLaranjaClaro)
            .cornerRadius(12)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("IP do Servidor Totem / ESP32")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.lavamosTextoSec)
                    TextField("Ex: 192.168.15.23", text: $totemHostInput)
                        .font(.system(size: 15, weight: .semibold, design: .monospaced))
                        .keyboardType(.numbersAndPunctuation)
                        .autocapitalization(.none)
                        .padding(12)
                        .background(Color.lavamosFundo)
                        .cornerRadius(10)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Porta da API")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.lavamosTextoSec)
                    TextField("Ex: 8080", text: $totemPortaInput)
                        .font(.system(size: 15, weight: .semibold, design: .monospaced))
                        .keyboardType(.numberPad)
                        .padding(12)
                        .background(Color.lavamosFundo)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 16)
            
            HStack(spacing: 12) {
                Button {
                    store.totemHost = totemHostInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    store.totemPorta = totemPortaInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    store.verificarConexaoTotem()
                } label: {
                    Text("Testar Conexão")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.lavamosAzul)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.lavamosAzulClaro)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                
                Button {
                    store.totemHost = totemHostInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    store.totemPorta = totemPortaInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    store.salvarEstado()
                    store.verificarConexaoTotem()
                    exibirModalConfigTotem = false
                } label: {
                    Text("Salvar")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.lavamosAzul)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            
            Spacer()
        }
        .padding(20)
        .presentationDetents([.fraction(0.55)])
    }
}
