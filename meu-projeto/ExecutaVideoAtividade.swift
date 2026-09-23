import UIKit
import AVKit

// Model para representar a estrutura de dados de Song/Música
struct Song {
    var fileName: String
    var urlDownload: String?
}

class ExecutaVideoAtividade: UIViewController {

    // MARK: - Properties & Data
    var currentContentIndex: Int = 0
    var playList: [Song] = []
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserverToken: Any?

    private var isBabyModeEnabled: Bool = false
    private var isPlayAllEnabled: Bool = false
    private var isMuted: Bool = false
    private var isErrorState: Bool = false

    private var checkModoBB: Bool = true
    private var unlockTimer: Timer?
    private var secController: Int = 3

    // MARK: - UI Components
    private let videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let playerLayer = AVPlayerLayer()

    private let controlLayout: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let btVoltar: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "bt_voltar"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let btSom: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "bt_som"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let playAllVideosButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "bt_tocartudo_off"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let babyModeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "modo_bebe"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let backwardButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "backward_button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let playPauseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "play_button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let forwardButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "forward_button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let seekBar: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    // Componentes para a Contagem Regressiva do Modo Bebê
    private let viewTimer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.layer.cornerRadius = 12
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let numTimerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 36)
        label.textAlignment = .center
        label.text = "3"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        loadPreferences()
        initAnalytics()

        if !playList.isEmpty && currentContentIndex < playList.count {
            playVideo()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoContainerView.bounds
    }

    deinit {
        removePeriodicTimeObserver()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup UI & Layout
    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(videoContainerView)
        videoContainerView.layer.addSublayer(playerLayer)

        view.addSubview(controlLayout)
        controlLayout.addSubview(btVoltar)
        controlLayout.addSubview(btSom)
        controlLayout.addSubview(playAllVideosButton)
        controlLayout.addSubview(babyModeButton)
        controlLayout.addSubview(backwardButton)
        controlLayout.addSubview(playPauseButton)
        controlLayout.addSubview(forwardButton)
        controlLayout.addSubview(seekBar)

        view.addSubview(viewTimer)
        viewTimer.addSubview(numTimerLabel)

        NSLayoutConstraint.activate([
            // Video Container
            videoContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            videoContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            videoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Control Layout Overlay
            controlLayout.topAnchor.constraint(equalTo: view.topAnchor),
            controlLayout.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            controlLayout.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlLayout.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Botão Voltar
            btVoltar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            btVoltar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            btVoltar.widthAnchor.constraint(equalToConstant: 44),
            btVoltar.heightAnchor.constraint(equalToConstant: 44),

            // Botão Som
            btSom.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            btSom.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            btSom.widthAnchor.constraint(equalToConstant: 44),
            btSom.heightAnchor.constraint(equalToConstant: 44),

            // Tocartudo & Modo Bebê
            playAllVideosButton.topAnchor.constraint(equalTo: btVoltar.bottomAnchor, constant: 16),
            playAllVideosButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            playAllVideosButton.widthAnchor.constraint(equalToConstant: 44),
            playAllVideosButton.heightAnchor.constraint(equalToConstant: 44),

            babyModeButton.topAnchor.constraint(equalTo: btSom.bottomAnchor, constant: 16),
            babyModeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            babyModeButton.widthAnchor.constraint(equalToConstant: 44),
            babyModeButton.heightAnchor.constraint(equalToConstant: 44),

            // Mid Controls (Retroceder, Play/Pause, Avançar)
            playPauseButton.centerXAnchor.constraint(equalTo: controlLayout.centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: controlLayout.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 64),
            playPauseButton.heightAnchor.constraint(equalToConstant: 64),

            backwardButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            backwardButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -40),
            backwardButton.widthAnchor.constraint(equalToConstant: 44),
            backwardButton.heightAnchor.constraint(equalToConstant: 44),

            forwardButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            forwardButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 40),
            forwardButton.widthAnchor.constraint(equalToConstant: 44),
            forwardButton.heightAnchor.constraint(equalToConstant: 44),

            // SeekBar
            seekBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            seekBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            seekBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            // View Timer Popup
            viewTimer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewTimer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            viewTimer.widthAnchor.constraint(equalToConstant: 120),
            viewTimer.heightAnchor.constraint(equalToConstant: 120),

            numTimerLabel.centerXAnchor.constraint(equalTo: viewTimer.centerXAnchor),
            numTimerLabel.centerYAnchor.constraint(equalTo: viewTimer.centerYAnchor)
        ])
    }

    // MARK: - Actions & Touch Setup
    private func setupActions() {
        btVoltar.addTarget(self, action: #selector(closeWindow), for: .touchUpInside)
        btSom.addTarget(self, action: #selector(toggleSom), for: .touchUpInside)
        playAllVideosButton.addTarget(self, action: #selector(togglePlayAll), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        backwardButton.addTarget(self, action: #selector(backward10Sec), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(forward10Sec), for: .touchUpInside)

        // Gesture de Tap no background para ocultar/exibir os controles
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleControlVisibility))
        controlLayout.addGestureRecognizer(tapGesture)

        // Seekbar target actions
        seekBar.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)

        // Touch gesture customizado para segurar o botão de Modo Bebê
        let longPressBabyMode = UILongPressGestureRecognizer(target: self, action: #selector(handleBabyModeTouch(_:)))
        longPressBabyMode.minimumPressDuration = 0.0
        babyModeButton.addGestureRecognizer(longPressBabyMode)
    }

    private func loadPreferences() {
        self.checkModoBB = UserDefaults.standard.object(forKey: "MODO_BB") as? Bool ?? true
    }

    private func initAnalytics() {
        print("Screen Name: /ExecutaVideo")
    }

    // MARK: - Video Execution Core
    private func playVideo() {
        guard currentContentIndex < playList.count else { return }
        let currentSong = playList[currentContentIndex]

        var videoURL: URL?
        if let urlString = currentSong.urlDownload, let remoteURL = URL(string: urlString) {
            videoURL = remoteURL
        } else {
            // Caso seja um arquivo baixado localmente na pasta Documents
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            videoURL = documentsDirectory.appendingPathComponent(currentSong.fileName)
        }

        guard let finalURL = videoURL else {
            showCorruptedErrorAlert()
            return
        }

        removePeriodicTimeObserver()
        playerItem = AVPlayerItem(url: finalURL)
        player = AVPlayer(playerItem: playerItem)
        playerLayer.player = player
        player?.isMuted = isMuted

        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)

        addPeriodicTimeObserver()
        player?.play()
        playPauseButton.setImage(UIImage(named: "pause_button"), for: .normal)
    }

    private func addPeriodicTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, let duration = self.playerItem?.duration.seconds, !duration.isNaN else { return }
            self.seekBar.maximumValue = Float(duration)
            self.seekBar.value = Float(time.seconds)
        }
    }

    private func removePeriodicTimeObserver() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }

    @objc private func playerItemDidReachEnd(_ notification: Notification) {
        if isErrorState { return }

        if isPlayAllEnabled {
            if let nextSong = getNextVideo(babyModeEnabled: isBabyModeEnabled),
               let nextIndex = playList.firstIndex(where: { $0.fileName == nextSong.fileName }) {
                currentContentIndex = nextIndex
                playVideo()
            } else {
                closeWindow()
            }
        } else if isBabyModeEnabled {
            playVideo()
        } else {
            closeWindow()
        }
    }

    // MARK: - Navigation Control
    
    /// Método do botão 'btVoltar' que encerra a reprodução do vídeo e retorna para a HomeAtividade
    @objc public func closeWindow() {
        if isBabyModeEnabled { return }

        player?.pause()
        removePeriodicTimeObserver()

        let somAtivo = UserDefaults.standard.bool(forKey: "flagson")
        if somAtivo {
            // Reproduz o som de fechamento local se ativado
            print("Playing local asset: o_sabao.mp3")
        }

        if let nav = navigationController {
            if let homeVC = nav.viewControllers.first(where: { $0 is HomeAtividade }) {
                nav.popToViewController(homeVC, animated: true)
            } else {
                nav.popViewController(animated: true)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Actions Operations
    @objc private func toggleControlVisibility() {
        UIView.animate(withDuration: 0.3) {
            self.controlLayout.alpha = (self.controlLayout.alpha == 0.0) ? 1.0 : 0.0
        }
    }

    @objc private func toggleSom() {
        if isBabyModeEnabled { return }
        isMuted.toggle()
        player?.isMuted = isMuted
        let imageName = isMuted ? "bt_som_off" : "bt_som"
        btSom.setImage(UIImage(named: imageName), for: .normal)
    }

    @objc private func togglePlayAll() {
        if isBabyModeEnabled { return }
        isPlayAllEnabled.toggle()
        let imageName = isPlayAllEnabled ? "bt_tocartudo_on" : "bt_tocartudo_off"
        playAllVideosButton.setImage(UIImage(named: imageName), for: .normal)
    }

    @objc private func togglePlayPause() {
        if isBabyModeEnabled { return }
        guard let player = player else { return }

        if player.timeControlStatus == .playing {
            player.pause()
            playPauseButton.setImage(UIImage(named: "play_button"), for: .normal)
        } else {
            player.play()
            playPauseButton.setImage(UIImage(named: "pause_button"), for: .normal)
        }
    }

    @objc private func backward10Sec() {
        if isBabyModeEnabled { return }
        guard let currentTime = player?.currentTime() else { return }
        let newTime = max(CMTimeGetSeconds(currentTime) - 10.0, 0.0)
        player?.seek(to: CMTime(seconds: newTime, preferredTimescale: 1000))
    }

    @objc private func forward10Sec() {
        if isBabyModeEnabled { return }
        guard let player = player, let duration = playerItem?.duration.seconds else { return }
        let newTime = min(CMTimeGetSeconds(player.currentTime()) + 10.0, duration)
        player.seek(to: CMTime(seconds: newTime, preferredTimescale: 1000))
    }

    @objc private func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if isBabyModeEnabled { return }
        let seconds = Double(slider.value)
        let targetTime = CMTime(seconds: seconds, preferredTimescale: 1000)

        if let touch = event.allTouches?.first {
            switch touch.phase {
            case .began:
                removePeriodicTimeObserver()
            case .ended:
                player?.seek(to: targetTime) { [weak self] _ in
                    self?.addPeriodicTimeObserver()
                }
            default:
                break
            }
        }
    }

    // MARK: - Baby Mode Gesture Logic
    @objc private func handleBabyModeTouch(_ gesture: UILongPressGestureRecognizer) {
        guard checkModoBB else {
            let alert = UIAlertController(title: nil, message: "O Modo Bebê está desativado\npara utilizá-lo ative-o no menu configurações!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        switch gesture.state {
        case .began:
            if isBabyModeEnabled {
                startUnlockTimer()
            } else {
                setBabyModeState(enabled: true)
            }
        case .ended, .cancelled, .failed:
            cancelUnlockTimer()
        default:
            break
        }
    }

    private func startUnlockTimer() {
        secController = 3
        numTimerLabel.text = "\(secController)"
        viewTimer.isHidden = false

        unlockTimer?.invalidate()
        unlockTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.secController -= 1
            if self.secController > 0 {
                self.numTimerLabel.text = "\(self.secController)"
            } else {
                self.cancelUnlockTimer()
                self.setBabyModeState(enabled: false)
            }
        }
    }

    private func cancelUnlockTimer() {
        unlockTimer?.invalidate()
        unlockTimer = nil
        viewTimer.isHidden = true
        secController = 3
    }

    private func setBabyModeState(enabled: Bool) {
        isBabyModeEnabled = enabled
        let imageName = enabled ? "modo_bebe_on" : "modo_bebe"
        babyModeButton.setImage(UIImage(named: imageName), for: .normal)
        seekBar.isEnabled = !enabled
    }

    // MARK: - Helpers & Error Alerts
    private func getNextVideo(babyModeEnabled: Bool) -> Song? {
        var pos = currentContentIndex + 1
        if pos >= playList.count {
            if !babyModeEnabled { return nil }
            pos = 0
        }
        return playList[pos]
    }

    private func showCorruptedErrorAlert() {
        isErrorState = true
        let alert = UIAlertController(
            title: "Atenção",
            message: "Não foi possível reproduzir o vídeo pois o arquivo está corrompido. Por favor, clique em OK para sair e faça um novo download do vídeo.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.closeWindow()
        }))
        present(alert, animated: true)
    }
}
