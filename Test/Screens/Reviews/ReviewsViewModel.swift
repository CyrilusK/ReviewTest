import UIKit

/// Класс, описывающий бизнес-логику экрана отзывов.
final class ReviewsViewModel: NSObject {

    /// Замыкание, вызываемое при изменении `state`.
    var onStateChange: ((State) -> Void)?

    private var state: State
    private let reviewsProvider: ReviewsProvider
    private let ratingRenderer: RatingRenderer
    private let imageLoader: ImageLoader
    private let decoder: JSONDecoder

    init(
        state: State = State(),
        reviewsProvider: ReviewsProvider = ReviewsProvider(),
        ratingRenderer: RatingRenderer = RatingRenderer(),
        imageLoader: ImageLoader = ImageLoader(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.state = state
        self.reviewsProvider = reviewsProvider
        self.ratingRenderer = ratingRenderer
        self.imageLoader = imageLoader
        self.decoder = decoder
    }

    deinit {
        print("[DEBUG] \(Self.self) deinit")
    }
}

// MARK: - Internal

extension ReviewsViewModel {

    typealias State = ReviewsViewModelState

    /// Метод получения отзывов.
    func getReviews() {
        guard state.shouldLoad else { return }
        state.shouldLoad = false
        if state.items.isEmpty && !state.isRefreshing {
            state.isLoading = true
            onStateChange?(state)
        }
        reviewsProvider.getReviews(offset: state.offset) { [weak self] result in
            self?.gotReviews(result)
        }
    }

    func refreshReviews() {
        state.items.removeAll()
        state.offset = 0
        state.shouldLoad = true
        state.isRefreshing = true
        onStateChange?(state)
        getReviews()
    }
}

// MARK: - Private

private extension ReviewsViewModel {

    /// Метод обработки получения отзывов.
    func gotReviews(_ result: ReviewsProvider.GetReviewsResult) {
        do {
            let data = try result.get()
            let reviews = try decoder.decode(Reviews.self, from: data)
            state.items += reviews.items.map(makeReviewItem)
            state.offset += state.limit
            state.shouldLoad = state.offset < reviews.count
            
            if state.offset >= reviews.count {
                let totalCountReviewsConfig = makeTotalCountReviewsItem(reviews.count)
                state.items.append(totalCountReviewsConfig)
            }
        } catch {
            state.shouldLoad = true
            state.isLoading = false
        }
        state.isLoading = false
        state.isRefreshing = false
        onStateChange?(state)
    }

    /// Метод, вызываемый при нажатии на кнопку "Показать полностью...".
    /// Снимает ограничение на количество строк текста отзыва (раскрывает текст).
    func showMoreReview(with id: UUID) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem
        else { return }
        item.maxLines = .zero
        state.items[index] = item
        onStateChange?(state)
    }

}

// MARK: - Items

private extension ReviewsViewModel {

    typealias ReviewItem = ReviewCellConfig

    func makeReviewItem(_ review: Review) -> ReviewItem {
        let avatarImage = UIImage(named: "l5w5aIHioYc") ?? UIImage()
        let userName = "\(review.first_name) \(review.last_name)".attributed(font: .username)
        let ratingImage = ratingRenderer.ratingImage(review.rating)
        let reviewText = review.text.attributed(font: .text)
        let created = review.created.attributed(font: .created, color: .created)
        
        var item = ReviewItem(
            avatarImage: avatarImage,
            userName: userName,
            ratingImage: ratingImage,
            reviewText: reviewText,
            created: created,
            photos: [],
            onTapShowMore: { [weak self] id in
                self?.showMoreReview(with: id)
            }
        )
        
        imageLoader.loadImages(from: review.photo_urls) { [weak self] images in
            guard let self else { return }
            item.photos = images
            if let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == item.id }) {
                state.items[index] = item
                onStateChange?(state)
            }
        }
        return item
    }

    func makeTotalCountReviewsItem(_ count: Int) -> TotalCountReviewsCellConfig {
        let countText = "\(count) отзывов ".attributed(font: .reviewCount, color: .reviewCount)
        let config = TotalCountReviewsCellConfig(totalText: countText)
        return config
    }
}

// MARK: - UITableViewDataSource

extension ReviewsViewModel: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        state.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let config = state.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: config.reuseId, for: indexPath)
        config.update(cell: cell)
        return cell
    }

}

// MARK: - UITableViewDelegate

extension ReviewsViewModel: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        state.items[indexPath.row].height(with: tableView.bounds.size)
    }

    /// Метод дозапрашивает отзывы, если до конца списка отзывов осталось два с половиной экрана по высоте.
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(scrollView: scrollView, targetOffsetY: targetContentOffset.pointee.y) {
            getReviews()
        }
    }

    private func shouldLoadNextPage(
        scrollView: UIScrollView,
        targetOffsetY: CGFloat,
        screensToLoadNextPage: Double = 2.5
    ) -> Bool {
        let viewHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        return remainingDistance <= triggerDistance
    }
}
