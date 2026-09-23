import SwiftUI
import UIKit

// Struct que faz a ponte entre o UIKit e o SwiftUI
struct LaunchScreenView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> LaunchScreenViewController {
        return LaunchScreenViewController()
    }

    func updateUIViewController(_ uiViewController: LaunchScreenViewController, context: Context) {}
}

@main
struct MeuApp: App {
    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
        }
    }
}
