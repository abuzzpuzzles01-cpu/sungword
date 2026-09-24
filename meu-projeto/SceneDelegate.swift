// SceneDelegate.swift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene, 
        willConnectTo session: UISceneSession, 
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // 1. Confirma que a cena é do tipo UIWindowScene
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // 2. Cria a UIWindow informando explicitamente a windowScene
        let window = UIWindow(windowScene: windowScene)
        
        // 3. Define a cor de fundo do contêiner principal para evitar transparência preta
        window.backgroundColor = .systemBackground

        // 4. Instancia o fluxo principal
        let homeVC = HomeAtividade()
        let navController = UINavigationController(rootViewController: homeVC)
        navController.isNavigationBarHidden = true
        
        // 5. Vincula a Controller e torna a janela visível na tela
        window.rootViewController = navController
        self.window = window
        window.makeKeyAndVisible()
    }
}
