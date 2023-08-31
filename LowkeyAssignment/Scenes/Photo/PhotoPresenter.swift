import Foundation

@MainActor
protocol PhotoPresenter: AnyObject {
    func didLoad()
}

@MainActor
class PhotoPresenterImpl: PhotoPresenter {
    weak var view: PhotoView?
    private let photo: PexelsPhotoResponse
    
    init(photo: PexelsPhotoResponse) {
        self.photo = photo
    }
    
    func didLoad() {
        view?.displayPhoto(
            url: photo.src.original,
            title: photo.photographer
        )
    }
}
