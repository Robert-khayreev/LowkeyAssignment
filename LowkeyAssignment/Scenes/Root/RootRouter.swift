import UIKit

@MainActor
class RootRouter {
    
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func routeToRoot() {
        let vc = createPhotoListVC()
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
    
    private func createPhotoListVC() -> UIViewController {
        let vc = PhotoListViewControllerImpl()
        let host = URL(string: "https://api.pexels.com")!
        let requestPerformer = RequestPerformer(host: host)
        let service = PhotoListServiceImpl(requestPerformer: requestPerformer)
        let router = PhotoListRouterImpl(photoListVC: vc)
        let presenter = PhotoListPresenterImpl(
            service: service,
            router: router
        )
        vc.presenter = presenter
        presenter.view = vc
        return UINavigationController(rootViewController: vc)
    }
    
}
