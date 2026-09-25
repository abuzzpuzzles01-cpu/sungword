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
    
    // Container onde o vídeo é desenhado
    private let videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✕", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 26)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle
    override public func loadView() {
        super.loadView()
        let mainView = UIView(frame: UIScreen.main.bounds)
        mainView.backgroundColor = .black
        self.view = mainView
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Inicia o vídeo no viewDidAppear para garantir que a janela e as bounds da view estejam 100% prontas
        iniciarVideo()
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoContainerView.bounds
    }

    private func setupUI() {
        view.addSubview(videoContainerView)
        view.addSubview(closeButton)

        closeButton.addTarget(self, action: #selector(fecharTela), for: .touchUpInside)

        NSLayoutConstraint.activate([
            videoContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            videoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func iniciarVideo() {
        // 1. Reativa a sessão de áudio para mídia de vídeo
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Aviso: Falha ao reconfigurar AVAudioSession: \(error)")
        }

        // 2. Determina a Song atual
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
            if urlString.hasPrefix("http") {
                targetURL = URL(string: urlString)
            } else {
                targetURL = URL(fileURLWithPath: urlString)
            }
        }

        guard let videoURL = targetURL else {
            print("❌ ERRO FATAL: Nenhuma URL de vídeo válida encontrada para \(songToPlay?.title ?? "Música Desconhecida").")
            return
        }

        print("🎬 Iniciando reprodução do vídeo na URL: \(videoURL.absoluteString)")

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
        layer.frame = videoContainerView.bounds
        videoContainerView.layer.addSublayer(layer)
        self.playerLayer = layer

        // 7. KVO para acionar play quando estiver pronto
        playerItemObserver = playerItem.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch item.status {
                case .readyToPlay:
                    print("✅ Mídia pronta! Iniciando .play()")
                    self.player?.play()
                case .failed:
                    print("❌ ERRO ao carregar arquivo de mídia: \(String(describing: item.error?.localizedDescription))")
                case .unknown:
                    print("⏳ Carregando mídia...")
                @unknown default:
                    break
                }
            }
        }

        // 8. Fim do vídeo -> Próximo item
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
