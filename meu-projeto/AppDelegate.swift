// AppDelegate.swift
import UIKit
import AVFoundation

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Configuração da sessão de áudio para permitir reprodução em segundo plano/modo silencioso
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Erro ao configurar AVAudioSession no AppDelegate: \(error.localizedDescription)")
        }

        // Inicialização do Window no ciclo de vida iOS < 13 ou quando não se utiliza SceneDelegate
        let window = UIWindow(frame: UIScreen.main.bounds)
        let rootVC = HomeAtividade()
        let navController = UINavigationController(rootViewController: rootVC)
        navController.isNavigationBarHidden = true // Esconde a barra de navegação superior
        
        window.rootViewController = navController
        window.makeKeyAndVisible()
        self.window = window

        return true
    }

    // MARK: - UISceneSession Lifecycle (iOS 13+)

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
