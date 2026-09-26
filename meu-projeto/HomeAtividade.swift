import UIKit
import AVFoundation

public class HomeAtividade: UIViewController {

    // MARK: - Properties
    public var playlist: [Song] = []
    
    private var homeAudioPlayer: AVAudioPlayer?
    
    // Imagem de fundo
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "background.png")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    // MARK: - Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupCollectionView()
        
        carregarPlaylistCompleta()
        iniciarAudioHome()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retomarAudioHome()
        collectionView.reloadData()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pausarAudioHome()
    }

    // MARK: - Setup
    private func setupBackground() {
        view.addSubview(backgroundImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SongCell.self, forCellWithReuseIdentifier: SongCell.identifier)
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Mapeamento de Músicas
    private func carregarPlaylistCompleta() {
        let baseURL = "https://newabuzzassets.b-cdn.net/assets/tres_palavrinhas"

        self.playlist = [
            // --- DVD 1 ---
            Song(id: "dvd1_3_palavrinhas", title: "3 Palavrinhas", urlVideo: "\(baseURL)/dvd1/video_dvd1_3_palavrinhas.mp4", isFreeContent: false),
            Song(id: "dvd1_a_deus_dai_louvor", title: "A Deus Dai Louvor", urlVideo: "\(baseURL)/dvd1/video_dvd1_a_deus_dai_louvor.mp4", isFreeContent: false),
            Song(id: "dvd1_alo", title: "Alô", urlVideo: "\(baseURL)/dvd1/video_dvd1_alo.mp4", isFreeContent: false),
            Song(id: "dvd1_ao_senhor_agradecemos", title: "Ao Senhor Agradecemos", urlVideo: "\(baseURL)/dvd1/video_dvd1_ao_senhor_agradecemos.mp4", isFreeContent: false),
            Song(id: "dvd1_deus_criou_os_peixes", title: "Deus Criou os Peixes", urlVideo: "\(baseURL)/dvd1/video_dvd1_deus_criou_os_peixes.mp4", isFreeContent: false),
            Song(id: "dvd1_estou_alegre", title: "Estou Alegre", urlVideo: "\(baseURL)/dvd1/video_dvd1_estou_alegre.mp4", isFreeContent: false),
            Song(id: "dvd1_meu_barco", title: "Meu Barco", urlVideo: "\(baseURL)/dvd1/video_dvd1_meu_barco.mp4", isFreeContent: false),
            Song(id: "dvd1_missionariozinho", title: "Missionariozinho", urlVideo: "\(baseURL)/dvd1/video_dvd1_missionariozinho.mp4", isFreeContent: false),
            Song(id: "dvd1_o_sabao", title: "O Sabão", fileName: "video_dvd1_o_sabao.mp4", urlVideo: nil, isFreeContent: true),
            Song(id: "dvd1_quem_fez", title: "Quem Fez", urlVideo: "\(baseURL)/dvd1/video_dvd1_quem_fez.mp4", isFreeContent: false),

            // --- HORA DE DORMIR ---
            Song(id: "dormir_3_palavrinhas", title: "3 Palavrinhas (Hora de Dormir)", urlVideo: "\(baseURL)/dormir/video_dormir_3_palavrinhas.mp4", isFreeContent: false),
            Song(id: "dormir_a_deus_dai_louvor", title: "A Deus Dai Louvor (Hora de Dormir)", urlVideo: "\(baseURL)/dormir/video_dormir_a_deus_dai_louvor.mp4", isFreeContent: false),
            Song(id: "dormir_alo", title: "Alô (Hora de Dormir)", urlVideo: "\(baseURL)/dormir/video_dormir_alo.mp4", isFreeContent: false),
            Song(id: "dormir_ao_senhor_agradecemos", title: "Ao Senhor Agradecemos (Hora de Dormir)", urlVideo: "\(baseURL)/dormir/video_dormir_ao_senhor_agradecemos.mp4", isFreeContent: false),
            Song(id: "dormir_deus_criou_os_peixes", title: "Deus Criou os Peixes (Hora de Dormir)", urlVideo: "\(baseURL)/dormir/video_dormir_deus_criou_os_peixes.mp4", isFreeContent: false),
            Song(id: "dormir_estou_alegre", title: "Estou Alegre (Hora de Dormir)", urlVideo: "\(baseURL)/dormir/video_dormir_estou_alegre.mp4", isFreeContent: false),
            Song(id: "dormir_meu_barco", title: "Meu Barco (Hora de Dormir)", urlVideo: "\(baseURL)/dormir/video_dormir_meu_barco.mp4", isFreeContent: false),
            Song(id: "dormir_missionariozinho", title: "Missionariozinho (Hora de Dormir)", urlVideo: "\(baseURL)/dormir/video_dormir_missionariozinho.mp4", isFreeContent: false),
            Song(id: "dormir_o_sabao", title: "O Sabão (Hora de Dormir)", fileName: "video_dormir_o_sabao.mp4", urlVideo: nil, isFreeContent: true),
            Song(id: "dormir_quem_fez", title: "Quem Fez (Hora de Dormir)", urlVideo: "\(baseURL)/dormir/video_dormir_quem_fez.mp4", isFreeContent: false),

            // --- DVD 2 ---
            Song(id: "dvd2_assim_vou_louvar", title: "Assim Vou Louvar", urlVideo: "\(baseURL)/dvd2/video_dvd2_assim_vou_louvar.mp4", isFreeContent: false),
            Song(id: "dvd2_deus_e_bom_para_mim", title: "Deus é Bom Para Mim", urlVideo: "\(baseURL)/dvd2/video_dvd2_deus_e_bom_para_mim.mp4", isFreeContent: false),
            Song(id: "dvd2_deus_lhe_tem_amor", title: "Deus Lhe Tem Amor", urlVideo: "\(baseURL)/dvd2/video_dvd2_deus_lhe_tem_amor.mp4", isFreeContent: false),
            Song(id: "dvd2_e_bom_e_muito_bom", title: "É Bom, É Muito Bom", urlVideo: "\(baseURL)/dvd2/video_dvd2_e_bom_e_muito_bom.mp4", isFreeContent: false),
            Song(id: "dvd2_familia_original", title: "Família Original", urlVideo: "\(baseURL)/dvd2/video_dvd2_familia_original.mp4", isFreeContent: false),
            Song(id: "dvd2_florzinha_e_soldadinho", title: "Florzinha e Soldadinho", urlVideo: "\(baseURL)/dvd2/video_dvd2_florzinha_e_soldadinho.mp4", isFreeContent: false),
            Song(id: "dvd2_leia_a_biblia", title: "Leia a Bíblia", urlVideo: "\(baseURL)/dvd2/video_dvd2_leia_a_biblia.mp4", isFreeContent: false),
            Song(id: "dvd2_pare", title: "Pare!", fileName: "video_dvd2_pare.mp4", urlVideo: nil, isFreeContent: true),
            Song(id: "dvd2_toc_toc_toc", title: "Toc, Toc, Toc", urlVideo: "\(baseURL)/dvd2/video_dvd2_toc_toc_toc.mp4", isFreeContent: false),
            Song(id: "dvd2_trenzinho", title: "Trenzinho", urlVideo: "\(baseURL)/dvd2/video_dvd2_trenzinho.mp4", isFreeContent: false),

            // --- DVD 3 (Invertido: pasta /tlw/) ---
            Song(id: "dvd3_aleluia", title: "Aleluia", urlVideo: "\(baseURL)/tlw/video_dvd3_aleluia.mp4", isFreeContent: false),
            Song(id: "dvd3_churua", title: "Churuá", urlVideo: "\(baseURL)/tlw/video_dvd3_churua.mp4", isFreeContent: false),
            Song(id: "dvd3_e_feliz_o_lar", title: "É Feliz o Lar", urlVideo: "\(baseURL)/tlw/video_dvd3_e_feliz_o_lar.mp4", isFreeContent: false),
            Song(id: "dvd3_grande_e_largo", title: "Grande e Largo", urlVideo: "\(baseURL)/tlw/video_dvd3_grande_e_largo.mp4", isFreeContent: false),
            Song(id: "dvd3_ha_eu_amo_a_cristo", title: "Há, Eu Amo a Cristo", urlVideo: "\(baseURL)/tlw/video_dvd3_ha_eu_amo_a_cristo.mp4", isFreeContent: false),
            Song(id: "dvd3_homenzinho_torto", title: "Homenzinho Torto", urlVideo: "\(baseURL)/tlw/video_dvd3_homenzinho_torto.mp4", isFreeContent: false),
            Song(id: "dvd3_meu_bom_pastor", title: "Meu Bom Pastor", urlVideo: "\(baseURL)/tlw/video_dvd3_meu_bom_pastor.mp4", isFreeContent: false),
            Song(id: "dvd3_meu_coracao_era_sujo", title: "Meu Coração Era Sujo", urlVideo: "\(baseURL)/tlw/video_dvd3_meu_coracao_era_sujo.mp4", isFreeContent: false),
            Song(id: "dvd3_meu_melhor_amigo", title: "Meu Melhor Amigo", fileName: "video_dvd3_meu_melhor_amigo.mp4", urlVideo: nil, isFreeContent: true),
            Song(id: "dvd3_por_dentro_fora_alto_embaixo", title: "Por Dentro, Fora, Alto, Embaixo", urlVideo: "\(baseURL)/tlw/video_dvd3_por_dentro_fora_alto_embaixo.mp4", isFreeContent: false),

            // --- THE LITTLE WORDS (TLW) (Invertido: pasta /dvd3/) ---
            Song(id: "tlw_fatherabraham", title: "Father Abraham", urlVideo: "\(baseURL)/dvd3/video_tlw_fatherabraham.mp4", isFreeContent: false),
            Song(id: "tlw_god_made_the_fishes", title: "God Made the Fishes", urlVideo: "\(baseURL)/dvd3/video_tlw_god_made_the_fishes.mp4", isFreeContent: false),
            Song(id: "tlw_hello", title: "Hello", urlVideo: "\(baseURL)/dvd3/video_tlw_hello.mp4", isFreeContent: false),
            Song(id: "tlw_i_am_so_happy", title: "I Am So Happy", urlVideo: "\(baseURL)/dvd3/video_tlw_i_am_so_happy.mp4", isFreeContent: false),
            Song(id: "tlw_little_missionary", title: "Little Missionary", urlVideo: "\(baseURL)/dvd3/video_tlw_little_missionary.mp4", isFreeContent: false),
            Song(id: "tlw_my_boat", title: "My Boat", urlVideo: "\(baseURL)/dvd3/video_tlw_my_boat.mp4", isFreeContent: false),
            Song(id: "tlw_its_snack_time", title: "It's Snack Time", urlVideo: "\(baseURL)/dvd3/video_tlw_its_snack_time.mp4", isFreeContent: false),
            Song(id: "tlw_soap", title: "Soap", fileName: "video_tlw_soap.mp4", urlVideo: nil, isFreeContent: true),
            Song(id: "tlw_3_little_words", title: "3 Little Words", urlVideo: "\(baseURL)/dvd3/video_tlw_3_little_words.mp4", isFreeContent: false),
            Song(id: "tlw_who_made_it", title: "Who Made It", urlVideo: "\(baseURL)/dvd3/video_tlw_who_made_it.mp4", isFreeContent: false)
        ]
        
        collectionView.reloadData()
    }

    // MARK: - Áudio de Fundo da Home
    private func iniciarAudioHome() {
        guard let url = Bundle.main.url(forResource: "so_o_poder_de_deus", withExtension: "mp3") else {
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            homeAudioPlayer = try AVAudioPlayer(contentsOf: url)
            homeAudioPlayer?.numberOfLoops = -1
            homeAudioPlayer?.prepareToPlay()
            homeAudioPlayer?.play()
        } catch {
            print("Erro ao iniciar áudio de fundo: \(error.localizedDescription)")
        }
    }

    private func pausarAudioHome() {
        if let player = homeAudioPlayer, player.isPlaying {
            player.pause()
        }
    }

    private func retomarAudioHome() {
        if let player = homeAudioPlayer, !player.isPlaying {
            player.play()
        }
    }

    // MARK: - Navegação para o Player
    private func abrirPlayer(para song: Song, index: Int) {
        pausarAudioHome()

        let playerVC = ExecutaVideoAtividade()
        playerVC.currentSong = song
        playerVC.currentIndex = index
        playerVC.playlist = playlist
        playerVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        present(playerVC, animated: true)
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension HomeAtividade: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlist.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SongCell.identifier, for: indexPath) as? SongCell else {
            return UICollectionViewCell()
        }
        
        let song = playlist[indexPath.item]
        cell.configure(with: song)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let song = playlist[indexPath.item]
        abrirPlayer(para: song, index: indexPath.item)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 16) / 2
        return CGSize(width: width, height: width * 0.75)
    }
}
