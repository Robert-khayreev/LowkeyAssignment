import Foundation

protocol PhotoListService: AnyObject {
    func getPhotos(page: Int, perPage: Int) async throws -> PexelsCuratedPhotosResponse
}

class PhotoListServiceImpl: PhotoListService {
    private let requestPerformer: RequestPerformer
    
    init(requestPerformer: RequestPerformer) {
        self.requestPerformer = requestPerformer
    }
    
    func getPhotos(page: Int, perPage: Int) async throws -> PexelsCuratedPhotosResponse {
        try await requestPerformer.performRequest(
            request: PexelsRequest.curatedPhotos(
                page: page,
                perPage: perPage
            )
        )
    }
}
