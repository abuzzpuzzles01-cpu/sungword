// SobreAtividade.swift
import UIKit

class SobreAtividade: UIViewController {

    // MARK: - UI Components
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        if let image = UIImage(named: "bg_sobre") {
            imageView.image = image
        }
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var btVoltar: UIButton = {
        let button = UIButton(type: .custom)
        if let image = UIImage(named: "bt_voltar") {
            button.setImage(image, for: .normal)
        } else {
            button.setTitle("Voltar", for: .normal)
            button.setTitleColor(.white, for: .normal)
        }
        button.addTarget(self, action: #selector(btVoltarTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .black
        
        // Adiciona subviews
        view.addSubview(backgroundImageView)
        view.addSubview(btVoltar)
        
        // Garante que o fundo fique na camada traseira
        view.sendSubviewToBack(backgroundImageView)

        // Constraints de layout
        NSLayoutConstraint.activate([
            // Fundo ocupa 100% da tela
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Botão Voltar no canto superior esquerdo (considerando Safe Area)
            btVoltar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            btVoltar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            btVoltar.widthAnchor.constraint(equalToConstant: 44),
            btVoltar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Actions
    @objc private func btVoltarTapped() {
        // Se estiver em um NavigationController, faz o pop; caso contrário, dismiss
        if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}
