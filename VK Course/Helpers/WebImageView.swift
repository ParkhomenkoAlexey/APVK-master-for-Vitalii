//
//  WebImageView.swift
//  VK Course
//
//  Created by Алексей Пархоменко on 24/01/2019.
//  Copyright © 2019 Алексей Пархоменко. All rights reserved.
//

import UIKit

final class WebImageView: UIImageView {
    
    private var currentUrlString: String?
    private let urlCache = URLCache.shared
    
    func set(imageUrl: String?) {
        
        currentUrlString = imageUrl
        
        guard let imageUrl = imageUrl, let url = URL(string: imageUrl) else {
            self.image = nil
            return
        }
        
        // URLCache.shared.cachedResponse - Возвращает кэшированный ответ URL в кеше для указанного запроса URL.
        if let cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url)) {
            self.image = UIImage(data: cachedResponse.data)
            return // ???
        }
        
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: url) { [weak self] (data, response, error) in
            DispatchQueue.main.async {
                if let data = data, let response = response, error == nil {
                    self?.handleLoadedImage(data: data, response: response)
                }
            }
        }
        dataTask.resume()
    }
    
    private func handleLoadedImage(data: Data, response: URLResponse) {
        guard let responseUrl = response.url else { return }
        // CachedURLResponse - Кэшированный ответ на запрос URL.
        let cachedResponse = CachedURLResponse(response: response, data: data)
        // .storeCachedResponse - Хранит кэшированный ответ URL для указанного запроса.
        URLCache.shared.storeCachedResponse(cachedResponse, for: URLRequest(url: responseUrl))
        
        if responseUrl.absoluteString == currentUrlString {
             self.image = UIImage(data: data)
        }
    }
}
