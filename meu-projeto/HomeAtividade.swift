// HomeAtividade.swift
import UIKit
import AVFoundation

protocol HomeAtividadeDelegate: AnyObject {
    func loadVideo(content: Song, position: Int)
    func startDownload(pos: Int, content: Song)
    func downloadColection(products: [Album])
    func downloadAlbum(product: Album)
    func downloadItem(content: Song)
}

class HomeAtividade: UIViewController, HomeAtividadeDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Audio Player
    private var audioPlayer: AVAudioPlayer?

    // MARK: - Properties
    private var contents: [Song] = []
    private var products: [Album] = []
    private var selectedAlbumIndex: Int = 0

    // MARK: - UI Components
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        if let image = UIImage(named: "bg_home.png") ?? UIImage(named: "bg_home") {
            imageView.image = image
        } else {
            imageView.backgroundColor = UIColor(red: 0.1, green: 0.5, blue: 0.9, alpha: 1.0)
        }
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var btSobre: UIButton = {
        let button = UIButton(type: .custom)
        if let image = UIImage(named: "bt_sobre.png") ?? UIImage(named: "bt_sobre") {
            button.setImage(image, for: .normal)
        } else {
            button.setTitle("Sobre", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .systemOrange
            button.layer.cornerRadius = 8
        }
        button.addTarget(self, action: #selector(sobreButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // UICollectionView para listagem dos vídeos em formato de carrossel
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.identifier)
        cv.dataSource = self
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        playBackgroundAudio()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let player = audioPlayer, !player.isPlaying {
            player.play()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioPlayer?.pause()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Sound Function
    private func playBackgroundAudio() {
        guard let url = Bundle.main.url(forResource: "o_sabao", withExtension: "mp3") else {
            print("❌ Erro: o_sabao.mp3 não encontrado no Bundle.")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("❌ Erro ao inicializar o player de áudio: \(error.localizedDescription)")
        }
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(backgroundImageView)
        view.addSubview(btSobre)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            // Fundo
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Botão Sobre
            btSobre.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            btSobre.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            btSobre.widthAnchor.constraint(equalToConstant: 60),
            btSobre.heightAnchor.constraint(equalToConstant: 44),

            // Carrossel de Vídeos (Centralizado na metade inferior)
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalToConstant: 160)
        ])
    }

    // MARK: - Data Handling
    private func loadData() {
        self.products = getProducts()
        if !products.isEmpty {
            self.contents = products[0].songs ?? []
        }
        collectionView.reloadData()
    }

    // MARK: - Actions
    @objc private func sobreButtonTapped() {
        let sobreVC = SobreAtividade()
        if let nav = navigationController {
            nav.pushViewController(sobreVC, animated: true)
        } else {
            sobreVC.modalPresentationStyle = .fullScreen
            present(sobreVC, animated: true, completion: nil)
        }
    }

    // MARK: - UICollectionView DataSource & Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.identifier, for: indexPath) as? VideoCell else {
            return UICollectionViewCell()
        }
        let song = contents[indexPath.item]
        cell.configure(with: song)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 140)
    }

    // Clique no vídeo -> Executa a ExecutaVideoAtividade
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedSong = contents[indexPath.item]
        loadVideo(content: selectedSong, position: indexPath.item)
    }

    // MARK: - HomeAtividadeDelegate Implementation
    func loadVideo(content: Song, position: Int) {
        let downloadPath = content.isDownloaded() ? content.getLocalVideoMP4URL().path : (content.getDownloadURL()?.absoluteString ?? "")

        // Pausa a música de fundo
        audioPlayer?.pause()

        // Abre o player de vídeo
        let executaVC = ExecutaVideoAtividade()
        executaVC.downloadUrl = downloadPath
        executaVC.currentIndex = position
        executaVC.playlist = self.contents

        if let nav = navigationController {
            nav.pushViewController(executaVC, animated: true)
        } else {
            executaVC.modalPresentationStyle = .fullScreen
            present(executaVC, animated: true, completion: nil)
        }
    }

    func startDownload(pos: Int, content: Song) {}
    func downloadColection(products: [Album]) {}
    func downloadAlbum(product: Album) {}
    func downloadItem(content: Song) {}

    private func getProducts() -> [Album] {
        return self.products
    }
}

// MARK: - Cell Customizada para renderizar a miniatura do vídeo
class VideoCell: UICollectionViewCell {
    static let identifier = "VideoCell"

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .darkGray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 100),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) não foi implementado")
    }

    func configure(with song: Song) {
        titleLabel.text = song.songName ?? "Vídeo"
        if let thumbName = song.getThumb(), let image = UIImage(named: thumbName) {
            imageView.image = image
        } else {
            imageView.image = UIImage(named: "bg_splash.png")
        }
    }
}
