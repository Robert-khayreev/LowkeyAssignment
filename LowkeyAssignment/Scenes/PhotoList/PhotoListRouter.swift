import UIKit

@MainActor
protocol PhotoListRouter {
    func routeToPhoto(photo: PexelsPhotoResponse)
}

@MainActor
class PhotoListRouterImpl: PhotoListRouter {
    
    weak var photoListVC: PhotoListViewControllerImpl?
    init(photoListVC: PhotoListViewControllerImpl) {
        self.photoListVC = photoListVC
    }
    
    func routeToPhoto(photo: PexelsPhotoResponse) {
        let photoVC = createPhotoVC(photo: photo)
        photoListVC?.present(photoVC, animated: true)
    }
    
    private func createPhotoVC(photo: PexelsPhotoResponse) -> UIViewController {
        let vc = PhotoViewControllerImpl()
        let presenter = PhotoPresenterImpl(photo: photo)
        vc.presenter = presenter
        presenter.view = vc
        return UINavigationController(rootViewController: vc)
    }
    
}
