//
//  NewFeedModels.swift
//  VK Course
//
//  Created by Алексей Пархоменко on 28/02/2019.
//  Copyright (c) 2019 Алексей Пархоменко. All rights reserved.
//

import UIKit

enum NewFeed {
    
    struct GeneralFeedViewModel {
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
        let cells: [Cell]
        let footerTitle: String?
    }
    
    struct GeneralFeedResponse {
        var feedResponse: FeedResponse
        var revealdedPostIds: [Int]
    }
    
    enum GetUser {
        struct Request {
        }
        struct Response {
            var userResponse: UserResponse?
        }
        struct ViewModel: TitleViewViewModel {
            var photoUrlString: String?
        }
    }
    
    enum GetNewsfeed {
        struct Request {
        }
        struct Response {
            var generalFeedResponse: GeneralFeedResponse
        }
        struct ViewModel {
            var FeedViewModel: GeneralFeedViewModel
        }
    }
    
    enum GetNextBranch {
        struct Request {
        }
        struct Response {
            var generalFeedResponse: GeneralFeedResponse
        }
        struct ViewModel {
            var FeedViewModel: GeneralFeedViewModel
        }
    }
    
    enum RevealPostIds {
        struct Request {
            var postId: Int
        }
        struct Response {
            var generalFeedResponse: GeneralFeedResponse
        }
        struct ViewModel {
            var FeedViewModel: GeneralFeedViewModel
        }
    }
    
}


