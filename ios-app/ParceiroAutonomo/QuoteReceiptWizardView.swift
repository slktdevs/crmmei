import SwiftUI

struct QuoteReceiptWizardView: View {
    @ObservedObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    
    let tipoDocumento: TipoDocumento
    var servicoPreSelecionado: ServicoItem? = nil
    
    @State private var passoAtual: Int = 1
    
    // Estado Passo 1: Cliente
    @State private var clienteSelecionado: Cliente? = nil
    @State private var mostrarAlertaImportadoWhatsApp: Bool = false
    
    // Estado Passo 2: O que vai ser feito + Valor + Parcelas + Foto
    @State private var itemCatalogoSelecionado: CatalogoItem? = nil
    @State private var descricaoDigitada: String = ""
    @State private var valorString: String = "250"
    @State private var quantidadeParcelas: Int = 1
    @State private var temFotoLocalAnexada: Bool = false
    
    // Estado Passo 3: PDF pronto e confirmação de envio
    @State private var urlPDFGerado: URL? = nil
    @State private var mostrarConfirmacaoEnvioWhatsApp: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                barraPassosVisuais
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        if passoAtual == 1 {
                            passo1QuemEOCliente
                        } else if passoAtual == 2 {
                            passo2OQueVaiSerFeito
                        } else {
                            passo3ProntoParaEnviar
                        }
                    }
                    .padding(18)
                }
                
                rodapeBotoesNavegacao
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                            Text("Fechar")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.semaforoVermelho)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(tipoDocumento.rawValue)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.inkPrimary)
                }
            }
            .onAppear {
                configurarDadosIniciais()
            }
            .alert("Enviado para o WhatsApp", isPresented: $mostrarConfirmacaoEnvioWhatsApp) {
                Button("Voltar para o Início") {
                    salvarNoAppStore()
                    dismiss()
                }
            } message: {
                Text("O PDF de \(clienteEfetivo.nome) no valor de \(FormatadorMoeda.string(valorNumerico)) já está pronto para conversa no WhatsApp.")
            }
        }
    }
    
    // MARK: - Dados Efetivos Computados
    private var clienteEfetivo: Cliente {
        clienteSelecionado ?? store.clientes.first ?? Cliente(nome: "Dona Maria", apelidoOuBairro: "Casa Verde", telefone: "(11) 99123-4567", emojiAvatar: "")
    }
    
    private var valorNumerico: Double {
        Double(valorString.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
    
    private var tituloServicoEfetivo: String {
        if let item = itemCatalogoSelecionado {
            return item.nomeCurto
        }
        if !descricaoDigitada.isEmpty {
            return descricaoDigitada
        }
        return "Serviço Geral"
    }
    
    private var iconeServicoEfetivo: String {
        itemCatalogoSelecionado?.iconeSistema ?? "wrench.and.screwdriver"
    }
    
    private func configurarDadosIniciais() {
        if let pre = servicoPreSelecionado {
            clienteSelecionado = pre.cliente
            descricaoDigitada = pre.observacaoFalada.isEmpty ? pre.tituloServico : pre.observacaoFalada
            valorString = String(Int(pre.valor))
            temFotoLocalAnexada = pre.temFotoAnexa
            passoAtual = 3
            gerarPDFAtualizado()
        } else {
            clienteSelecionado = store.clientes.first
            itemCatalogoSelecionado = store.catalogoServicos.first
            valorString = "300"
        }
    }
    
    // MARK: - Barra de 3 Passos Visuais Minimalista
    private var barraPassosVisuais: some View {
        HStack(spacing: 8) {
            indicadorPasso(numero: 1, titulo: "Cliente")
            indicadorPasso(numero: 2, titulo: "Serviço")
            indicadorPasso(numero: 3, titulo: "Pronto")
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 1.5)
                .foregroundColor(Color.black.opacity(0.08)),
            alignment: .bottom
        )
    }
    
    private func indicadorPasso(numero: Int, titulo: String) -> some View {
        let ativo = passoAtual == numero
        let concluido = passoAtual > numero
        let corFundo: Color = concluido ? .semaforoVerde : (ativo ? .semaforoAzul : Color.appBackground)
        let corTexto: Color = (ativo || concluido) ? .white : .inkSecondary
        
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                passoAtual = numero
                if numero == 3 {
                    gerarPDFAtualizado()
                }
            }
        } label: {
            Text("\(numero). \(titulo)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(corTexto)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(corFundo)
                )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - PASSO 1: Quem é o Cliente?
    private var passo1QuemEOCliente: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("1. Quem é o cliente?")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.inkPrimary)
            
            Button {
                let novoContato = Cliente(
                    nome: "Seu Antônio",
                    apelidoOuBairro: "Importado da Agenda",
                    telefone: "(11) 99777-1234",
                    emojiAvatar: ""
                )
                store.adicionarCliente(novoContato)
                clienteSelecionado = novoContato
                mostrarAlertaImportadoWhatsApp = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 22, weight: .semibold))
                    Text("Importar da Agenda / WhatsApp")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(18)
            }
            .buttonStyle(
                PhysicalButtonStyle(
                    baseColor: .semaforoVerde,
                    shadowColor: .semaforoVerdeEscuro,
                    cornerRadius: 18
                )
            )
            
            if mostrarAlertaImportadoWhatsApp {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.semaforoVerdeEscuro)
                    Text("Contato importado com sucesso")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.semaforoVerdeEscuro)
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.semaforoVerdeFundo))
            }
            
            Text("Selecione na sua lista:")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.inkSecondary)
            
            VStack(spacing: 10) {
                ForEach(store.clientes) { cliente in
                    let selecionado = clienteSelecionado?.id == cliente.id
                    Button {
                        clienteSelecionado = cliente
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(selecionado ? Color.semaforoAzul : Color.semaforoAzulFundo)
                                    .frame(width: 54, height: 54)
                                Text(cliente.iniciais)
                                    .font(.system(size: 19, weight: .bold, design: .rounded))
                                    .foregroundColor(selecionado ? .white : .semaforoAzul)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(cliente.nome)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.inkPrimary)
                                Text(cliente.apelidoOuBairro)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.inkSecondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: selecionado ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundColor(selecionado ? .semaforoAzul : .inkSecondary.opacity(0.3))
                        }
                        .padding(16)
                        .accessibleCard(
                            borderColor: selecionado ? .semaforoAzul : Color.black.opacity(0.1),
                            backgroundColor: selecionado ? Color.semaforoAzulFundo.opacity(0.4) : .white
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - PASSO 2: O que vai ser feito?
    private var passo2OQueVaiSerFeito: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("2. O que vai ser feito?")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.inkPrimary)
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ],
                spacing: 10
            ) {
                ForEach(store.catalogoServicos) { item in
                    let selecionado = itemCatalogoSelecionado?.id == item.id
                    Button {
                        itemCatalogoSelecionado = item
                        valorString = String(Int(item.valorSugerido))
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: item.iconeSistema)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(selecionado ? .white : .semaforoAzul)
                            Text(item.nomeCurto)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(selecionado ? .white : .inkPrimary)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(selecionado ? Color.semaforoAzul : Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(selecionado ? Color.semaforoAzulEscuro : Color.black.opacity(0.12), lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Descrição ou Observação")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.inkPrimary)
                
                TextField("Ex: Pintura completa da sala...", text: $descricaoDigitada)
                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.appBackground))
            }
            .padding(16)
            .accessibleCard()
            
            tecladoGiganteMaquininha
            
            seletorParcelamentoVisual
            
            Button {
                temFotoLocalAnexada.toggle()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "camera")
                        .font(.system(size: 20, weight: .semibold))
                    Text(temFotoLocalAnexada ? "Foto do Local Anexada" : "Anexar Foto do Local")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(18)
            }
            .buttonStyle(
                PhysicalButtonStyle(
                    baseColor: temFotoLocalAnexada ? .semaforoVerde : .semaforoAzul,
                    shadowColor: temFotoLocalAnexada ? .semaforoVerdeEscuro : .semaforoAzulEscuro,
                    cornerRadius: 18
                )
            )
        }
    }
    
    // MARK: - Teclado Numérico Gigante (Estilo Maquininha)
    private var tecladoGiganteMaquininha: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Valor do Serviço")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.inkPrimary)
                Spacer()
            }
            
            HStack {
                Text("R$")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.semaforoVerdeEscuro)
                Spacer()
                Text(valorString.isEmpty ? "0" : valorString)
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                    .foregroundColor(.semaforoVerdeEscuro)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.semaforoVerdeFundo)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.semaforoVerde, lineWidth: 2.5)
            )
            
            let teclas = [
                ["1", "2", "3"],
                ["4", "5", "6"],
                ["7", "8", "9"],
                ["00", "0", "⌫"]
            ]
            
            VStack(spacing: 10) {
                ForEach(teclas, id: \.self) { linha in
                    HStack(spacing: 10) {
                        ForEach(linha, id: \.self) { tecla in
                            Button {
                                tocarTeclaCalculadora(tecla)
                            } label: {
                                Group {
                                    if tecla == "⌫" {
                                        Image(systemName: "delete.left")
                                            .font(.system(size: 22, weight: .bold))
                                    } else {
                                        Text(tecla)
                                            .font(.system(size: 26, weight: .bold, design: .rounded))
                                    }
                                }
                                .foregroundColor(tecla == "⌫" ? .white : .inkPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 58)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(tecla == "⌫" ? Color.semaforoVermelho : Color.appBackground)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(Color.black.opacity(0.12), lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .padding(18)
        .accessibleCard()
    }
    
    private func tocarTeclaCalculadora(_ tecla: String) {
        if tecla == "⌫" {
            if !valorString.isEmpty {
                valorString.removeLast()
            }
        } else {
            if valorString == "0" {
                valorString = tecla == "00" ? "0" : tecla
            } else if valorString.count < 6 {
                valorString.append(tecla)
            }
        }
    }
    
    // MARK: - Seletor Visual de Parcelamento
    private var seletorParcelamentoVisual: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Como o cliente vai pagar?")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.inkPrimary)
            
            HStack(spacing: 8) {
                ForEach([1, 2, 3], id: \.self) { qtd in
                    let ativo = quantidadeParcelas == qtd
                    Button {
                        quantidadeParcelas = qtd
                    } label: {
                        VStack(spacing: 4) {
                            Text(qtd == 1 ? "À Vista" : "\(qtd) Vezes")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            Text("\(qtd)x \(FormatadorMoeda.string(valorNumerico / Double(qtd)))")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .opacity(0.9)
                        }
                        .foregroundColor(ativo ? .white : .inkPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(ativo ? Color.semaforoAzul : Color.appBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(ativo ? Color.semaforoAzulEscuro : Color.black.opacity(0.12), lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(18)
        .accessibleCard()
    }
    
    // MARK: - PASSO 3: Pronto
    private var passo3ProntoParaEnviar: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("3. Tudo Pronto")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.inkPrimary)
            
            DocumentoVisualCardView(
                tipo: tipoDocumento,
                nomeProfissional: store.nomeProfissional,
                profissaoProfissional: store.profissaoProfissional,
                telefoneProfissional: store.telefoneProfissional,
                cliente: clienteEfetivo,
                servicoTitulo: tituloServicoEfetivo,
                servicoEmoji: "",
                observacao: descricaoDigitada,
                valor: valorNumerico,
                data: Date(),
                temFotoAnexa: temFotoLocalAnexada
            )
            
            if let urlPDF = urlPDFGerado {
                ShareLink(
                    item: urlPDF,
                    subject: Text("\(tipoDocumento.tituloPDF) - \(store.nomeProfissional)"),
                    message: Text("Olá \(clienteEfetivo.nome)! Segue o \(tipoDocumento == .orcamento ? "orçamento" : "recibo") de \(tituloServicoEfetivo) no valor de \(FormatadorMoeda.string(valorNumerico)).")
                ) {
                    conteudoBotaoWhatsAppGigante
                }
                .buttonStyle(
                    PhysicalButtonStyle(
                        baseColor: .semaforoVerde,
                        shadowColor: .semaforoVerdeEscuro,
                        cornerRadius: 20
                    )
                )
            }
            
            Button {
                mostrarConfirmacaoEnvioWhatsApp = true
            } label: {
                conteudoBotaoWhatsAppGigante
            }
            .buttonStyle(
                PhysicalButtonStyle(
                    baseColor: .semaforoVerde,
                    shadowColor: .semaforoVerdeEscuro,
                    cornerRadius: 20
                )
            )
        }
    }
    
    private var conteudoBotaoWhatsAppGigante: some View {
        HStack(spacing: 12) {
            Image(systemName: "paperplane")
                .font(.system(size: 24, weight: .semibold))
            VStack(alignment: .leading, spacing: 2) {
                Text("Mandar no WhatsApp Agora")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Text("Envia o PDF pronto para \(clienteEfetivo.nome)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .opacity(0.92)
            }
            Spacer()
        }
        .foregroundColor(.white)
        .padding(18)
    }
    
    // MARK: - Rodapé de Navegação
    private var rodapeBotoesNavegacao: some View {
        HStack(spacing: 12) {
            if passoAtual > 1 {
                Button {
                    withAnimation {
                        passoAtual -= 1
                    }
                } label: {
                    Text("Voltar")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundColor(.inkPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(
                    PhysicalButtonStyle(
                        baseColor: Color.white,
                        shadowColor: Color.black.opacity(0.15),
                        cornerRadius: 18
                    )
                )
            }
            
            if passoAtual < 3 {
                Button {
                    withAnimation {
                        passoAtual += 1
                        if passoAtual == 3 {
                            gerarPDFAtualizado()
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text("Continuar")
                            .font(.system(size: 19, weight: .bold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .buttonStyle(
                    PhysicalButtonStyle(
                        baseColor: .semaforoVerde,
                        shadowColor: .semaforoVerdeEscuro,
                        cornerRadius: 18
                    )
                )
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color.white)
    }
    
    private func gerarPDFAtualizado() {
        urlPDFGerado = PDFGenerator.gerarArquivoPDF(
            tipo: tipoDocumento,
            nomeProfissional: store.nomeProfissional,
            profissaoProfissional: store.profissaoProfissional,
            telefoneProfissional: store.telefoneProfissional,
            cliente: clienteEfetivo,
            servicoTitulo: tituloServicoEfetivo,
            servicoEmoji: "",
            observacao: descricaoDigitada,
            valor: valorNumerico,
            temFotoAnexa: temFotoLocalAnexada
        )
    }
    
    private func salvarNoAppStore() {
        if let existente = servicoPreSelecionado {
            store.marcarComoPago(existente)
            return
        }
        
        let statusInicial: StatusServico = (tipoDocumento == .recibo) ? .pago : .prontoCobrar
        let valorCada = valorNumerico / Double(max(quantidadeParcelas, 1))
        let listaParcelas: [ParcelaItem] = (1...quantidadeParcelas).map { num in
            let jaPaga = (tipoDocumento == .recibo) || (quantidadeParcelas > 1 && num == 1)
            let textoVenc = jaPaga ? "Pago" : (num == 1 ? "Vence HOJE" : "\(num)ª Parcela (Falta)")
            return ParcelaItem(
                numero: num,
                totalParcelas: quantidadeParcelas,
                valor: valorCada,
                vencimentoTexto: textoVenc,
                pago: jaPaga,
                atrasada: false
            )
        }
        
        let novoServico = ServicoItem(
            cliente: clienteEfetivo,
            tituloServico: tituloServicoEfetivo,
            iconeSistema: iconeServicoEfetivo,
            emoji: "",
            valor: valorNumerico,
            status: statusInicial,
            temFotoAnexa: temFotoLocalAnexada,
            observacaoFalada: descricaoDigitada,
            parcelas: listaParcelas
        )
        store.adicionarServico(novoServico)
    }
}
