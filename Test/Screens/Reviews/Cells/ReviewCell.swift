import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {

    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)

    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    /// Аватар пользователя.
    let avatarImage: UIImage
    /// Имя пользователя.
    let userName: NSAttributedString
    /// Рейтинг отзыва.
    let ratingImage: UIImage
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Максимальное отображаемое количество строк текста. По умолчанию 3.
    var maxLines = 3
    /// Время создания отзыва.
    let created: NSAttributedString
    /// Массив фото
    var photos: [UIImage]
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: (UUID) -> Void

    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()

}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
        cell.avatarImageView.image = avatarImage
        cell.nameLabel.attributedText = userName
        cell.ratingImageView.image = ratingImage
        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = maxLines
        cell.createdLabel.attributedText = created
        cell.configurePhotos(photos)
        cell.config = self
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }

}

// MARK: - Private

private extension ReviewCellConfig {

    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)

}

// MARK: - Cell

final class ReviewCell: UITableViewCell {

    fileprivate var config: Config?

    fileprivate let avatarImageView = UIImageView()
    fileprivate let nameLabel = UILabel()
    fileprivate let ratingImageView = UIImageView()
    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()
    fileprivate let photoStackView = UIStackView()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        avatarImageView.frame = layout.frameAvatar
        nameLabel.frame = layout.frameNameLabel
        ratingImageView.frame = layout.frameRatingImage
        reviewTextLabel.frame = layout.frameReviewTextLabel
        createdLabel.frame = layout.frameCreatedLabel
        showMoreButton.frame = layout.frameShowMoreButton
        photoStackView.frame = layout.framePhotoStackView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        nameLabel.attributedText = nil
        ratingImageView.image = nil
        reviewTextLabel.attributedText = nil
        createdLabel.attributedText = nil
        photoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    deinit {
        print("[DEBUG] \(Self.self) deinit")
    }
}

// MARK: - Private

private extension ReviewCell {

    func setupCell() {
        setupAvatarImageView()
        setupNameLabel()
        setupRatingImageView()
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
        setupPhotoStackView()
    }
    
    func setupPhotoStackView() {
        contentView.addSubview(photoStackView)
        photoStackView.axis = .horizontal
        photoStackView.spacing = ReviewCellLayout.spacingPhotos
        photoStackView.distribution = .fillEqually
    }
    
    func configurePhotos(_ photos: [UIImage]) {
        for photo in photos {
            let imageView = UIImageView(image: photo)
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = Layout.cornerRadiusPhoto
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            photoStackView.addArrangedSubview(imageView)
        }
    }
    
    func setupAvatarImageView() {
        contentView.addSubview(avatarImageView)
        avatarImageView.layer.cornerRadius = Layout.cornerRadiusAvatar
        avatarImageView.clipsToBounds = true
    }

    func setupNameLabel() {
        contentView.addSubview(nameLabel)
    }

    func setupRatingImageView() {
        contentView.addSubview(ratingImageView)
    }

    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }

    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }

    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
        showMoreButton.addTarget(self, action: #selector(didTapShowMore), for: .touchUpInside)
    }
    
    @objc
    private func didTapShowMore() {
        guard let id = config?.id else { return }
        config?.onTapShowMore(id)
    }
}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {

    // MARK: - Размеры

    fileprivate static let sizeAvatar = CGSize(width: 36.0, height: 36.0)
    fileprivate static let cornerRadiusAvatar = 18.0
    fileprivate static let spacingPhotos = 8.0
    fileprivate static let cornerRadiusPhoto = 8.0

    private static let sizePhoto = CGSize(width: 55.0, height: 66.0)
    private static let sizeShowMoreButton = Config.showMoreText.size()

    // MARK: - Фреймы

    private(set) var frameAvatar = CGRect.zero
    private(set) var frameNameLabel = CGRect.zero
    private(set) var frameRatingImage = CGRect.zero
    private(set) var frameReviewTextLabel = CGRect.zero
    private(set) var frameShowMoreButton = CGRect.zero
    private(set) var frameCreatedLabel = CGRect.zero
    private(set) var framePhotoStackView = CGRect.zero

    // MARK: - Отступы

    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    /// Горизонтальный отступ от аватара до имени пользователя.
    private let spacingAvatarToUsername = 10.0
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let spacingUsernameToRating = 6.0
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let spacingRatingToText = 6.0
    /// Вертикальный отступ от вью рейтинга до фото.
    private let spacingRatingToPhotos = 10.0
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let spacingPhotosToText = 10.0
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let spacingReviewTextToCreated = 6.0
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let spacingShowMoreToCreated = 6.0

    // MARK: - Расчёт фреймов и высоты ячейки

    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let width = maxWidth - insets.left - insets.right - Self.sizeAvatar.width - spacingAvatarToUsername

        var maxY = insets.top
        var showShowMoreButton = false

        frameAvatar = CGRect(
            origin: CGPoint(x: insets.left, y: maxY),
            size: Self.sizeAvatar
        )
        let avatarRightX = frameAvatar.maxX + spacingAvatarToUsername
        
        frameNameLabel = CGRect(
            origin: CGPoint(x: avatarRightX, y: maxY),
            size: config.userName.boundingRect(width: width).size
        )
        maxY = frameNameLabel.maxY + spacingUsernameToRating
        
        frameRatingImage = CGRect(
            origin: CGPoint(x: avatarRightX, y: maxY),
            size: config.ratingImage.size
        )
        maxY = frameRatingImage.maxY + spacingRatingToText
        
        if !config.photos.isEmpty {
            framePhotoStackView = CGRect(x: avatarRightX, y: maxY, width: Self.sizePhoto.width * CGFloat(config.photos.count), height: Self.sizePhoto.height)
            maxY = framePhotoStackView.maxY + spacingPhotosToText
        }
        
        if !config.reviewText.isEmpty() {
            // Высота текста с текущим ограничением по количеству строк.
            let currentTextHeight = (config.reviewText.font()?.lineHeight ?? .zero) * CGFloat(config.maxLines)
            // Максимально возможная высота текста, если бы ограничения не было.
            let actualTextHeight = config.reviewText.boundingRect(width: width).size.height
            // Показываем кнопку "Показать полностью...", если максимально возможная высота текста больше текущей.
            showShowMoreButton = config.maxLines != .zero && actualTextHeight > currentTextHeight

            frameReviewTextLabel = CGRect(
                origin: CGPoint(x: avatarRightX, y: maxY),
                size: config.reviewText.boundingRect(width: width, height: currentTextHeight).size
            )
            maxY = frameReviewTextLabel.maxY + spacingReviewTextToCreated
        }

        if showShowMoreButton {
            frameShowMoreButton = CGRect(
                origin: CGPoint(x: avatarRightX, y: maxY),
                size: Self.sizeShowMoreButton
            )
            maxY = frameShowMoreButton.maxY + spacingShowMoreToCreated
        } else {
            frameShowMoreButton = .zero
        }

        frameCreatedLabel = CGRect(
            origin: CGPoint(x: avatarRightX, y: maxY),
            size: config.created.boundingRect(width: width).size
        )

        return frameCreatedLabel.maxY + insets.bottom
    }

}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout

