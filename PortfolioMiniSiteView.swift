import SwiftUI

struct ObraPortfolioItem: Identifiable, Hashable {
    let id = UUID()
    var titulo: String
    var bairro: String
    var tempoExecucao: String
    var precoBase: String
    var icone: String
}

struct PortfolioMiniSiteView: View {
    @ObservedObject var store: AppStore
    
    @State private var abaMiniSite: Int = 0 // 0 = Dados, 1 = Portfólio, 2 = Preços
    @State private var slugUrl: String = "joao-reparos"
    @State private var slogan: String = "Serviço limpo, rápido e com garantia de 90 dias."
    @State private var cidadeBairros: String = "Atendo Zona Sul, Centro e Região"
    @State private var anosExperiencia: String = "12 anos de experiência"
    
    @State private var mostrarPreviewPublico: Bool = false
    @State private var mostrarFormNovaObra: Bool = false
    @State private var novaObraTitulo: String = ""
    @State private var novaObraBairro: String = ""
    @State private var novaObraPreco: String = ""
    
    @State private var obras: [ObraPortfolioItem] = [
        ObraPortfolioItem(
            titulo: "Pintura Completa de Sala e Iluminação LED",
            bairro: "Condomínio Flores",
            tempoExecucao: "Feito em 2 dias",
            precoBase: "A partir de R$ 450",
            icone: "paintbrush.pointed"
        ),
        ObraPortfolioItem(
            titulo: "Quadro Elétrico Novo + Disjuntores Padrão",
            bairro: "Centro",
            tempoExecucao: "Feito no mesmo dia",
            precoBase: "A partir de R$ 350",
            icone: "bolt"
        ),
        ObraPortfolioItem(
            titulo: "Reforma de Telhado e Impermeabilização de Calha",
            bairro: "Vila Nova",
            tempoExecucao: "Garantia de 1 ano",
            precoBase: "A partir de R$ 380",
            icone: "house"
        )
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                cabecalhoMiniSite
                cartaoCompartilharLink
                seletorSubAbas
                
                if abaMiniSite == 0 {
                    formularioDadosEmpresa
                } else if abaMiniSite == 1 {
                    galeriaPortfolioObras
                } else {
                    tabelaPrecosPublicos
                }
            }
            .padding(18)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .sheet(isPresented: $mostrarPreviewPublico) {
            PublicMiniSitePreviewSheet(
                store: store,
                slugUrl: slugUrl,
                slogan: slogan,
                anosExperiencia: anosExperiencia,
                obras: obras
            )
        }
    }
    
    // MARK: - 1. Cabeçalho
    private var cabecalhoMiniSite: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Meu Mini Site")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.inkPrimary)
                Text("Seu portfólio profissional para compartilhar")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.inkSecondary)
            }
            Spacer()
            Button {
                mostrarPreviewPublico = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "safari")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Abrir Site")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            }
            .buttonStyle(
                PhysicalButtonStyle(
                    baseColor: .inkPrimary,
                    shadowColor: .black,
                    cornerRadius: 14
                )
            )
        }
    }
    
    // MARK: - 2. Cartão de Link Compartilhável
    private var cartaoCompartilharLink: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("LINK PRONTO PARA COMPARTILHAR")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.white.opacity(0.2)))
                Spacer()
                Image(systemName: "globe")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text("parceiro.app/\(slugUrl)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Envie no WhatsApp ou coloque na bio do Instagram para seus clientes verem suas fotos e pedirem orçamento online.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
            
            HStack(spacing: 10) {
                ShareLink(item: URL(string: "https://parceiro.app/\(slugUrl)")!) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .bold))
                        Text("Compartilhar Link")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.inkPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                }
                
                Button {
                    mostrarPreviewPublico = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "eye")
                            .font(.system(size: 16, weight: .bold))
                        Text("Ver Como Cliente")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.semaforoVerde))
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.semaforoAzul, .inkPrimary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
    
    // MARK: - 3. Sub-abas
    private var seletorSubAbas: some View {
        HStack(spacing: 8) {
            botaoSubAba(indice: 0, icone: "slider.horizontal.3", titulo: "Dados")
            botaoSubAba(indice: 1, icone: "photo.on.rectangle", titulo: "Portfólio (\(obras.count))")
            botaoSubAba(indice: 2, icone: "list.bullet.rectangle", titulo: "Preços")
        }
    }
    
    private func botaoSubAba(indice: Int, icone: String, titulo: String) -> some View {
        let ativo = abaMiniSite == indice
        return Button {
            withAnimation {
                abaMiniSite = indice
            }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: icone)
                    .font(.system(size: 18, weight: .semibold))
                Text(titulo)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
            }
            .foregroundColor(ativo ? .white : .inkPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(ativo ? Color.semaforoAzul : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.1), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Aba 0: Formulário de Dados da Empresa
    private var formularioDadosEmpresa: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Dados da Sua Empresa no Site")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.inkPrimary)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Nome Comercial")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.inkSecondary)
                TextField("Nome da Empresa", text: $store.nomeProfissional)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.appBackground))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Frase de Destaque / Garantia")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.inkSecondary)
                TextField("Slogan", text: $slogan)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.appBackground))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Link Personalizado")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.inkSecondary)
                HStack(spacing: 4) {
                    Text("parceiro.app/")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.inkSecondary)
                    TextField("seu-nome", text: $slugUrl)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.semaforoAzul)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.appBackground))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Bairros onde você atende")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.inkSecondary)
                TextField("Região", text: $cidadeBairros)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.appBackground))
            }
        }
        .padding(18)
        .accessibleCard()
    }
    
    // MARK: - Aba 1: Galeria de Portfólio
    private var galeriaPortfolioObras: some View {
        VStack(spacing: 14) {
            Button {
                withAnimation {
                    mostrarFormNovaObra.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 20, weight: .semibold))
                    Text("Adicionar Obra ao Portfólio")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(
                PhysicalButtonStyle(
                    baseColor: .semaforoAzul,
                    shadowColor: .semaforoAzulEscuro,
                    cornerRadius: 16
                )
            )
            
            if mostrarFormNovaObra {
                VStack(spacing: 12) {
                    TextField("Título do serviço realizado", text: $novaObraTitulo)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.appBackground))
                    
                    TextField("Bairro / Condomínio", text: $novaObraBairro)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.appBackground))
                    
                    TextField("Preço médio (Ex: A partir de R$ 300)", text: $novaObraPreco)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.appBackground))
                    
                    Button {
                        guard !novaObraTitulo.isEmpty else { return }
                        obras.insert(
                            ObraPortfolioItem(
                                titulo: novaObraTitulo,
                                bairro: novaObraBairro.isEmpty ? "Cliente Verificado" : novaObraBairro,
                                tempoExecucao: "Garantia inclusa",
                                precoBase: novaObraPreco.isEmpty ? "Sob consulta" : novaObraPreco,
                                icone: "checkmark.seal"
                            ),
                            at: 0
                        )
                        novaObraTitulo = ""
                        novaObraBairro = ""
                        novaObraPreco = ""
                        mostrarFormNovaObra = false
                    } label: {
                        Text("Publicar no Meu Site")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(
                        PhysicalButtonStyle(
                            baseColor: .semaforoVerde,
                            shadowColor: .semaforoVerdeEscuro,
                            cornerRadius: 14
                        )
                    )
                }
                .padding(16)
                .accessibleCard()
            }
            
            ForEach(obras) { obra in
                VStack(alignment: .leading, spacing: 10) {
                    ZStack(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.semaforoAzul, .inkPrimary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 110)
                        
                        Image(systemName: obra.icone)
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        Text(obra.tempoExecucao)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.black.opacity(0.45)))
                            .padding(10)
                    }
                    
                    Text(obra.titulo)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.inkPrimary)
                    
                    HStack {
                        Text(obra.bairro)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.inkSecondary)
                        Spacer()
                        Text(obra.precoBase)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.semaforoVerdeEscuro)
                    }
                }
                .padding(14)
                .accessibleCard()
            }
        }
    }
    
    // MARK: - Aba 2: Preços Base no Site
    private var tabelaPrecosPublicos: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tabela de Serviços no Site")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.inkPrimary)
            
            ForEach(store.catalogoServicos) { item in
                HStack(spacing: 12) {
                    Image(systemName: item.iconeSistema)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.semaforoAzul)
                        .frame(width: 36, height: 36)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.semaforoAzulFundo))
                    
                    Text(item.nomeCurto)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.inkPrimary)
                    
                    Spacer()
                    
                    Text("A partir de \(FormatadorMoeda.string(item.valorSugerido))")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.semaforoVerdeEscuro)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.appBackground))
            }
        }
        .padding(18)
        .accessibleCard()
    }
}

