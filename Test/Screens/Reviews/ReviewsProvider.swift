import Foundation

/// Класс для загрузки отзывов.
final class ReviewsProvider {

    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    deinit {
        print("[DEBUG] \(Self.self) deinit")
    }
}

// MARK: - Internal

extension ReviewsProvider {

    typealias GetReviewsResult = Result<Data, GetReviewsError>

    enum GetReviewsError: Error {

        case badURL
        case badData(Error)

    }

    func getReviews(offset: Int = 0, completion: @escaping (GetReviewsResult) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let url = self.bundle.url(forResource: "getReviews.response", withExtension: "json") else {
                self.completeOnMainThread(completion, result: .failure(.badURL))
                return
            }

            // Симулируем сетевой запрос - не менять
            usleep(.random(in: 100_000...1_000_000))

            do {
                let data = try Data(contentsOf: url)
                self.completeOnMainThread(completion, result: .success(data))
            } catch {
                self.completeOnMainThread(completion, result: .failure(.badData(error)))
            }
        }
    }

    private func completeOnMainThread(_ completion: @escaping (GetReviewsResult) -> Void, result: GetReviewsResult) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
}
