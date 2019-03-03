//
//  FeedInteractor.swift
//  VK Course
//
//  Created by Алексей Пархоменко on 23/01/2019.
//  Copyright © 2019 Алексей Пархоменко. All rights reserved.
//

import Foundation

protocol FeedBusinessLogic: class {
    func getUser()
    func getFeed()
    func getNextBatch()
    func revealPostPostId(for postId: Int)
}


final class FeedInteractor: FeedBusinessLogic {
    
    private let presenter: FeedPresenterLogic
    private let networkService: NetworkService
    
    private var userResponse: UserResponse?
    private var feedResponse: FeedResponse?
    private var revealedPostsIds = [Int]()
    private var newFromInProcess: String?
    
    init(presenter: FeedPresenterLogic, networkService: NetworkService) {
        self.presenter = presenter
        self.networkService = networkService
    }
    
    func getUser() {
        networkService.getUser(completion: { [weak self] user in
            self?.userResponse = user
            self?.presenter.presentUserInfo(user)
            
            }, failure: {
                print("failure Feed Interactor")
        })
    }
    
    // достаем Feed из инета
    func getFeed() {
        
        guard newFromInProcess == nil else { return }
        
        
        networkService.getFeed(completion: { [weak self] feedResponse in
            // если достали то 
            self?.feedResponse = feedResponse
            self?.presentFeed()
            }, failure: {
                print("failure Feed Interactor")
        })
    }
    
    func getNextBatch() {
        guard newFromInProcess == nil else { return }
        newFromInProcess = feedResponse?.nextFrom
        
        presenter.presentFooterLoader()
        networkService.getFeed(nextBatchFrom: feedResponse?.nextFrom, completion: { [weak self] feedResponse in
            self?.newFromInProcess = nil
            guard self?.feedResponse?.nextFrom != feedResponse.nextFrom else { return }
            
            self?.mergeResponse(feedResponse)
            self?.presentFeed()
            }, failure: { [weak self] in
                print("TEST TEST TEST")
                self?.newFromInProcess = nil
        })
    }
    
    
    
    func revealPostPostId(for postId: Int) {
        // теперь мы это значение передаем в массив
        revealedPostsIds.append(postId) // что будет если увеличим на 1? на 10? на 100?
        presentFeed()
    }
    
    private func presentFeed() {
        guard let feedResponse = feedResponse else { return }
        presenter.presentFeed(feedResponse, revealedPostIds: revealedPostsIds) // зачем мы в presenter передаем revealedPostIds?
    }

    
    private func mergeResponse(_ nextBatch: FeedResponse) {
        if feedResponse == nil {
            feedResponse = nextBatch
        } else {
            feedResponse?.items.append(contentsOf: nextBatch.items)
            
            var profiles = nextBatch.profiles
            if let oldProfiles = feedResponse?.profiles {
                
                let oldProfilesFiltered = oldProfiles.filter({ oldProfile -> Bool in
                    !nextBatch.profiles.contains(where: { $0.id == oldProfile.id })
                })
                profiles.append(contentsOf: oldProfilesFiltered)
                
            }
            feedResponse?.profiles = profiles
            
            var groups = nextBatch.groups
            if let oldGroups = feedResponse?.groups {
                
                let oldGroupsFiltered = oldGroups.filter({ oldGroup -> Bool in
                    !nextBatch.groups.contains(where: {$0.id == oldGroup.id })
                })
                groups.append(contentsOf: oldGroupsFiltered)
                
            }
            feedResponse?.groups = groups
            
            feedResponse?.nextFrom = nextBatch.nextFrom
            
        }
    }
    
    
}
