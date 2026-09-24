// SceneDelegate.swift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene, 
        willConnectTo session: UISceneSession, 
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { 
            print("❌ Erro: Scene não é uma UIWindowScene")
            return 
        }

        // 1. Instancia a janela usando diretamente os limites da tela (bounds)
        let window = UIWindow(windowScene: windowScene)
        window.frame = windowScene.coordinateSpace.bounds
        
        // 2. Cor de fundo temporária para garantir que a janela está visível (Amarelo)
        window.backgroundColor = .systemYellow

        // 3. Define a Controller Principal
        let homeVC = HomeAtividade()
        let navController = UINavigationController(rootViewController: homeVC)
        navController.isNavigationBarHidden = true

        window.rootViewController = navController
        
        // 4. Exibe e ativa a janela na tela do dispositivo
        self.window = window
        window.makeKeyAndVisible()
        
        print("✅ SceneDelegate: UIWindow montada e tornada visível!")
    }
}
