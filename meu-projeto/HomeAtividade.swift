import UIKit
import AVFoundation

public class HomeAtividade: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Properties
    public var contents: [Song] = []
    private var audioPlayer: AVAudioPlayer?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(VideoCell.self, forCellWithReuseIdentifier: "VideoCell")
        return cv
    }()
    
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "bg_splash") ?? UIImage(named: "bg_main")
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // MARK: - Lifecycle
    override public func loadView() {
    super.loadView()
    // Define a cor de fundo explícita para evitar transparência preta
    let mainView = UIView(frame: UIScreen.main.bounds)
    mainView.backgroundColor = UIColor(red: 0.15, green: 0.65, blue: 0.88, alpha: 1.0) // Azul "Três Palavrinhas"
    self.view = mainView
}


    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        carregarMusicas()
        iniciarAudioFundo()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Retoma a música de fundo quando o usuário volta do vídeo
        if audioPlayer?.isPlaying == false {
            audioPlayer?.play()
        }
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pausa o áudio de fundo para não dar conflito de áudio com o vídeo que vai abrir
        audioPlayer?.pause()
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }

    // MARK: - Audio Background Loop (o_sabao.mp3)
    private func iniciarAudioFundo() {
        guard let url = Bundle.main.url(forResource: "o_sabao", withExtension: "mp3") else {
            print("Aviso: o_sabao.mp3 não encontrado no Bundle.")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop infinito
            audioPlayer?.volume = 0.5
            audioPlayer?.play()
        } catch {
            print("Erro ao tocar áudio de fundo: \(error)")
        }
    }

    private func carregarMusicas() {
        // Exemplo/Mock de carregamento da lista se estiver vazia
        if contents.isEmpty {
            contents = [
                Song(id: "dvd1_o_sabao", title: "O Sabão", fileName: "video_dvd1_o_sabao.mp4"),
                Song(id: "dvd2_pare", title: "Pare", fileName: "video_dvd2_pare.mp4"),
                Song(id: "dvd3_meu_melhor_amigo", title: "Meu Melhor Amigo", fileName: "video_dvd3_meu_melhor_amigo.mp4"),
                Song(id: "dormir_o_sabao", title: "O Sabão", fileName: "video_dormir_o_sabao.mp4"),
                Song(id: "tlw_soap", title: "Soap", fileName: "video_tlw_soap.mp4")
            ]
        }
        collectionView.reloadData()
    }

    // MARK: - UICollectionView DataSource & Delegate
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as? VideoCell else {
            return UICollectionViewCell()
        }
        let song = contents[indexPath.item]
        cell.configure(with: song)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 200)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let song = contents[indexPath.item]
    
    let executaVC = ExecutaVideoAtividade()
    executaVC.currentSong = song
    executaVC.currentIndex = indexPath.item
    executaVC.playlist = self.contents
    
    // Força apresentação Full Screen
    executaVC.modalPresentationStyle = .fullScreen
    
    // Pausa a música de fundo o_sabao.mp3 antes de abrir o vídeo
    audioPlayer?.pause()
    
    present(executaVC, animated: true, completion: 
    }
}
    
