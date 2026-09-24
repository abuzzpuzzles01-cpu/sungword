// ExecutaVideoAtividade.swift
import UIKit
import AVKit

class ExecutaVideoAtividade: UIViewController {

    // MARK: - Properties (Recebidas de HomeAtividade)
    var downloadUrl: String?
    var currentIndex: Int = 0
    var playlist: [Song] = []

    // MARK: - Components
    private var playerViewController: AVPlayerViewController?
    private var player: AVPlayer?

    private lazy var btVoltar: UIButton = {
        let button = UIButton(type: .custom)
        if let image = UIImage(named: "bt_voltar") {
            button.setImage(image, for: .normal)
        } else {
            button.setTitle("✕", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        }
        button.addTarget(self, action: #selector(btVoltarTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupPlayer()
        setupUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        NotificationCenter.default.removeObserver(self)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Setup
    private func setupPlayer() {
        guard let urlString = downloadUrl, let videoURL = URL(string: urlString) else {
            print("Erro: URL do vídeo inválida ou não informada.")
            return
        }

        player = AVPlayer(url: videoURL)
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        playerVC.showsPlaybackControls = true

        // Adiciona o playerViewController como filho desta ViewController
        addChild(playerVC)
        playerVC.view.frame = view.bounds
        playerVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(playerVC.view)
        playerVC.didMove(toParent: self)

        self.playerViewController = playerVC

        // Notificação para fechar/avançar quando o vídeo terminar
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )

        player?.play()
    }

    private func setupUI() {
        // Traz o botão de fechar/voltar para a frente do Player
        view.addSubview(btVoltar)
        view.bringSubviewToFront(btVoltar)

        NSLayoutConstraint.activate([
            btVoltar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            btVoltar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            btVoltar.widthAnchor.constraint(equalToConstant: 44),
            btVoltar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Actions
    @objc private func btVoltarTapped() {
        // Pausa a execução do áudio/vídeo imediatamente
        player?.pause()
        
        // Retorna explicitamente para a HomeAtividade
        if let nav = navigationController {
            if let homeVC = nav.viewControllers.first(where: { $0 is HomeAtividade }) {
                nav.popToViewController(homeVC, animated: true)
            } else if nav.viewControllers.count > 1 {
                nav.popViewController(animated: true)
            } else {
                let homeVC = HomeAtividade()
                nav.setViewControllers([homeVC], animated: true)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    @objc private func videoDidFinishPlaying() {
        // Toca o próximo vídeo se houver playlist
        if currentIndex + 1 < playlist.count {
            currentIndex += 1
            let nextSong = playlist[currentIndex]
            if let nextUrl = nextSong.downloadUrl, let url = URL(string: nextUrl) {
                let playerItem = AVPlayerItem(url: url)
                player?.replaceCurrentItem(with: playerItem)
                player?.play()
                return
            }
        }
        
        // Se for o último vídeo da playlist, volta para a HomeAtividade
        btVoltarTapped()
    }
}
