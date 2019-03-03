//
//  PerfectFeedWorker.swift
//  VK Course
//
//  Created by Алексей Пархоменко on 02/03/2019.
//  Copyright (c) 2019 Алексей Пархоменко. All rights reserved.
//

import UIKit

class PerfectFeedService {
    
    var authService: AuthService
    var networkService: NetworkService!
    
    private var userResponse: UserResponse?
    private var feedResponse: FeedResponse?
    private var revealedPostsIds = [Int]()
    private var newFromInProcess: String?
    
    init() {
        self.authService = AppDelegate.shared().authService
        self.networkService = NetworkService(authService: authService)
    }
    
    func getUser(completion: @escaping (UserResponse?) -> Void) {
        
        networkService.getUser(completion: { (userResponse) in
            completion(userResponse)
        }) {
            print("failure \(#function) in \(#file)")
        }
    }
    
    func getFeed(completion: @escaping ([Int] ,FeedResponse) -> Void) {
        
        guard self.newFromInProcess == nil else { return }
        networkService.getFeed(completion: { [weak self] (feed) in
            self?.feedResponse = feed
            
            guard let feedResponse = self?.feedResponse else { return }
            completion(self!.revealedPostsIds, feedResponse)
        }) {
            print("failure \(#function) in \(#file)")
            
        }
    }
    
    func getNextBatch(completion: @escaping ([Int] ,FeedResponse) -> Void) {
        guard newFromInProcess == nil else { return }
        newFromInProcess = feedResponse?.nextFrom
        networkService.getFeed(nextBatchFrom: newFromInProcess, completion: { [weak self] (feed) in
            
            self?.newFromInProcess = nil
            guard self?.feedResponse?.nextFrom != feed.nextFrom else { return }
            
            self?.mergeResponse(feed)
            
            guard let feedResponse = self?.feedResponse else { return }
            completion(self!.revealedPostsIds, feedResponse)
            
            }, failure: { [weak self] in
                self?.newFromInProcess = nil
                print("failure \(#function) in \(#file)")
        })
    }
    
    func revealPostPostId(forPostId postId: Int, completion: @escaping ([Int] ,FeedResponse) -> Void) {
        revealedPostsIds.append(postId)
        
        guard let feedResponse = feedResponse else { return }
        completion(revealedPostsIds, feedResponse)
        
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
