import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Se não usar SceneDelegate:
        if #available(iOS 13.0, *) {
            // Gerenciado pelo SceneDelegate
        } else {
            let window = UIWindow(frame: UIScreen.main.bounds)
            let homeVC = HomeAtividade()
            window.rootViewController = UINavigationController(rootViewController: homeVC)
            window.makeKeyAndVisible()
            self.window = window
        }
        
        return true
    }
}
