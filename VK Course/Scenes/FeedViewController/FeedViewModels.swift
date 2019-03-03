//
//  FeedViewModels.swift
//  VK Course
//
//  Created by Алексей Пархоменко on 23/01/2019.
//  Copyright © 2019 Алексей Пархоменко. All rights reserved.
//

import Foundation
import UIKit

// зачем?
// Энум ленты новостей
enum Feed {
    
    struct UserViewModel: TitleViewViewModel {
        var photoUrlString: String?
    
    }
    
    // у ленты новостей есть модель новости (или поста)
    struct ViewModel {
        struct Cell: FeedCellViewModel {
            let postId: Int
            
            let iconUrlString: String
            let name: String
            let date: String
            let text: String?
            var likes: String?
            var comments: String?
            var shares: String?
            var views: String?
            var photoAttachements: [FeedCellPhotoAttachmentViewModel]
            var sizes: FeedCellSizes
        }
        
        struct FeedCellPhotoAttachment: FeedCellPhotoAttachmentViewModel {
            var photoUrlString: String?
            var width: Float
            var height: Float
        }
        // и у ленты новостей есть собственно ячейки с этими новостями
        let cells: [Cell]
        
        let footerTitle: String?
    }
}

struct Constants {
    static let cardInsets = UIEdgeInsets(top: 0, left: 8, bottom: 12, right: 8)

    static let postLabelFont = UIFont.systemFont(ofSize: 15)
    static let topViewHeight: CGFloat = 36
    static let countersPlaceholderHeight: CGFloat = 44

    static let countersPlaceholderViewWidth: CGFloat = 80
    static let countersPlaceholderViewHeight: CGFloat = 44

    static let countersPlaceholderViewsIconsSize: CGFloat = 24

    // dynamic

    static let postLabelInsets = UIEdgeInsets(top: 22 + Constants.topViewHeight, left: 12, bottom: 10, right: 12) // почему 58? 10?

    // moreTextButton
    static let minfiedPostLines = 6
    static let minifiedPostLimitLines = 8

    static let moreTextButtonInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
    static let moreTextButtonSize = CGSize(width: 170, height: 30)
}
