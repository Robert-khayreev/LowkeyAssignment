import UIKit

protocol PhotoView: AnyObject {
    func displayPhoto(url: URL, title: String)
}

class PhotoViewControllerImpl: UIViewController, PhotoView {
    
    var presenter: PhotoPresenter?
    private let imageView = URLImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        presenter?.didLoad()
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imageView.contentMode = .scaleAspectFit
    }
    
    func displayPhoto(url: URL, title: String) {
        self.title = title
        imageView.setImage(url: url, showsLoading: true)
    }
}
