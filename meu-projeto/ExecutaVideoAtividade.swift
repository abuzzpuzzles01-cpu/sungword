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
    
    // Camada de degradê colorido para o fundo
    private let gradientLayer = CAGradientLayer()
    
    // Container transparente onde o AVPlayerLayer é encaixado
    private let videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Botão de fechar (✕)
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
        
        // Fundo infantil em degradê azul/amarelo
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
            layer.frame = videoContainerView.bounds
        }
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(videoContainerView)
        view.addSubview(closeButton)

        closeButton.addTarget(self, action: #selector(fecharTela), for: .touchUpInside)

        NSLayoutConstraint.activate([
            videoContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            videoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            videoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            videoContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // MARK: - Video Execution
    private func iniciarVideo() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Aviso: Falha na AVAudioSession: \(error)")
        }

        let songToPlay = currentSong ?? (!playlist.isEmpty && currentIndex < playlist.count ? playlist[currentIndex] : nil)

        guard let song = songToPlay else {
            print("❌ ERRO: Nenhuma música informada.")
            return
        }

        guard let videoURL = song.getVideoURL() else {
            print("❌ ERRO: Não foi possível obter a URL do vídeo para \(song.title).")
            return
        }

        print("🎬 Iniciando vídeo: \(videoURL.lastPathComponent)")

        // Limpeza de player antigo
        player?.pause()
        playerItemObserver?.invalidate()
        playerItemObserver = nil
        videoContainerView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let playerItem = AVPlayerItem(url: videoURL)
        let newPlayer = AVPlayer(playerItem: playerItem)
        self.player = newPlayer

        let layer = AVPlayerLayer(player: newPlayer)
        layer.videoGravity = .resizeAspect
        
        view.layoutIfNeeded()
        layer.frame = videoContainerView.bounds
        videoContainerView.layer.addSublayer(layer)
        self.playerLayer = layer

        // Observa o status para dar o play quando a mídia estiver pronta
        playerItemObserver = playerItem.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if item.status == .readyToPlay {
                    print("✅ Reproduzindo vídeo: \(videoURL.lastPathComponent)")
                    self.player?.play()
                } else if item.status == .failed {
                    print("❌ ERRO ao carregar playerItem: \(String(describing: item.error))")
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
