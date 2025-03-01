/// Модель отзыва.
struct Review: Decodable {

    /// Имя комментатора
    let first_name: String
    /// Фамилия комментатора
    let last_name: String
    /// Количесто звезд
    let rating: Int
    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
    /// Массив ссылок на фото
    let photo_urls: [String]
}
