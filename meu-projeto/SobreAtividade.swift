import UIKit

class SobreAtividade: UIViewController {

    // MARK: - Componentes de UI
    private let btVoltar: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "bt_voltar"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let btInstitucional: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "bt_institucional"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let btPersonagens: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "bt_personagens"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        initAnalytics()
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        let bgImageView = UIImageView(image: UIImage(named: "bg_sobre"))
        bgImageView.contentMode = .scaleAspectFill
        bgImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bgImageView)
        
        view.addSubview(btVoltar)
        view.addSubview(btInstitucional)
        view.addSubview(btPersonagens)

        NSLayoutConstraint.activate([
            bgImageView.topAnchor.constraint(equalTo: view.topAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bgImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            btVoltar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            btVoltar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            btVoltar.widthAnchor.constraint(equalToConstant: 44),
            btVoltar.heightAnchor.constraint(equalToConstant: 44),

            btInstitucional.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            btInstitucional.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            btInstitucional.widthAnchor.constraint(equalToConstant: 220),
            btInstitucional.heightAnchor.constraint(equalToConstant: 50),

            btPersonagens.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            btPersonagens.topAnchor.constraint(equalTo: btInstitucional.bottomAnchor, constant: 20),
            btPersonagens.widthAnchor.constraint(equalToConstant: 220),
            btPersonagens.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupActions() {
        btVoltar.addTarget(self, action: #selector(closeWindow), for: .touchUpInside)
        btInstitucional.addTarget(self, action: #selector(openInstitucional), for: .touchUpInside)
        btPersonagens.addTarget(self, action: #selector(openPersonagens), for: .touchUpInside)
    }

    // MARK: - Analytics Initialization
    private func initAnalytics() {
        print("Screen Name: /Sobre")
    }

    // MARK: - Actions / Navigation

    /// O bt_voltar do SobreAtividade volta para a HomeAtividade
    @objc public func closeWindow() {
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

    @objc public func openInstitucional() {
        let institucionalVC = InstitucionalAtividade()
        if let nav = navigationController {
            nav.pushViewController(institucionalVC, animated: true)
        } else {
            institucionalVC.modalPresentationStyle = .fullScreen
            present(institucionalVC, animated: true)
        }
    }

    @objc public func openPersonagens() {
        let personagensVC = PersonagensAtividade()
        if let nav = navigationController {
            nav.pushViewController(personagensVC, animated: true)
        } else {
            personagensVC.modalPresentationStyle = .fullScreen
            present(personagensVC, animated: true)
        }
    }
}
