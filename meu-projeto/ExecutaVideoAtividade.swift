import UIKit
import AVFoundation

public class ExecutaVideoAtividade: UIViewController {

    // MARK: - Properties
    public var currentSong: Song?
    public var downloadUrl: String?
    public var currentIndex: Int = 0
    public var playlist: [Song] = []
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerItemObserver: NSKeyValueObservation?
    
    // Camada de degradê colorido para o fundo infantil
    private let gradientLayer = CAGradientLayer()
    
    // Container onde o vídeo é desenhado (deve ser clear para não tapar o AVPlayerLayer)
    private let videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Botão de fechar customizado (✕)
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✕", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        button.backgroundColor = UIColor.systemRed.withAlphaComponent(0.9)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle
    override public func loadView() {
        super.loadView()
        let mainView = UIView(frame: UIScreen.main.bounds)
        
        // Configura o degradê colorido infantil (Azul -> Amarelo)
        gradientLayer.colors = [
            UIColor(red: 0.23, green: 0.73, blue: 0.95, alpha: 1.0).cgColor,
            UIColor(red: 1.00, green: 0.84, blue: 0.31, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = mainView.bounds
        mainView.layer.insertSublayer(gradientLayer, at: 0)
        
        self.view = mainView
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        iniciarVideo()
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
        
        if let layer = playerLayer {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layer.frame = videoContainerView.bounds
            CATransaction.commit()
        }
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(videoContainerView)
        view.addSubview(closeButton)

        closeButton.addTarget(self, action: #selector(fecharTela), for: .touchUpInside)

        NSLayoutConstraint.activate([
            // Container do vídeo centralizado
            videoContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            videoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            videoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            videoContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),

            // Botão fechar no canto superior direito
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // MARK: - Video Playback Logic
    private func iniciarVideo() {
        // 1. Reativa a sessão de áudio para mídia de vídeo
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Aviso: Falha ao reconfigurar AVAudioSession: \(error)")
        }

        // 2. Determina a música a ser tocada
        let songToPlay: Song?
        if let current = currentSong {
            songToPlay = current
        } else if !playlist.isEmpty && currentIndex < playlist.count {
            songToPlay = playlist[currentIndex]
        } else {
            songToPlay = nil
        }

        // 3. Resolve a URL do vídeo
        var targetURL: URL? = songToPlay?.getVideoURL()
        if targetURL == nil, let urlString = downloadUrl, !urlString.isEmpty {
            targetURL = urlString.hasPrefix("http") ? URL(string: urlString) : URL(fileURLWithPath: urlString)
        }

        guard let videoURL = targetURL else {
            print("❌ ERRO FATAL: Nenhuma URL de vídeo válida para \(songToPlay?.title ?? "Música Desconhecida").")
            return
        }

        print("🎬 Abrindo vídeo na URL: \(videoURL.absoluteString)")

        // 4. Limpa executores anteriores
        player?.pause()
        playerItemObserver?.invalidate()
        playerItemObserver = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        videoContainerView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        // 5. Instancia PlayerItem e AVPlayer
        let playerItem = AVPlayerItem(url: videoURL)
        let newPlayer = AVPlayer(playerItem: playerItem)
        self.player = newPlayer

        // 6. Configura a AVPlayerLayer
        let layer = AVPlayerLayer(player: newPlayer)
        layer.videoGravity = .resizeAspect
        
        view.layoutIfNeeded()
        layer.frame = videoContainerView.bounds
        videoContainerView.layer.addSublayer(layer)
        self.playerLayer = layer

        // 7. KVO para iniciar o Play somente quando a mídia estiver pronta
        playerItemObserver = playerItem.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if item.status == .readyToPlay {
                    print("✅ Mídia pronta para reprodução!")
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                    self.player?.play()
                } else if item.status == .failed {
                    print("❌ ERRO ao carregar arquivo de mídia: \(String(describing: item.error?.localizedDescription))")
                }
            }
        }

        // 8. Fim do vídeo -> Toca o próximo item da playlist
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }

    @objc private func videoDidFinishPlaying(notification: Notification) {
        if !playlist.isEmpty && currentIndex + 1 < playlist.count {
            currentIndex += 1
            currentSong = playlist[currentIndex]
            downloadUrl = currentSong?.downloadUrl
            iniciarVideo()
        } else {
            fecharTela()
        }
    }

    @objc private func fecharTela() {
        playerItemObserver?.invalidate()
        playerItemObserver = nil
        player?.pause()
        player = nil
        dismiss(animated: true, completion: nil)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerItemObserver?.invalidate()
        playerItemObserver = nil
        player?.pause()
        NotificationCenter.default.removeObserver(self)
    }
}
