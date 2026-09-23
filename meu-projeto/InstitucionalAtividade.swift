import UIKit

class InstitucionalAtividade: UIViewController {

    // MARK: - UI Components
    private let bgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "bg_institucional")
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

    private let lblTitulo: UILabel = {
        let label = UILabel()
        label.text = "QUEM SOMOS?"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let lblTextoInstitucional: UILabel = {
        let label = UILabel()
        label.text = "Olá, somos o 3 Palavrinhas! Um canal divertido e interessado em exaltar e declarar o amor de Deus. Venha fazer parte da nossa turma! Somos uma turminha dedicada em ensinar, divertir e unir gerações por meio da música cristã. Focado especialmente nos pais e nas crianças de 0 a 7 anos de idade, o projeto 3 Palavrinhas nasceu para modernizar e eternizar as canções que fazem parte do universo infantil dos cristãos brasileiros. Pensando em fazer mais do que apenas distrair a garotada, nossas músicas falam do amor de Deus e passam mensagens com valores cristãos. Nossos vídeos animados também contêm legendas para ajudar na alfabetização das crianças."
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        initAnalytics()
    }

    // MARK: - Setup UI & Constraints
    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(bgImageView)
        view.addSubview(btVoltar)
        view.addSubview(lblTitulo)
        view.addSubview(lblTextoInstitucional)

        NSLayoutConstraint.activate([
            bgImageView.topAnchor.constraint(equalTo: view.topAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bgImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            btVoltar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            btVoltar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            btVoltar.widthAnchor.constraint(equalToConstant: 44),
            btVoltar.heightAnchor.constraint(equalToConstant: 44),

            lblTitulo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            lblTitulo.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            lblTitulo.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            lblTextoInstitucional.topAnchor.constraint(equalTo: lblTitulo.bottomAnchor, constant: 16),
            lblTextoInstitucional.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            lblTextoInstitucional.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func setupActions() {
        btVoltar.addTarget(self, action: #selector(closeWindow), for: .touchUpInside)
    }

    // MARK: - Analytics Initialization
    private func initAnalytics() {
        print("Screen Name: /Sobre/institucional")
    }

    // MARK: - Actions / Navigation

    /// O bt_voltar do Institucional volta para a SobreAtividade
    @objc public func closeWindow() {
        if let nav = navigationController {
            if let sobreVC = nav.viewControllers.first(where: { $0 is SobreAtividade }) {
                nav.popToViewController(sobreVC, animated: true)
            } else {
                nav.popViewController(animated: true)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}
