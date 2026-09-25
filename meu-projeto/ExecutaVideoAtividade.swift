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
    
    // Camada de degradê colorido para o fundo da tela
    private let gradientLayer = CAGradientLayer()
    
    // Container onde o vídeo é desenhado
    private let videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Botão de fechar customizado e colorido
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
        
        // Define as cores do degradê infantil (Azul Claro para Amarelo Suave)
        gradientLayer.colors = [
            UIColor(red: 0.23, green: 0.73, blue: 0.95, alpha: 1.0).cgColor, // Azul Três Palavrinhas
            UIColor(red: 1.00, green: 0.84, blue: 0.31, alpha: 1.0).cgColor  // Amarelo
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
        // Atualiza as dimensões do degradê e do vídeo quando a tela muda de tamanho
        gradientLayer.frame = view.bounds
        playerLayer?.frame = videoContainerView.bounds
    }

    private func setupUI() {
        view.addSubview(videoContainerView)
        view.addSubview(closeButton)

        closeButton.addTarget(self, action: #selector(fecharTela), for: .touchUpInside)

        NSLayoutConstraint.activate([
            // Container do vídeo centralizado e com margens laterais
            videoContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            videoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            videoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            videoContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            // Botão Fechar no canto superior direito
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func iniciarVideo() {
        // Reativa a sessão de áudio para mídia de vídeo
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Aviso: Falha ao reconfigurar AVAudioSession: \(error)")
        }

        let songToPlay: Song?
        if let current = currentSong {
            songToPlay = current
        } else if !playlist.isEmpty && currentIndex < playlist.count {
            songToPlay = playlist[currentIndex]
        } else {
            songToPlay = nil
        }

        var targetURL: URL? = songToPlay?.getVideoURL()
        
        if targetURL == nil, let urlString = downloadUrl, !urlString.isEmpty {
            if urlString.hasPrefix("http") {
                targetURL = URL(string: urlString)
            } else {
                targetURL = URL(fileURLWithPath: urlString)
            }
        }

        guard let videoURL = targetURL else {
            print("❌ ERRO FATAL: Nenhuma URL de vídeo válida encontrada.")
            return
        }

        player?.pause()
        playerItemObserver?.invalidate()
        playerItemObserver = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        videoContainerView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let playerItem = AVPlayerItem(url: videoURL)
        let newPlayer = AVPlayer(playerItem: playerItem)
        self.player = newPlayer

        let layer = AVPlayerLayer(player: newPlayer)
        layer.videoGravity = .resizeAspect
        layer.frame = videoContainerView.bounds
        videoContainerView.layer.addSublayer(layer)
        self.playerLayer = layer

        playerItemObserver = playerItem.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if item.status == .readyToPlay {
                    self.player?.play()
                }
            }
        }

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
