import Foundation

enum PexelsRequest: Request {
    case curatedPhotos(page: Int, perPage: Int)
    
    var method: HTTPMethod {
        switch self {
            case .curatedPhotos:
                return .get
        }
    }
    
    var path: String {
        switch self {
            case .curatedPhotos:
                return  "v1/curated"
        }
    }
    
    var headers: [String : String] {
        ["Authorization": "8x7LvSL8GynwgmIO5YmOyNcLdl0hqgmyAXBDEzvN8pvEnuIAB2snstq7"]
    }
    
    var urlParameters: [String : String]? {
        switch self {
            case .curatedPhotos(let page, let perPage):
                return [
                    "page": page.description,
                    "per_page": perPage.description
                ]

        }
    }
}

struct PexelsCuratedPhotosResponse: Decodable {
    let photos: [PexelsPhotoResponse]
    let page: Int
    let perPage: Int
    let totalResults: Int
    let prevPage: URL?
    let nextPage: URL?
}

struct PexelsPhotoResponse: Decodable {
    let id: Int
    let width: Int
    let height: Int
    let url: URL
    let photographer: String
    let photographerUrl: URL?
    let photographerId: Int?
    let avgColor: String
    let src: PexelsPhotoSrcResponse
    let alt: String
}

struct PexelsPhotoSrcResponse: Decodable {
    let original: URL
    let large: URL
    let large2x: URL
    let medium: URL
    let small: URL
    let portrait: URL
    let landscape: URL
    let tiny: URL
}
