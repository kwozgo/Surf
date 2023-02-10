import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let modalPresenter = ModalPresenter(dataSource: TagDatabase.collection)
        let modalViewController = ModalViewController()
        modalViewController.presenter = modalPresenter
        modalPresenter.view = modalViewController
        window?.rootViewController = modalViewController
        window?.makeKeyAndVisible()
    }
}
