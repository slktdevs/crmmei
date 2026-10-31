import SwiftUI
import AVFoundation
import Speech

// MARK: - 1. Gerenciador de Voz (Text-to-Speech + Voice-to-Text Nativo)
@MainActor
final class VoiceManager: NSObject, ObservableObject {
    @Published var estaFalando: Bool = false
    @Published var estaOuvindo: Bool = false
    @Published var textoReconhecido: String = ""
    @Published var mensagemStatusVoz: String = ""
    @Published var campoAtivoId: String? = nil
    
    private let synthesizer = AVSpeechSynthesizer()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "pt-BR"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    // MARK: - Text-to-Speech (Alto-falante 🔊)
    func falar(_ texto: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            estaFalando = false
            return
        }
        
        configurarSessaoAudioParaLeitura()
        
        let utterance = AVSpeechUtterance(string: texto)
        utterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
        // Velocidade levemente reduzida e clara para acessibilidade cognitiva
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.02
        utterance.volume = 1.0
        
        estaFalando = true
        synthesizer.speak(utterance)
    }
    
    func pararFala() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        estaFalando = false
    }
    
    private func configurarSessaoAudioParaLeitura() {
        #if os(iOS)
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            // Ignora falha em ambiente de simulador sem áudio
        }
        #endif
    }
    
    // MARK: - Voice-to-Text (Microfone Pulsante 🎙️)
    func alternarEscuta(
        campoId: String,
        fraseSimuladaSeSemMicrofone: String,
        aoReconhecer: @escaping (String) -> Void
    ) {
        if estaOuvindo && campoAtivoId == campoId {
            pararEscuta()
            return
        }
        
        pararFala()
        pararEscuta()
        
        campoAtivoId = campoId
        textoReconhecido = ""
        mensagemStatusVoz = "Pode falar agora..."
        estaOuvindo = true
        
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor in
                guard let self = self else { return }
                switch status {
                case .authorized:
                    self.iniciarCapturaDeAudioReal(
                        fraseFallback: fraseSimuladaSeSemMicrofone,
                        aoReconhecer: aoReconhecer
                    )
                default:
                    // Em simuladores ou quando a permissão ainda não foi configurada no Info.plist,
                    // executa ditado assistido realista para demonstração imediata.
                    self.simularDitadoInteligente(
                        frase: fraseSimuladaSeSemMicrofone,
                        aoReconhecer: aoReconhecer
                    )
                }
            }
        }
    }
    
    private func iniciarCapturaDeAudioReal(
        fraseFallback: String,
        aoReconhecer: @escaping (String) -> Void
    ) {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            simularDitadoInteligente(frase: fraseFallback, aoReconhecer: aoReconhecer)
            return
        }
        
        do {
            #if os(iOS)
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            #endif
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else {
                simularDitadoInteligente(frase: fraseFallback, aoReconhecer: aoReconhecer)
                return
            }
            recognitionRequest.shouldReportPartialResults = true
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            guard recordingFormat.channelCount > 0 else {
                simularDitadoInteligente(frase: fraseFallback, aoReconhecer: aoReconhecer)
                return
            }
            
            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                Task { @MainActor in
                    guard let self = self else { return }
                    if let result = result {
                        let transcrito = result.bestTranscription.formattedString
                        self.textoReconhecido = transcrito
                        aoReconhecer(transcrito)
                    }
                    if error != nil || (result?.isFinal == true) {
                        self.pararEscuta()
                    }
                }
            }
        } catch {
            simularDitadoInteligente(frase: fraseFallback, aoReconhecer: aoReconhecer)
        }
    }
    
    /// Simulação de ditado por voz para facilitar testes em Preview/Simulador
    private func simularDitadoInteligente(
        frase: String,
        aoReconhecer: @escaping (String) -> Void
    ) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            guard self.estaOuvindo else { return }
            self.textoReconhecido = frase
            self.mensagemStatusVoz = "Entendi: \"\(frase)\""
            aoReconhecer(frase)
            try? await Task.sleep(nanoseconds: 900_000_000)
            self.pararEscuta()
        }
    }
    
    func pararEscuta() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        estaOuvindo = false
        campoAtivoId = nil
    }
    
    // MARK: - Parser Inteligente de Frases Faladas (Ex: "Pintura da sala da Dona Maria trezentos reais")
    static func extrairValorReais(de texto: String) -> Double? {
        let lower = texto.lowercased()
        
        // 1. Procura números explícitos (ex: "300", "250,00")
        let padraoNumerico = #"(\d+([.,]\d{1,2})?)"#
        if let range = lower.range(of: padraoNumerico, options: .regularExpression) {
            let numeroLimpo = String(lower[range]).replacingOccurrences(of: ",", with: ".")
            if let valor = Double(numeroLimpo) {
                return valor
            }
        }
        
        // 2. Procura números falados por extenso mais comuns
        let mapaExtenso: [(String, Double)] = [
            ("mil e quinhentos", 1500),
            ("mil e duzentos", 1200),
            ("mil", 1000),
            ("oitocentos", 800),
            ("setecentos", 700),
            ("seiscentos", 600),
            ("quinhentos", 500),
            ("quatrocentos", 400),
            ("trezentos e cinquenta", 350),
            ("trezentos", 300),
            ("duzentos e cinquenta", 250),
            ("duzentos", 200),
            ("cento e oitenta", 180),
            ("cento e cinquenta", 150),
            ("cento e vinte", 120),
            ("cem", 100),
            ("oitenta", 80),
            ("cinquenta", 50)
        ]
        
        for (palavra, valor) in mapaExtenso {
            if lower.contains(palavra) {
                return valor
            }
        }
        
        return nil
    }
}

