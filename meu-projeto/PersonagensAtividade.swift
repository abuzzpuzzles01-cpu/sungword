import UIKit

class PersonagensAtividade: UIViewController {

    // MARK: - UI Components
    private let bgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "bg_personagens")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let btVoltar: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "bt_voltar"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let btDavi: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "bt_davi"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let btMiguel: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "bt_miguel"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let btSara: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "bt_sara"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Textos Oficiais dos Personagens
    private let textDavi = "Oi, galerinha do bem! Eu sou o Davi. Eu aprendo e me divirto muito com as canções do 3 Palavrinhas. Eu adoro praticar esportes junto com os meus amigos. Também gosto muito de ajudar as pessoas e de participar da Escola Dominical na igreja. Amo aprender as lindas histórias da Palavra de Deus. Minha música preferida é “Leia a Bíblia”."

    private let textMiguel = "Olá, pessoal! Eu sou o Miguel! Curto de montão todas as músicas e vídeos do 3 Palavrinhas. Gosto muito de brincar, mas também amo ler e contar as histórias da Bíblia. Meu sonho é fazer missões! Quero anunciar o Evangelho para todas as crianças do mundo! Minha música predileta é “Missionariozinho”."

    private let textSara = "Olá! Eu sou a Sarah. Sou uma menina que tem muitos amigos e amo estar na companhia deles. Gosto muito de cantar e dançar! Na minha casa, sempre ouço as músicas e assisto aos vídeos do 3 Palavrinhas. Quero aprender todas as músicas para me tornar uma cantora! A música que eu mais gosto é “Estou Alegre”."

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        initAnalytics()
    }

    // MARK: - Setup UI & Layout
    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(bgImageView)
        view.addSubview(btVoltar)
        view.addSubview(btDavi)
        view.addSubview(btMiguel)
        view.addSubview(btSara)

        NSLayoutConstraint.activate([
            // Fundo da Tela
            bgImageView.topAnchor.constraint(equalTo: view.topAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bgImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Botão Voltar (Canto superior esquerdo)
            btVoltar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            btVoltar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            btVoltar.widthAnchor.constraint(equalToConstant: 44),
            btVoltar.heightAnchor.constraint(equalToConstant: 44),

            // Botões dos Personagens
            btDavi.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            btDavi.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            btDavi.widthAnchor.constraint(equalToConstant: 90),
            btDavi.heightAnchor.constraint(equalToConstant: 120),

            btMiguel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            btMiguel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            btMiguel.widthAnchor.constraint(equalToConstant: 90),
            btMiguel.heightAnchor.constraint(equalToConstant: 120),

            btSara.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            btSara.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            btSara.widthAnchor.constraint(equalToConstant: 90),
            btSara.heightAnchor.constraint(equalToConstant: 120)
        ])
    }

    private func setupActions() {
        btVoltar.addTarget(self, action: #selector(closeWindow), for: .touchUpInside)
        btDavi.addTarget(self, action: #selector(openFrameDavi), for: .touchUpInside)
        btMiguel.addTarget(self, action: #selector(openFrameMiguel), for: .touchUpInside)
        btSara.addTarget(self, action: #selector(openFrameSara), for: .touchUpInside)
    }

    // MARK: - Analytics Initialization
    private func initAnalytics() {
        print("Screen Name: /Sobre/personagens")
    }

    // MARK: - Character Frame Actions

    @objc public func openFrameDavi() {
        createPopupView(backgroundImageName: "frame_davi", texto: textDavi)
    }

    @objc public func openFrameSara() {
        createPopupView(backgroundImageName: "frame_sara", texto: textSara)
    }

    @objc public func openFrameMiguel() {
        createPopupView(backgroundImageName: "frame_miguel", texto: textMiguel)
    }

    /// Método acionado pelo botão btVoltar para retornar à tela SobreAtividade
    @objc public func closeWindow() {
        if let nav = navigationController {
            // Se SobreAtividade já existir na pilha do NavigationController, volta diretamente para ela
            if let sobreVC = nav.viewControllers.first(where: { String(describing: type(of: $0)).contains("SobreAtividade") }) {
                nav.popToViewController(sobreVC, animated: true)
            } else {
                nav.popViewController(animated: true)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Popup Builder (Overlay Personagem)

    public func createPopupView(backgroundImageName: String, texto: String) {
        let popupView = UIView(frame: view.bounds)
        popupView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let popupBgImageView = UIImageView(frame: popupView.bounds)
        popupBgImageView.image = UIImage(named: backgroundImageName)
        popupBgImageView.contentMode = .scaleAspectFill
        popupBgImageView.clipsToBounds = true
        popupBgImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        popupView.addSubview(popupBgImageView)

        // Label para a História do Personagem
        let txtHistoria = UILabel()
        txtHistoria.text = texto
        txtHistoria.textColor = .white
        txtHistoria.numberOfLines = 0
        txtHistoria.textAlignment = .center
        txtHistoria.translatesAutoresizingMaskIntoConstraints = false

        // Aplica a fonte personalizada se disponível, caso contrário usa a do sistema
        if let customFont = UIFont(name: "arnold_dois_um", size: 18) {
            txtHistoria.font = customFont
        } else {
            txtHistoria.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        }
        popupView.addSubview(txtHistoria)

        // Botão Fechar do Popup
        let btClose = UIButton(type: .custom)
        btClose.setImage(UIImage(named: "bt_remove_video"), for: .normal)
        btClose.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(btClose)

        // Constraints dos elementos no Popup
        NSLayoutConstraint.activate([
            btClose.topAnchor.constraint(equalTo: popupView.safeAreaLayoutGuide.topAnchor, constant: 16),
            btClose.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -16),
            btClose.widthAnchor.constraint(equalToConstant: 44),
            btClose.heightAnchor.constraint(equalToConstant: 44),

            txtHistoria.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            txtHistoria.centerYAnchor.constraint(equalTo: popupView.centerYAnchor, constant: 40),
            txtHistoria.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 40),
            txtHistoria.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -40)
        ])

        // Ação de fechar o Popup
        btClose.addAction(UIAction(handler: { _ in
            UIView.animate(withDuration: 0.25, animations: {
                popupView.alpha = 0.0
            }) { _ in
                popupView.removeFromSuperview()
            }
        }), for: .touchUpInside)

        // Adiciona à hierarquia da view com animação
        popupView.alpha = 0.0
        view.addSubview(popupView)
        UIView.animate(withDuration: 0.25) {
            popupView.alpha = 1.0
        }
    }
}
