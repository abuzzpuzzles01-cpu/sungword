import UIKit
import AVFoundation

// MARK: - Protocolos
protocol VideoAdapterListener: AnyObject {
    func loadVideo(content: Song, position: Int)
    func playVideo(downloadPath: String, position: Int)
    func startDownload(pos: Int, content: Song)
}

protocol DownloadAllListener: AnyObject {
    func downloadColection(products: [Album])
    func downloadAlbum(product: Album)
    func downloadItem(content: Song)
}

protocol ParentalControlPopupListener: AnyObject {
    func onUserUnblockedParentalControl(position: Int)
}

protocol PurchasePopupListener: AnyObject {
    func onUserPurchase()
}

// MARK: - UIViewController Principal
class HomeAtividade: UIViewController, VideoAdapterListener, DownloadAllListener, ParentalControlPopupListener, PurchasePopupListener {

    // MARK: - IBOutlets / Componentes de UI
    private let containerHome: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let backgroundImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // Botões dos DVDs
    private let btDvd1 = UIButton(type: .custom)
    private let btDvd2 = UIButton(type: .custom)
    private let btDvd3 = UIButton(type: .custom)
    private let btDvdEn = UIButton(type: .custom)
    private let btHoraDormir = UIButton(type: .custom)

    // Botões de Ação
    private let btSobre = UIButton(type: .custom)
    private let btSom = UIButton(type: .custom)
    private let btConfig = UIButton(type: .custom)

