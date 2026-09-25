import UIKit
import AVFoundation
import AVKit

public class ExecutaVideoAtividade: UIViewController {

    // MARK: - Properties (Injetadas pela HomeAtividade)
    public var currentSong: Song?
    public var downloadUrl: String?
    public var currentIndex: Int = 0
    public var playlist: [Song] = []
    
    // MARK: - Player Properties
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    // Container onde o vídeo é desenhado
    private let videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        iniciarVideo()
    }

    // Garante que o frame do playerLayer se ajuste ao tamanho real da tela (Evita Tela Preta)
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoContainerView.bounds
    }

    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(videoContainerView)

        NSLayoutConstraint.activate([
            videoContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            videoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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

        // 2. Obtém a URL do vídeo (Bundle se for grátis, Local/CDN se for pago)
        var targetURL: URL? = songToPlay?.getVideoURL()
        
        // Fallback para downloadUrl se o modelo não retornar
        if targetURL == nil, let urlString = downloadUrl, let url = URL(string: urlString) {
            targetURL = url
        }

        guard let videoURL = targetURL else {
            print("Erro: Nenhuma URL de vídeo encontrada.")
            return
        }

        // 3. Limpa o player anterior se existir
        player?.pause()
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)

        // 4. Configura o AVPlayer
        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)

        // 5. Configura a camada visual AVPlayerLayer
        if playerLayer == nil {
            let layer = AVPlayerLayer(player: player)
            layer.videoGravity = .resizeAspect
            videoContainerView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            videoContainerView.layer.addSublayer(layer)
            self.playerLayer = layer
        } else {
            playerLayer?.player = player
        }

        // 6. Registra notificação para tocar a próxima música ao fim do vídeo
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )

        // Force layout & Play
        view.setNeedsLayout()
        view.layoutIfNeeded()
        player?.play()
    }

    @objc private func videoDidFinishPlaying(notification: Notification) {
        // Toca automaticamente o próximo vídeo da playlist se houver
        if !playlist.isEmpty && currentIndex + 1 < playlist.count {
            currentIndex += 1
            currentSong = playlist[currentIndex]
            downloadUrl = currentSong?.downloadUrl
            iniciarVideo()
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        NotificationCenter.default.removeObserver(self)
    }
}
