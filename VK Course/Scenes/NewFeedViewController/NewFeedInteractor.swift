//
//  NewFeedInteractor.swift
//  VK Course
//
//  Created by Алексей Пархоменко on 28/02/2019.
//  Copyright (c) 2019 Алексей Пархоменко. All rights reserved.
//

import UIKit

protocol NewFeedBusinessLogic {

    func getUser(request: NewFeed.GetUser.Request)
    func getNewsfeed(request: NewFeed.GetNewsfeed.Request)
    func getNextBatch(request: NewFeed.GetNextBranch.Request)
    func revealPostIds(request: NewFeed.RevealPostIds.Request)
    
}

class NewFeedInteractor: NewFeedBusinessLogic {
    
  var presenter: NewFeedPresentationLogic?
  var service = NewFeedService() // some kind of wirker in Interactor
    
    // MARK: NewFeedBusinessLogic
    
    func getUser(request: NewFeed.GetUser.Request) {
        print("getUser Interactor")
        service.getUser { (user) in
            let response = NewFeed.GetUser.Response.init(userResponse: user)
            self.presenter?.presentUserInfo(response: response)
        }
    }
    
    func getNewsfeed(request: NewFeed.GetNewsfeed.Request) {
        print("getNewsfeed Interactor")
        service.getFeed { (revealdedPostIds, feed)  in
            
            let response = NewFeed.GetNewsfeed.Response.init(generalFeedResponse: NewFeed.GeneralFeedResponse.init(feedResponse: feed,
                                                                                                                   revealdedPostIds: revealdedPostIds))
            self.presenter?.presentNewsFeed(response: response.generalFeedResponse)
        }
    }
    
    func getNextBatch(request: NewFeed.GetNextBranch.Request) {
        print("getNextBatch Interactor")
        self.presenter?.presentFooterLoader()
        service.getNextBatch { (revealdedPostIds, feed) in
            
            let response = NewFeed.GetNextBranch.Response.init(generalFeedResponse: NewFeed.GeneralFeedResponse.init(feedResponse: feed,
                                                                                                                   revealdedPostIds: revealdedPostIds))
            self.presenter?.presentNewsFeed(response: response.generalFeedResponse)
        }
    }
    
    func revealPostIds(request: NewFeed.RevealPostIds.Request) {
        print("revealPostIds Interactor")
        service.revealPostPostId(forPostId: request.postId) { (revealdedPostIds, feed) in
            let response = NewFeed.RevealPostIds.Response.init(generalFeedResponse: NewFeed.GeneralFeedResponse.init(feedResponse: feed,
                                                                                                                     revealdedPostIds: revealdedPostIds))
            self.presenter?.presentNewsFeed(response: response.generalFeedResponse)
        }
    }
    
}
