import SwiftUI
import UIKit

@main
struct TresPalavrinhasApp: App {
    var body: some Scene {
        WindowGroup {
            HomeViewControllerRepresentable()
                .ignoresSafeArea()
        }
    }
}

// Wrapper para acoplar a HomeAtividade (UIKit) dentro do SwiftUI
struct HomeViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let homeVC = HomeAtividade()
        let navController = UINavigationController(rootViewController: homeVC)
        navController.isNavigationBarHidden = true
        return navController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Atualizações de layout se necessário
    }
}
