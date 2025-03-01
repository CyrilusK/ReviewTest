//
//  ImageLoader.swift
//  Test
//
//  Created by Cyril Kardash on 01.03.2025.
//

import UIKit

final class ImageLoader {
    private let cache = NSCache<NSString, UIImage>()

    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                completion(nil)
                return
            }
            self.cache.setObject(image, forKey: urlString as NSString)
            completion(image)
            
        }.resume()
    }

    func loadImages(from urls: [String], completion: @escaping ([UIImage]) -> Void) {
        let group = DispatchGroup()
        var images = [UIImage?](repeating: nil, count: urls.count)
        
        for (index, urlString) in urls.enumerated() {
            group.enter()
            self.loadImage(from: urlString) { image in
                images[index] = image
                DispatchQueue.main.async {
                    completion(images.compactMap { $0 })
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(images.compactMap { $0 })
        }
    }
}


