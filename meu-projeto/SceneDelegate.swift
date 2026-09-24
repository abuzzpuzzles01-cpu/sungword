// SceneDelegate.swift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // 1. Cria a UIWindow do aplicativo manualmente
        let window = UIWindow(windowScene: windowScene)
        
        // 2. Define a HomeAtividade como a Controller raiz dentro de uma UINavigationController
        let homeVC = HomeAtividade()
        let navController = UINavigationController(rootViewController: homeVC)
        navController.isNavigationBarHidden = true
        
        // 3. Exibe a janela na tela do iPhone
        window.rootViewController = navController
        window.makeKeyAndVisible()
        self.window = window
    }
}
