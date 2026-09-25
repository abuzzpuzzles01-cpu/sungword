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
        iniciarVideo()
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Mantém o tamanho da camada alinhado ao container
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
        // 1. Determina qual Song será tocada
        let songToPlay: Song?
        if let current = currentSong {
            songToPlay = current
        } else if !playlist.isEmpty && currentIndex < playlist.count {
            songToPlay = playlist[currentIndex]
        } else {
            songToPlay = nil
        }

        // 2. Obtém a URL do vídeo
        var targetURL: URL? = songToPlay?.getVideoURL()
        
        if targetURL == nil, let urlString = downloadUrl, let url = URL(string: urlString) {
            targetURL = url
        }

        guard let videoURL = targetURL else {
            print("Erro: Nenhuma URL de vídeo válida encontrada.")
            return
        }

        // 3. Limpa o player antigo e observadores
        player?.pause()
        playerItemObserver?.invalidate()
        playerItemObserver = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        // Remove sublayers antigas do container
        videoContainerView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        // 4. Instancia o Item e o Player
        let playerItem = AVPlayerItem(url: videoURL)
        let newPlayer = AVPlayer(playerItem: playerItem)
        self.player = newPlayer

        // 5. Configura a AVPlayerLayer
        let layer = AVPlayerLayer(player: newPlayer)
        layer.videoGravity = .resizeAspect
        layer.frame = videoContainerView.bounds
        videoContainerView.layer.addSublayer(layer)
        self.playerLayer = layer

        // 6. Observa o status do playerItem para dar play automático assim que estiver pronto
        playerItemObserver = playerItem.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if item.status == .readyToPlay {
                    self.player?.play()
                } else if item.status == .failed {
                    print("Erro no carregamento da mídia: \(String(describing: item.error))")
                }
            }
        }

        // 7. Notificação de fim de vídeo para tocar o próximo da playlist
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
