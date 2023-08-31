import UIKit

@MainActor
protocol BaseVC: UIViewController {
    var activityIndicator: UIActivityIndicatorView? { get set }
}

@MainActor
extension BaseVC {

    func performAsyncTask(
        showsLoader: Bool = false,
        task: @escaping @Sendable () async throws -> Void
    ) {
        Task {
            do {
                if showsLoader { showLoading() }
                try await task()
                if showsLoader { hideLoading() }
            } catch {
                showError(error: error)
            }
        }
        
    }
    
    func showError(error: Error) {
        let alertController = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    func configureLoading() {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.activityIndicator = activityIndicator
    }
    
    func showLoading() {
        activityIndicator?.startAnimating()
    }
    
    func hideLoading() {
        activityIndicator?.stopAnimating()
    }
    
}
