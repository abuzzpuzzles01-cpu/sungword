// SceneDelegate.swift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        window.frame = windowScene.coordinateSpace.bounds
        
        let homeVC = HomeAtividade()
        let navController = UINavigationController(rootViewController: homeVC)
        navController.isNavigationBarHidden = true

        window.rootViewController = navController
        self.window = window
        window.makeKeyAndVisible()
    }
}
