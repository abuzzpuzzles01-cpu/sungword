import UIKit

class LaunchscreenViewController: UIViewController {

    // MARK: - UI Components
    private let bgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "bg_splash")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Aguarda 2.5 segundos de Splash e navega para a HomeAtividade
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.navigateToHome()
        }
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(bgImageView)

        NSLayoutConstraint.activate([
            bgImageView.topAnchor.constraint(equalTo: view.topAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bgImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    // MARK: - Navigation
    private func navigateToHome() {
        let homeVC = HomeAtividade()
        
        if let nav = navigationController {
            // Caso esteja usando UINavigationController, substitui a pilha para impedir que o usuário volte para a Splash
            nav.setViewControllers([homeVC], animated: true)
        } else {
            // Caso seja a RootViewController da janela principal
            guard let window = view.window else { return }
            
            let navVC = UINavigationController(rootViewController: homeVC)
            navVC.isNavigationBarHidden = true // Oculta a barra nativa do iOS
            
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = navVC
            }, completion: nil)
        }
    }
}
