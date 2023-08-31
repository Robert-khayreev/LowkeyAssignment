import Foundation

@MainActor
protocol PhotoListPresenter: AnyObject {
    func didLoad() async throws
    func didTapOnCell(id: Int)
    func didPullToRefresh() async throws
    func didScrollToNextPage() async throws
}

@MainActor
class PhotoListPresenterImpl: PhotoListPresenter {
    
    weak var view: PhotoListView?
    private let service: PhotoListService
    private let router: PhotoListRouter
    private var currentPage = 1
    private let perPage = 30
    private var currentPhotos: [PexelsPhotoResponse] = []
    
    init(
        service: PhotoListService,
        router: PhotoListRouter
    ) {
        self.service = service
        self.router = router
    }
    
    func didLoad() async throws {
        currentPage = 1
        let response = try await service.getPhotos(page: currentPage, perPage: perPage)
        currentPhotos.append(contentsOf: response.photos)
        let photos = response.photos.map { $0.converted }
        view?.displayPhotos(photos: photos)
    }
    
    func didTapOnCell(id: Int) {
        guard let photo = currentPhotos.first(where: { $0.id == id }) else { return }
        router.routeToPhoto(photo: photo)
    }
    
    func didPullToRefresh() async throws {
        currentPage = 1
        let response = try await service.getPhotos(page: currentPage, perPage: perPage)
        currentPhotos = response.photos
        let photos = response.photos.map { $0.converted }
        view?.displayPhotos(photos: photos)
    }
    
    func didScrollToNextPage() async throws {
        currentPage += 1
        let response = try await service.getPhotos(page: currentPage, perPage: perPage)
        currentPhotos.append(contentsOf: response.photos)
        let photos = response.photos.map { $0.converted }
        view?.addPhotos(photos: photos)
    }
    
}

private extension PexelsPhotoResponse {
    
    var converted: DisplayedPhotoListItem {
        .init(
            id: id,
            name: photographer,
            preview: src.medium
        )
    }
    
}