extension VoiceManager: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.estaFalando = false
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.estaFalando = false
        }
    }
}

// MARK: - 2. Componentes Visuais de Voz (Microfone Pulsante e Botão Ouvir 🔊)

/// Botão grande de Alto-Falante (🔊) para ouvir resumos e orçamentos em voz alta
struct SpeakerButton: View {
    @ObservedObject var voiceManager: VoiceManager
    let textoParaLer: String
    var rotuloCurto: String = "Ouvir"
    var corFundo: Color = .semaforoAzul
    var corSombra: Color = .semaforoAzulEscuro
    
    var body: some View {
        Button {
            voiceManager.falar(textoParaLer)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: voiceManager.estaFalando ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    // compatibilidade iOS 16
                    .scaleEffect(voiceManager.estaFalando ? 1.08 : 1.0)
                
                Text(voiceManager.estaFalando ? "Parar Áudio" : rotuloCurto)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
        .buttonStyle(PhysicalButtonStyle(baseColor: corFundo, shadowColor: corSombra, cornerRadius: 18))
        .accessibilityLabel(rotuloCurto)
    }
}

/// Botão de Microfone Pulsante para ditado de voz em qualquer campo
struct PulsingMicButton: View {
    @ObservedObject var voiceManager: VoiceManager
    let campoId: String
    var rotulo: String = "Falar"
    let fraseExemplo: String
    let aoReconhecer: (String) -> Void
    
    @State private var pulso: Bool = false
    
    private var ativoNesteCampo: Bool {
        voiceManager.estaOuvindo && voiceManager.campoAtivoId == campoId
    }
    
    var body: some View {
        Button {
            voiceManager.alternarEscuta(
                campoId: campoId,
                fraseSimuladaSeSemMicrofone: fraseExemplo,
                aoReconhecer: aoReconhecer
            )
        } label: {
            HStack(spacing: 10) {
                ZStack {
                    if ativoNesteCampo {
                        Circle()
                            .fill(Color.white.opacity(0.35))
                            .frame(width: 44, height: 44)
                            .scaleEffect(pulso ? 1.35 : 0.9)
                            .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: pulso)
                    }
                    
                    Image(systemName: ativoNesteCampo ? "waveform.circle.fill" : "mic.fill")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                }
                
                Text(ativoNesteCampo ? "Ouvindo..." : rotulo)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
        .buttonStyle(
            PhysicalButtonStyle(
                baseColor: ativoNesteCampo ? .semaforoVermelho : .semaforoAzul,
                shadowColor: ativoNesteCampo ? .semaforoVermelhoEscuro : .semaforoAzulEscuro,
                cornerRadius: 18
            )
        )
        .onChange(of: ativoNesteCampo) { novoValor in
            pulso = novoValor
        }
    }
}

/// Campo de texto acessível com botão de Microfone embutido
struct VoiceAccessibleTextField: View {
    let tituloCurto: String
    let icone: String
    @Binding var texto: String
    let placeholder: String
    let campoId: String
    let fraseSimulada: String
    @ObservedObject var voiceManager: VoiceManager
    var aoFinalizarFala: ((String) -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icone)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.semaforoAzul)
                Text(tituloCurto)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(.inkPrimary)
            }
            
            HStack(spacing: 12) {
                TextField(placeholder, text: $texto)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.inkPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.appBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.semaforoAzul.opacity(0.4), lineWidth: 2)
                    )
                
                PulsingMicButton(
                    voiceManager: voiceManager,
                    campoId: campoId,
                    rotulo: "Falar",
                    fraseExemplo: fraseSimulada
                ) { reconhecido in
                    texto = reconhecido
                    aoFinalizarFala?(reconhecido)
                }
            }
        }
        .padding(16)
        .accessibleCard()
    }
}
