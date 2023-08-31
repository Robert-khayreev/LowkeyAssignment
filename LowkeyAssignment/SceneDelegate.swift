import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var presenter: RootPresenter?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        let router = RootRouter(window: window)
        let presenter = RootPresenterImpl(router: router)
        self.presenter = presenter
        self.presenter?.didLaunch()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }

}
