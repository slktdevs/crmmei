import SwiftUI
import PDFKit

// MARK: - 1. Cartão Visual Minimalista do Documento (Usado na Tela e Renderizado para PDF)
struct DocumentoVisualCardView: View {
    let tipo: TipoDocumento
    let nomeProfissional: String
    let profissaoProfissional: String
    let telefoneProfissional: String
    let cliente: Cliente
    let servicoTitulo: String
    let servicoEmoji: String
    let observacao: String
    let valor: Double
    let data: Date
    let temFotoAnexa: Bool
    
    private var dataFormatada: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateStyle = .short
        return formatter.string(from: data)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Cabeçalho com Ícone Vetorial do Trabalhador e Tipo de Documento
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.22))
                        .frame(width: 52, height: 52)
                    Image(systemName: "wrench.and.screwdriver")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(tipo.tituloPDF)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))
                    Text(nomeProfissional)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("\(profissaoProfissional) • \(telefoneProfissional)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
            }
            .padding(18)
            .background(tipo.corTema)
            
            VStack(alignment: .leading, spacing: 16) {
                // Quem é o Cliente
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.semaforoAzulFundo)
                            .frame(width: 52, height: 52)
                        Text(cliente.iniciais)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.semaforoAzul)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("CLIENTE")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.inkSecondary)
                        Text(cliente.nome)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.inkPrimary)
                        Text(cliente.apelidoOuBairro)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.inkSecondary)
                    }
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("DATA")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.inkSecondary)
                        Text(dataFormatada)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.inkPrimary)
                    }
                }
                
                Divider()
                    .frame(height: 1.5)
                    .background(Color.black.opacity(0.08))
                
                // O que vai ser feito / foi feito
                VStack(alignment: .leading, spacing: 6) {
                    Text("SERVIÇO COMBINADO")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.inkSecondary)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "hammer")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.semaforoAzul)
                        Text(servicoTitulo)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.inkPrimary)
                    }
                    
                    if !observacao.isEmpty {
                        Text(observacao)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.inkSecondary)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.appBackground)
                            )
                    }
                }
                
                if temFotoAnexa {
                    HStack(spacing: 10) {
                        Image(systemName: "photo")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.semaforoAzul)
                        Text("Foto do local anexada no documento")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.semaforoAzul)
                        Spacer()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.semaforoAzulFundo)
                    )
                }
                
                // Caixa de Valor Total em Destaque
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(tipo == .orcamento ? "VALOR TOTAL" : "VALOR RECEBIDO")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.inkSecondary)
                        Text(tipo == .orcamento ? "Validade: 15 dias" : "Pagamento Confirmado")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.semaforoVerdeEscuro)
                    }
                    Spacer()
                    Text(FormatadorMoeda.string(valor))
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundColor(.semaforoVerdeEscuro)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.semaforoVerdeFundo)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.semaforoVerde, lineWidth: 2)
                )
            }
            .padding(18)
            .background(Color.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.black.opacity(0.14), lineWidth: 2)
        )
    }
}

// MARK: - 2. Gerador Nativo de Arquivo PDF (ImageRenderer + PDFKit)
enum PDFGenerator {
    @MainActor
    static func gerarArquivoPDF(
        tipo: TipoDocumento,
        nomeProfissional: String,
        profissaoProfissional: String,
        telefoneProfissional: String,
        cliente: Cliente,
        servicoTitulo: String,
        servicoEmoji: String,
        observacao: String,
        valor: Double,
        data: Date = Date(),
        temFotoAnexa: Bool
    ) -> URL? {
        let cardView = DocumentoVisualCardView(
            tipo: tipo,
            nomeProfissional: nomeProfissional,
            profissaoProfissional: profissaoProfissional,
            telefoneProfissional: telefoneProfissional,
            cliente: cliente,
            servicoTitulo: servicoTitulo,
            servicoEmoji: servicoEmoji,
            observacao: observacao,
            valor: valor,
            data: data,
            temFotoAnexa: temFotoAnexa
        )
        .frame(width: 540)
        .padding(24)
        .background(Color.white)
        
        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 2.0
        
        let nomeSeguro = cliente.nome.replacingOccurrences(of: " ", with: "_")
        let prefixo = tipo == .orcamento ? "Orcamento" : "Recibo"
        let urlArquivo = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(prefixo)_\(nomeSeguro).pdf")
        
        var mediaBox = CGRect(x: 0, y: 0, width: 588, height: 760)
        guard let consumer = CGDataConsumer(url: urlArquivo as CFURL),
              let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            return nil
        }
        
        renderer.render { size, renderInContext in
            var pageBox = CGRect(origin: .zero, size: CGSize(width: max(size.width, 588), height: max(size.height, 680)))
            pdfContext.beginPage(mediaBox: &pageBox)
            renderInContext(pdfContext)
            pdfContext.endPage()
            pdfContext.closePDF()
        }
        
        return urlArquivo
    }
}
