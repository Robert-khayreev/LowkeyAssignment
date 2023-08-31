import Foundation

@MainActor
protocol RootPresenter {
    func didLaunch()
}

@MainActor
class RootPresenterImpl: RootPresenter {
    let router: RootRouter
    
    init(router: RootRouter) {
        self.router = router
    }
    
    func didLaunch() {
        URLCache.shared = URLCache(memoryCapacity: 512_000_000, diskCapacity: 10_000_000_000)
        router.routeToRoot()   
    }
}
