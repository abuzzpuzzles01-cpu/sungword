// HomeAtividade.swift
import UIKit
import AVFoundation

// MARK: - Protocolo Delegate
protocol HomeAtividadeDelegate: AnyObject {
    func loadVideo(content: Song, position: Int)
    func startDownload(pos: Int, content: Song)
}

// MARK: - Classe Principal (Similar à HomeActivity em Java/Android)
class HomeAtividade: UIViewController, HomeAtividadeDelegate {

    // MARK: - Audio Player (AVAudioPlayer)
    // Gerencia a reprodução do áudio de fundo.
    private var audioPlayer: AVAudioPlayer?

    // MARK: - UI Components
    // Definição dos componentes da interface (ex: botões, imagens de fundo).
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        if let image = UIImage(named: "bg_home") {
            imageView.image = image
        } else {
            imageView.backgroundColor = .systemBlue // Fallback caso a imagem não exista
        }
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var btSobre: UIButton = {
        let button = UIButton(type: .custom)
        if let image = UIImage(named: "bt_sobre") {
            button.setImage(image, for: .normal)
        } else {
            button.setTitle("Sobre", for: .normal)
            button.setTitleColor(.white, for: .normal)
        }
        button.addTarget(self, action: #selector(sobreButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Properties (Variáveis de Estado)
    private var contents: [Song] = []
    private var products: [Album] = []
    private var selectedAlbumIndex: Int = 0

    // MARK: - Lifecycle (Ciclo de Vida - Similar ao onCreate/onStart/onStop do Android)

    // viewDidLoad: Chamado uma vez quando a view é carregada na memória (Similar ao onCreate).
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        playBackgroundAudio() // Inicia o som ao carregar a tela
    }

    // viewWillAppear: Chamado sempre que a view está prestes a ficar visível (Similar ao onStart).
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Resume o som ao voltar para a Home (vinda de outra tela que pausou o som)
        if let player = audioPlayer, !player.isPlaying {
            player.play()
        }
    }

    // viewWillDisappear: Chamado quando a view está prestes a ser removida da tela (Similar ao onStop).
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pausa o som para não sobrepor com vídeos ou sons de outras telas
        audioPlayer?.pause()
    }

    // Configuração para ocultar a barra de status (tela cheia).
    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Sound Function (Função de Áudio)
    // Configura e reproduz o arquivo o_sabao.mp3 em loop.
    private func playBackgroundAudio() {
        // 1. Localiza o arquivo o_sabao.mp3 no Bundle principal do aplicativo.
        guard let url = Bundle.main.url(forResource: "o_sabao", withExtension: "mp3") else {
            print("❌ Erro: Arquivo o_sabao.mp3 não encontrado no Bundle do aplicativo.")
            return
        }

        do {
            // 2. Configura a sessão de áudio do iOS para reprodução (playback).
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            // 3. Inicializa o AVAudioPlayer com a URL do arquivo.
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            
            // 4. Define o número de loops. -1 significa loop infinito.
            audioPlayer?.numberOfLoops = -1
            
            // 5. Prepara o player e inicia a reprodução.
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            print("🎵 Reproduzindo o_sabao.mp3 com sucesso em loop contínuo!")
        } catch {
            print("❌ Erro ao inicializar ou reproduzir o player de áudio: \(error.localizedDescription)")
        }
    }

    // MARK: - Setup UI (Configuração da Interface)
    private func setupUI() {
        view.backgroundColor = .black

        // Adiciona os componentes na hierarquia de views.
        view.addSubview(backgroundImageView)
        view.addSubview(btSobre)

        // Garante que a imagem de fundo fique atrás dos botões.
        view.sendSubviewToBack(backgroundImageView)

        // Define as Constraints (Auto Layout) para posicionar os elementos.
        NSLayoutConstraint.activate([
            // Fundo ocupa 100% da tela
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Botão Sobre (Canto superior esquerdo, respeitando a Safe Area)
            btSobre.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            btSobre.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            btSobre.widthAnchor.constraint(equalToConstant: 44),
            btSobre.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Data Handling (Manipulação de Dados)
    private func loadData() {
        // Carrega a lista de álbuns (Mocada ou vinda de uma API).
        self.products = getProducts()
        
        if !products.isEmpty {
            // Correção do erro opcional: Usa ?? [] para garantir que contents receba um array vazio caso songs seja nil.
            self.contents = products[0].songs ?? []
        }
    }

    // MARK: - Actions (Ações de Botões)
    @objc private func sobreButtonTapped() {
        // Linha 279: Navegação para a SobreAtividade.
        // Certifique-se de que o arquivo SobreAtividade.swift existe e está compilado.
        let sobreVC = SobreAtividade()
        if let nav = navigationController {
            // Se houver um NavigationController, faz o push da nova tela.
            nav.pushViewController(sobreVC, animated: true)
        } else {
            // Caso contrário, apresenta a tela de forma modal (full screen).
            sobreVC.modalPresentationStyle = .fullScreen
            present(sobreVC, animated: true, completion: nil)
        }
    }

    // MARK: - HomeAtividadeDelegate Protocol Implementation
    // Implementação dos métodos do protocolo definido no início do arquivo.

    func loadVideo(content: Song, position: Int) {
        guard let downloadPath = content.downloadUrl else { return }
        
        // Pausa o som de fundo explicitamente antes de iniciar o player de vídeo.
        audioPlayer?.pause()

        let executaVC = ExecutaVideoAtividade()
        // Passa os dados necessários para a controller de vídeo.
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

    func startDownload(pos: Int, content: Song) {
        // Lógica para iniciar o download do vídeo usando o VideoDownloadManager.
        // Após o sucesso do download, chamaria o loadVideo().
        print("Iniciando download do vídeo: \(content.name ?? "") na posição \(pos)")
    }

    // MARK: - Mock Products Data (Dados de Exemplo)
    // Função auxiliar para retornar uma lista de álbuns vazia ou mocada para teste.
    private func getProducts() -> [Album] {
        // Retorne sua lista real de álbuns aqui.
        return []
    }
}
