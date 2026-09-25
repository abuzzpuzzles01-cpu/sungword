import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // 1. Instancia a UIWindow com as dimensões exatas da UIWindowScene
        let window = UIWindow(windowScene: windowScene)
        window.frame = windowScene.coordinateSpace.bounds
        
        // 2. Define o Root View Controller (HomeAtividade)
        let homeVC = HomeAtividade()
        let navController = UINavigationController(rootViewController: homeVC)
        navController.isNavigationBarHidden = true // Esconde a barra nativa se necessário
        
        window.rootViewController = navController
        
        // 3. Torna a janela visível
        self.window = window
        window.makeKeyAndVisible()
    }
}
