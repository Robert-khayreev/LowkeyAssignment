import Foundation

public protocol Request {
    var method: HTTPMethod { get }
    var path: String { get }
    var headers: [String: String] { get }
    var urlParameters: [String: String]? { get }
}

public enum HTTPMethod: String {
    case get = "GET"
}

public class RequestPerformer {
    
    public var host: URL
    
    public init(host: URL) {
        self.host = host
    }
    
    @discardableResult
    public func performRequest(request: Request) async throws -> Data {
        let endpoint = host
            .appendingPathComponent(request.path)
            .appending(queryItems: request.urlParameters?.map { .init(name: $0.key, value: $0.value) } ?? [])
        var req = URLRequest(url: endpoint)
        req.timeoutInterval = 3
        req.httpMethod = request.method.rawValue
        req.allHTTPHeaderFields = request.headers
        let (data, _) = try await URLSession.shared.data(for: req)
        return data
    }
    
    public func performRequest<T: Decodable>(request: Request) async throws -> T {
        let data = try await performRequest(request: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
        
    }
}
