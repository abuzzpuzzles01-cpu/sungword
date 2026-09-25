import UIKit
import AVFoundation
import AVKit

public class ExecutaVideoAtividade: UIViewController {

    public var currentSong: Song?
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    // Container onde o vídeo será desenhado
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

    // IMPORTANTE: O frame do playerLayer DEVE ser atualizado aqui
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Garante que a camada do vídeo ocupe 100% da containerView
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
        guard let song = currentSong, let videoURL = song.getVideoURL() else {
            print("Erro: URL do vídeo não encontrada.")
            return
        }

        // 1. Criar o Player
        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)

        // 2. Criar e configurar a AVPlayerLayer
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspect
        
        // Remove camadas antigas antes de adicionar
        videoContainerView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        videoContainerView.layer.addSublayer(layer)
        
        self.playerLayer = layer

        // 3. Forçar o layout inicial do frame
        view.setNeedsLayout()
        view.layoutIfNeeded()

        // 4. Iniciar a reprodução
        player?.play()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }
}
