import UIKit
import AVFoundation
import AVKit

public class ExecutaVideoAtividade: UIViewController {

    // MARK: - Properties
    public var currentSong: Song?
    public var downloadUrl: String?
    public var currentIndex: Int = 0
    public var playlist: [Song] = []
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
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
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle
    override public func loadView() {
        super.loadView()
        // Garante que a view base seja opaca e ocupe a tela inteira
        let mainView = UIView(frame: UIScreen.main.bounds)
        mainView.backgroundColor = .black
        self.view = mainView
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        iniciarVideo()
    }

    // CRÍTICO PARA EVITAR TELA PRETA:
    // Garante que a camada do vídeo acompanhe o tamanho real da tela após o layout
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
        
        // Fallback caso venha pela propriedade downloadUrl
        if targetURL == nil, let urlString = downloadUrl, let url = URL(string: urlString) {
            targetURL = url
        }

        guard let videoURL = targetURL else {
            print("Erro: Nenhuma URL de vídeo válida encontrada.")
            return
        }

        // 3. Limpa o player antigo se houver
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)

        // 4. Cria o item e o AVPlayer
        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)

        // 5. Instancia a AVPlayerLayer com dimensionamento correto
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspect
        layer.frame = videoContainerView.bounds
        
        videoContainerView.layer.addSublayer(layer)
        self.playerLayer = layer

        // 6. Observador para tocar o próximo vídeo ao terminar
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )

        // Força atualização imediata de layout
        view.setNeedsLayout()
        view.layoutIfNeeded()

        player?.play()
    }

    @objc private func videoDidFinishPlaying(notification: Notification) {
        if !playlist.isEmpty && currentIndex + 1 < playlist.count {
            currentIndex += 1
            currentSong = playlist[currentIndex]
            downloadUrl = currentSong?.downloadUrl
            iniciarVideo()
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    @objc private func fecharTela() {
        player?.pause()
        dismiss(animated: true, completion: nil)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        NotificationCenter.default.removeObserver(self)
    }
}
