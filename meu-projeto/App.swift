import SwiftUI

struct MeuProjetoApp: App {
    var body: some Scene {
        WindowGroup {
            HomeAtividadeContainer()
                .ignoresSafeArea()
        }
    }
}

// Wrapper para converter a UIViewController em View do SwiftUI
struct HomeAtividadeContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let homeVC = HomeAtividade()
        let navController = UINavigationController(rootViewController: homeVC)
        navController.isNavigationBarHidden = true
        return navController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Sem atualização necessária
    }
}
