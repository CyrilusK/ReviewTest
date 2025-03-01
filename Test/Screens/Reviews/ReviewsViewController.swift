import UIKit

final class ReviewsViewController: UIViewController {

    private lazy var reviewsView = makeReviewsView()
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let viewModel: ReviewsViewModel

    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = reviewsView
        title = "Отзывы"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        setupViewModel()
        viewModel.getReviews()
        setupRefreshControl()
    }
    
    deinit {
        print("[DEBUG] \(Self.self) deinit")
    }
}

// MARK: - Private

private extension ReviewsViewController {

    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        reviewsView.tableView.delegate = viewModel
        reviewsView.tableView.dataSource = viewModel
        reviewsView.tableView.refreshControl = refreshControl
        return reviewsView
    }
    
    func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        reviewsView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: reviewsView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: reviewsView.centerYAnchor)
        ])
    }

    func setupViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            state.isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
            if !state.isRefreshing {
                reviewsView.tableView.refreshControl?.endRefreshing()
            }
            reviewsView.tableView.reloadData()
        }
    }
    
    func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func refresh() {
        viewModel.refreshReviews()
    }
}