// MARK: - Visualização Pública do Mini Site (Como o Cliente Vê)
struct PublicMiniSitePreviewSheet: View {
    @ObservedObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    
    let slugUrl: String
    let slogan: String
    let anosExperiencia: String
    let obras: [ObraPortfolioItem]
    
    @State private var nomeClienteSite: String = ""
    @State private var telefoneClienteSite: String = ""
    @State private var pedidoDescricaoSite: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    // Capa do Profissional
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 60, height: 60)
                                Image(systemName: "wrench.and.screwdriver")
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("PROFISSIONAL VERIFICADO")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(.semaforoVerdeFundo)
                                Text(store.nomeProfissional)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text(slogan)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [.semaforoAzul, .inkPrimary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    
                    // Formulário Público de Orçamento Online
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pedir Orçamento Online")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.inkPrimary)
                        
                        TextField("Seu Nome", text: $nomeClienteSite)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.appBackground))
                        
                        TextField("Seu WhatsApp", text: $telefoneClienteSite)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.appBackground))
                        
                        TextField("Qual serviço você precisa?", text: $pedidoDescricaoSite)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.appBackground))
                        
                        Button {
                            let novoCli = Cliente(
                                nome: nomeClienteSite.isEmpty ? "Cliente do Site" : nomeClienteSite,
                                apelidoOuBairro: "Veio pelo Mini Site",
                                telefone: telefoneClienteSite.isEmpty ? "(11) 99000-0000" : telefoneClienteSite,
                                emojiAvatar: ""
                            )
                            store.adicionarCliente(novoCli)
                            store.adicionarServico(
                                ServicoItem(
                                    cliente: novoCli,
                                    tituloServico: pedidoDescricaoSite.isEmpty ? "Orçamento pelo Site" : pedidoDescricaoSite,
                                    iconeSistema: "wrench.and.screwdriver",
                                    emoji: "",
                                    valor: 300,
                                    status: .combinando
                                )
                            )
                            dismiss()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "paperplane")
                                Text("Enviar Pedido de Orçamento")
                            }
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(
                            PhysicalButtonStyle(
                                baseColor: .semaforoVerde,
                                shadowColor: .semaforoVerdeEscuro,
                                cornerRadius: 16
                            )
                        )
                    }
                    .padding(18)
                    .accessibleCard()
                    .padding(.horizontal, 18)
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Voltar ao App") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("parceiro.app/\(slugUrl)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.inkSecondary)
                }
            }
        }
    }
}
