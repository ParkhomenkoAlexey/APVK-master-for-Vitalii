//
//  PerfectFeedInteractor.swift
//  VK Course
//
//  Created by Алексей Пархоменко on 02/03/2019.
//  Copyright (c) 2019 Алексей Пархоменко. All rights reserved.
//

import UIKit

protocol PerfectFeedBusinessLogic {
  func makeRequest(request: PerfectFeed.Model.Request.RequestType)
}

class PerfectFeedInteractor: PerfectFeedBusinessLogic {

  var presenter: PerfectFeedPresentationLogic?
  var service: PerfectFeedService?
  
  func makeRequest(request: PerfectFeed.Model.Request.RequestType) {
    if service == nil {
      service = PerfectFeedService()
    }
    
    switch request {
    case .getUser:
        print("getUser Interactor")
        service?.getUser(completion: { (user) in
            self.presenter?.presentData(response: PerfectFeed.Model.Response.ResponseType.presentUserInfo(user: user))
        })
    case .getNewsfeed:
        print("getNewsfeed Interactor")
        service?.getFeed(completion: { (revealdedPostIds, feed) in
            self.presenter?.presentData(response: PerfectFeed.Model.Response.ResponseType.presentNewsFeed(feed: feed, revealdedPostIds: revealdedPostIds))
        })
    case .getNextBatch:
        print("getNextBatch Interactor")
        self.presenter?.presentData(response: PerfectFeed.Model.Response.ResponseType.presentFooterLoader)
        service?.getNextBatch(completion: { (revealdedPostIds, feed) in
            self.presenter?.presentData(response: PerfectFeed.Model.Response.ResponseType.presentNewsFeed(feed: feed, revealdedPostIds: revealdedPostIds))
        })
    case .revealPostIds(let postId):
        print("revealPostIds Interactor")
        service?.revealPostPostId(forPostId: postId, completion: { (revealdedPostIds, feed) in
            self.presenter?.presentData(response: PerfectFeed.Model.Response.ResponseType.presentNewsFeed(feed: feed, revealdedPostIds: revealdedPostIds))
        })
    }
  }
}
