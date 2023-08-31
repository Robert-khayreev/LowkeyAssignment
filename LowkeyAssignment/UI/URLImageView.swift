import UIKit

class URLImageView: UIImageView {
    
    let cache = URLCache.shared
    let session = URLSession.shared

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)
        indicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        return indicator
    }()
    
    func setImage(
        url: URL,
        showsLoading: Bool = false,
        useCache: Bool = true
    ) {
        if showsLoading { showLoading() }
        Task {
            do {
                let data = try await data(from: url, useCache: useCache)
                let image = UIImage(data: data)
                await MainActor.run {
                    if showsLoading { hideLoading() }
                    self.alpha = 0
                    self.image = image
                    UIView.animate(withDuration: 0.2) {
                        self.alpha = 1
                    }
                }
            } catch {
                if showsLoading { hideLoading() }
                showError()
            }
        }
        
    }
    
    private func showError() { }
    
    private func showLoading() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoading() {
        activityIndicator.stopAnimating()
    }
    
    private func data(from url: URL, useCache: Bool) async throws -> Data {
        let data: Data
        let response: URLResponse
        let req = URLRequest(url: url)
        if useCache, let cached = cache.cachedResponse(for: req) {
            data = cached.data
            response = cached.response
        } else {
            (data, response) = try await session.data(for: req)
            if useCache {
                let cachedData = CachedURLResponse(response: response, data: data)
                cache.storeCachedResponse(
                    cachedData,
                    for: req
                )
            }
        }
        return data
    }
    
}
