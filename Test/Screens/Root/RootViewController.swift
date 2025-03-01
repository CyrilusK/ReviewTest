import UIKit

final class RootViewController: UIViewController {

    private lazy var rootView = RootView(onTapReviews: { [weak self] in
        self?.openReviews() })

    override func loadView() {
        view = rootView
    }
}

// MARK: - Private

private extension RootViewController {

    func openReviews() {
        let factory = ReviewsScreenFactory()
        let controller = factory.makeReviewsController()
        navigationController?.pushViewController(controller, animated: true)
    }
}
