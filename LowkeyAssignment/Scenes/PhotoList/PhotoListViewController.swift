import UIKit

struct DisplayedPhotoListItem {
    let id: Int
    let name: String
    let preview: URL
}

protocol PhotoListView: AnyObject {
    func displayPhotos(photos: [DisplayedPhotoListItem])
    func addPhotos(photos: [DisplayedPhotoListItem])
}

class PhotoListViewControllerImpl: UIViewController, BaseVC, PhotoListView {
    
    private enum Consts {
        static let edgeOffset: CGFloat = 16
        static let cellHeight: CGFloat = 208
        static let lineSpacing: CGFloat = 8
        static let interItemSpacing: CGFloat = 8
        static let pagingThreshold: CGFloat = 128
        static let cellsPerRow: CGFloat = 3
    }
    
    var presenter: PhotoListPresenter?
    var activityIndicator: UIActivityIndicatorView?
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    private var cellData: [DisplayedPhotoListItem] = []
    private var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Curated Photos"
        setupCollectionView()
        configureLoading()
        isLoading = true
        performAsyncTask(showsLoader: true) {
            try await self.presenter?.didLoad()
        }
        
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.backgroundColor = .systemGroupedBackground
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        collectionView.collectionViewLayout = layout
        collectionView.register(PhotoListCell.self, forCellWithReuseIdentifier: "PhotoListCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(pulledRefresh(sender:)), for: .valueChanged)
        collectionView.addSubview(refresh)
    }
    
    func displayPhotos(photos: [DisplayedPhotoListItem]) {
        cellData = photos
        collectionView.reloadData()
        isLoading = false
    }
    
    func addPhotos(photos: [DisplayedPhotoListItem]) {
        guard !photos.isEmpty else { return }
        let indicesToReload = cellData.count...cellData.count + photos.count - 1
        cellData.append(contentsOf: photos)
        collectionView.insertItems(at: indicesToReload.map { IndexPath(row: $0, section: 0) })
        isLoading = false
    }
    
    @objc func pulledRefresh(sender: UIRefreshControl) {
        performAsyncTask { [weak self] in
            try await self?.presenter?.didPullToRefresh()
            await sender.endRefreshing()
        }
    }
}

extension PhotoListViewControllerImpl: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        .init(
            top: Consts.edgeOffset,
            left: Consts.edgeOffset,
            bottom: Consts.edgeOffset,
            right: Consts.edgeOffset
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = (collectionView.bounds.width - (Consts.cellsPerRow - 1) * Consts.interItemSpacing - Consts.edgeOffset * 2) / Consts.cellsPerRow
        return CGSize(
            width: floor(width),
            height: Consts.cellHeight
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        Consts.lineSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        Consts.interItemSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        cellData.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoListCell", for: indexPath) as! PhotoListCell
        cell.label.text = cellData[indexPath.item].name
        cell.imageView.setImage(url: cellData[indexPath.item].preview)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter?.didTapOnCell(id: cellData[indexPath.item].id)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomOffset = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.bounds.height
        if bottomOffset < Consts.pagingThreshold && !isLoading {
            isLoading = true
            performAsyncTask { [weak self] in
                try await self?.presenter?.didScrollToNextPage()
            }
        }
    }
    
}