    // CollectionView para a lista de vídeos
    private lazy var collectionViewVideos: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    // MARK: - Propriedades de Estado
    private var contents: [Song] = []
    private var products: [Album] = []
    private var somAtivo: Bool = true
    private var audioPlayer: AVAudioPlayer?
    private var selectedDvdIndex: Int = 0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        initData()
        carregaVideos()
        setupAudioObserver()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkSoundPreference()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pararSomBackground()
    }

    // MARK: - Setup UI & Layout
    private func setupUI() {
        view.addSubview(containerHome)
        containerHome.addSubview(backgroundImage)
        containerHome.addSubview(collectionViewVideos)

        NSLayoutConstraint.activate([
            containerHome.topAnchor.constraint(equalTo: view.topAnchor),
            containerHome.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerHome.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerHome.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            backgroundImage.topAnchor.constraint(equalTo: containerHome.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: containerHome.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: containerHome.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: containerHome.trailingAnchor),

            collectionViewVideos.topAnchor.constraint(equalTo: containerHome.topAnchor, constant: 120),
            collectionViewVideos.bottomAnchor.constraint(equalTo: containerHome.bottomAnchor, constant: -20),
            collectionViewVideos.leadingAnchor.constraint(equalTo: containerHome.leadingAnchor, constant: 16),
            collectionViewVideos.trailingAnchor.constraint(equalTo: containerHome.trailingAnchor, constant: -16)
        ])

        collectionViewVideos.dataSource = self
        collectionViewVideos.delegate = self
        collectionViewVideos.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "VideoCell")
    }

    private func setupActions() {
        btDvd1.addTarget(self, action: #selector(dvd1Tapped), for: .touchUpInside)
        btDvd2.addTarget(self, action: #selector(dvd2Tapped), for: .touchUpInside)
        btDvd3.addTarget(self, action: #selector(dvd3Tapped), for: .touchUpInside)
        btDvdEn.addTarget(self, action: #selector(dvdEnTapped), for: .touchUpInside)
        btHoraDormir.addTarget(self, action: #selector(horaDormirTapped), for: .touchUpInside)

        btSom.addTarget(self, action: #selector(toggleSom), for: .touchUpInside)
        btSobre.addTarget(self, action: #selector(abrirSobre), for: .touchUpInside)
        btConfig.addTarget(self, action: #selector(openSecurity), for: .touchUpInside)
    }

    // MARK: - Inicialização de Dados
    private func initData() {
        // Carrega produtos (exemplo através de Mock ou Manager global)
        self.products = TresPalavrinhasAppManager.shared.getProducts()
        
        // Preferência do som
        self.somAtivo = UserDefaults.standard.object(forKey: "flagson") != nil ? UserDefaults.standard.bool(forKey: "flagson") : true
        atualizarIconeSom()
        
        if somAtivo {
            tocarSomBackground("o_sabao", ext: "mp3")
        }
        
        // Posição inicial das abas dos DVDs
        animarSelecaoAba(dvdSelecionado: btDvd1)
    }

    private func carregaVideos() {
        guard !products.isEmpty else { return }
        selectedDvdIndex = 0
        self.contents = products[0].songs ?? []
        self.backgroundImage.image = UIImage(named: "background")
        self.collectionViewVideos.reloadData()
    }

    // MARK: - Navegação dos DVDs
    @objc private func dvd1Tapped() {
        guard selectedDvdIndex != 0 else { return }
        selectedDvdIndex = 0
        animarSelecaoAba(dvdSelecionado: btDvd1)
        backgroundImage.image = UIImage(named: "background")
        if products.count > 0 {
            contents = products[0].songs ?? []
            collectionViewVideos.reloadData()
        }
    }

    @objc private func dvd2Tapped() {
        guard selectedDvdIndex != 1 else { return }
        selectedDvdIndex = 1
        animarSelecaoAba(dvdSelecionado: btDvd2)
        backgroundImage.image = UIImage(named: "bg_dvd2")
        if products.count > 1 {
            contents = products[1].songs ?? []
            collectionViewVideos.reloadData()
        }
    }

    @objc private func dvd3Tapped() {
        guard selectedDvdIndex != 2 else { return }
        selectedDvdIndex = 2
        animarSelecaoAba(dvdSelecionado: btDvd3)
        backgroundImage.image = UIImage(named: "fundo")
        if products.count > 3 {
            contents = products[3].songs ?? []
            collectionViewVideos.reloadData()
        }
    }

    @objc private func dvdEnTapped() {
        guard selectedDvdIndex != 3 else { return }
        selectedDvdIndex = 3
        animarSelecaoAba(dvdSelecionado: btDvdEn)
        backgroundImage.image = UIImage(named: "fundo_en")
        if products.count > 4 {
            contents = products[4].songs ?? []
            collectionViewVideos.reloadData()
        }
    }

    @objc private func horaDormirTapped() {
        guard selectedDvdIndex != 4 else { return }
        selectedDvdIndex = 4
        animarSelecaoAba(dvdSelecionado: btHoraDormir)
        backgroundImage.image = UIImage(named: "bg_hora_dormir")
        if products.count > 2 {
            contents = products[2].songs ?? []
            collectionViewVideos.reloadData()
        }
    }

    private func animarSelecaoAba(dvdSelecionado: UIButton) {
        let botoes = [btDvd1, btDvd2, btDvd3, btDvdEn, btHoraDormir]
        UIView.animate(withDuration: 0.3) {
            for btn in botoes {
                if btn == dvdSelecionado {
                    btn.transform = CGAffineTransform.identity
                } else {
                    btn.transform = CGAffineTransform(translationX: 0, y: -20)
                }
            }
        }
    }

    // MARK: - Gerenciamento de Som
    @objc private func toggleSom() {
        somAtivo.toggle()
        UserDefaults.standard.set(somAtivo, forKey: "flagson")
        atualizarIconeSom()

        if somAtivo {
            tocarSomBackground("o_sabao", ext: "mp3")
        } else {
            pararSomBackground()
        }
    }

    private func checkSoundPreference() {
        self.somAtivo = UserDefaults.standard.bool(forKey: "flagson")
        if somAtivo {
            tocarSomBackground("o_sabao", ext: "mp3")
        }
    }

    private func atualizarIconeSom() {
        let imageName = somAtivo ? "bt_som" : "bt_som_off"
        btSom.setImage(UIImage(named: imageName), for: .normal)
    }

    private func tocarSomBackground(_ nome: String, ext: String) {
        guard let url = Bundle.main.url(forResource: nome, withExtension: ext) else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            print("Erro ao tocar áudio: \(error.localizedDescription)")
        }
    }

    private func pararSomBackground() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    private func setupAudioObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @objc private func appDidEnterBackground() {
        pararSomBackground()
    }

    // MARK: - Modais e Navegação
// Linha 278 em diante no HomeAtividade.swift:
@objc private func sobreButtonTapped() {
    let sobreVC = SobreAtividade() // <- LINHA 279 (Erro ocorre aqui se SobreAtividade.swift não for compilado)
    if let nav = navigationController {
        nav.pushViewController(sobreVC, animated: true)
    } else {
        sobreVC.modalPresentationStyle = .fullScreen
        present(sobreVC, animated: true, completion: nil)
    }
}


    @objc private func openSecurity() {
        // Exibe o alerta ou modal de Controle Parental
        let alert = UIAlertController(title: "Controle Parental", message: "Digite a resposta para continuar", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Quanto é 2 + 2?"
            tf.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "Confirmar", style: .default, handler: { [weak self] _ in
            if alert.textFields?.first?.text == "4" {
                self?.onUserUnblockedParentalControl(position: -1)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }

    private func openConfig() {
        print("Abrindo configurações de vídeos...")
    }

    // MARK: - Protocolo VideoAdapterListener
    func loadVideo(content: Song, position: Int) {
        let mp4URL = content.getLocalVideoMP4URL()
        
        if FileManager.default.fileExists(atPath: mp4URL.path) {
            playVideo(downloadPath: mp4URL.path, position: position)
        } else {
            // Se estiver em modo offline
            let isOfflineMode = UserDefaults.standard.bool(forKey: "offline_mode")
            if isOfflineMode {
                let alert = UIAlertController(title: "Modo off-line", message: "Uma conexão à internet é necessária para executar este vídeo.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            } else {
                startDownload(pos: position, content: content)
            }
        }
    }

    func playVideo(downloadPath: String, position: Int) {
        let executaVC = ExecutaVideoAtividade()
        executaVC.downloadUrl = downloadPath
        executaVC.currentIndex = position
        executaVC.playlist = self.contents

        if let nav = navigationController {
            nav.pushViewController(executaVC, animated: true)
        } else {
            executaVC.modalPresentationStyle = .fullScreen
            present(executaVC, animated: true)
        }
    }

    func startDownload(pos: Int, content: Song) {
        let progressAlert = UIAlertController(title: content.songName ?? "Baixando", message: "Baixando Arquivo...", preferredStyle: .alert)
        present(progressAlert, animated: true)

        VideoDownloadManager.shared.downloadAndDecompressVideo(song: content) { [weak self] result in
            progressAlert.dismiss(animated: true) {
                guard let self = self else { return }
                switch result {
                case .success(let localURL):
                    let confirmAlert = UIAlertController(title: "Download concluído", message: "Gostaria de assistir este vídeo agora?", preferredStyle: .alert)
                    confirmAlert.addAction(UIAlertAction(title: "Não", style: .cancel))
                    confirmAlert.addAction(UIAlertAction(title: "Sim", style: .default, handler: { _ in
                        self.playVideo(downloadPath: localURL.path, position: pos)
                    }))
                    self.present(confirmAlert, animated: true)
                case .failure(let error):
                    let errAlert = UIAlertController(title: "Erro", message: error.localizedDescription, preferredStyle: .alert)
                    errAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errAlert, animated: true)
                }
            }
        }
    }

    // MARK: - Protocolo ParentalControlPopupListener
    func onUserUnblockedParentalControl(position: Int) {
        if position >= 0 {
            print("Abrir compra para posição: \(position)")
        } else {
            openConfig()
        }
    }

    // MARK: - Protocolo PurchasePopupListener
    func onUserPurchase() {
        self.products = TresPalavrinhasAppManager.shared.getProducts()
        self.collectionViewVideos.reloadData()
    }

    // MARK: - Protocolo DownloadAllListener
    func downloadColection(products: [Album]) {}
    func downloadAlbum(product: Album) {}
    func downloadItem(content: Song) {}
}

// MARK: - UICollectionView DataSource & Delegate
extension HomeAtividade: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath)
        let song = contents[indexPath.item]
        
        // Personalize a célula do vídeo aqui
        cell.backgroundColor = song.isDownloaded() ? .systemGreen : .systemGray4
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedSong = contents[indexPath.item]
        loadVideo(content: selectedSong, position: indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 20) / 3
        return CGSize(width: width, height: width * 0.75)
    }
}

// MARK: - Singleton Helper do App
class TresPalavrinhasAppManager {
    static let shared = TresPalavrinhasAppManager()
    private init() {}

    func getProducts() -> [Album] {
        return [] // Retornar os álbuns configurados no seu projeto
    }
}
