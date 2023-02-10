import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//        let rootViewController = TableViewController()
//        window = UIWindow(windowScene: windowScene)
//        window?.rootViewController = rootViewController
//        window?.makeKeyAndVisible()

        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        let modalViewController = ModalViewController()
        let rootViewController = UINavigationController()
        let backgroundImage = UIImage(named: "Background")!
        rootViewController.view = UIImageView(image: backgroundImage)
        modalViewController.modalPresentationStyle = .overCurrentContext
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        rootViewController.present(modalViewController, animated: true)
    }
}
