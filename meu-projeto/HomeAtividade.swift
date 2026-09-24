// HomeAtividade.swift
import UIKit
import AVFoundation

class HomeAtividade: UIViewController, HomeAtividadeDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private var audioPlayer: AVAudioPlayer?
    private var contents: [Song] = []
    private var products: [Album] = []

    // MARK: - Componentes de Interface

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        if let image = UIImage(named: "bg_home.png") ?? UIImage(named: "bg_home") {
            imageView.image = image
        }
        // Fundo fallback chamativo (Azul) para se a imagem "bg_home" não existir no bundle
        imageView.backgroundColor = UIColor(red: 0.1, green: 0.5, blue: 0.9, alpha: 1.0)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
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

    // MARK: - LifeCycle

    override func loadView() {
        // Força a criação da view base com o frame do display para não zerar
        let mainView = UIView(frame: UIScreen.main.bounds)
        mainView.backgroundColor = .systemRed // SE FICAR VERMELHO: O SceneDelegate funcionou, mas as subviews não foram desenhadas
        self.view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        playBackgroundAudio()
    }

    private func setupUI() {
        // Adiciona as subviews
        view.addSubview(backgroundImageView)
        view.addSubview(btSobre)
        view.addSubview(collectionView)

        // Ativa as Constraints com prioridade
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            btSobre.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            btSobre.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            btSobre.widthAnchor.constraint(equalToConstant: 60),
            btSobre.heightAnchor.constraint(equalToConstant: 44),

            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    // MARK: - Audio & Methods
    private func playBackgroundAudio() {
        guard let url = Bundle.main.url(forResource: "o_sabao", withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            print("Erro áudio: \(error.localizedDescription)")
        }
    }

    private func loadData() {
        self.products = getProducts()
        if !products.isEmpty {
            self.contents = products[0].songs ?? []
        }
        collectionView.reloadData()
    }

    @objc private func sobreButtonTapped() {
        let sobreVC = SobreAtividade()
        present(sobreVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.identifier, for: indexPath) as? VideoCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: contents[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 130)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        loadVideo(content: contents[indexPath.item], position: indexPath.item)
    }

    func loadVideo(content: Song, position: Int) {
        let downloadPath = content.isDownloaded() ? content.getLocalVideoMP4URL().path : (content.getDownloadURL()?.absoluteString ?? "")
        audioPlayer?.pause()
        let executaVC = ExecutaVideoAtividade()
        executaVC.downloadUrl = downloadPath
        executaVC.currentIndex = position
        executaVC.playlist = self.contents
        present(executaVC, animated: true)
    }

    func startDownload(pos: Int, content: Song) {}
    func downloadColection(products: [Album]) {}
    func downloadAlbum(product: Album) {}
    func downloadItem(content: Song) {}

    private func getProducts() -> [Album] {
        return self.products
    }
}
