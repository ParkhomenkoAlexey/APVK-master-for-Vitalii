//
//  PerfectFeedModels.swift
//  VK Course
//
//  Created by Алексей Пархоменко on 02/03/2019.
//  Copyright (c) 2019 Алексей Пархоменко. All rights reserved.
//

import UIKit

enum PerfectFeed {
   
  enum Model {
    struct Request {
      enum RequestType {
        case getUser
        case getNewsfeed
        case getNextBatch
        case revealPostIds(postId: Int)
      }
    }
    struct Response {
      enum ResponseType {
        case presentUserInfo(user: UserResponse?)
        case presentNewsFeed(feed: FeedResponse, revealdedPostIds: [Int])
        case presentFooterLoader
      }
    }
    struct ViewModel {
      enum ViewModelData {
        case displayNewsFeed(feedViewModel: FeedViewModel)
        case displayUser(userViewModel: UserViewModel)
        case displayFooterLoader
      }
    }
  }
}

struct UserViewModel: TitleViewViewModel {
    var photoUrlString: String?
}

struct FeedViewModel {
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
    
    // у ленты новостей есть ячейки с новостями
    let cells: [Cell]
    
    let footerTitle: String?
}
