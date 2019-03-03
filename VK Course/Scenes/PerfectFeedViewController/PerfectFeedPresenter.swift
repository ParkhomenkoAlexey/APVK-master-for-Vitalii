//
//  PerfectFeedPresenter.swift
//  VK Course
//
//  Created by Алексей Пархоменко on 02/03/2019.
//  Copyright (c) 2019 Алексей Пархоменко. All rights reserved.
//

import UIKit

protocol PerfectFeedPresentationLogic {
  func presentData(response: PerfectFeed.Model.Response.ResponseType)
}

class PerfectFeedPresenter: PerfectFeedPresentationLogic {
    
    weak var viewController: PerfectFeedDisplayLogic?
    var cellLayoutCalculator: FeedCellLayoutCalculatorProtocol = FeedCellLayoutCalculator() // some kind of worker for presenter
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "d MMM 'в' HH:mm"
        return dateFormatter
    }()
  
  func presentData(response: PerfectFeed.Model.Response.ResponseType) {
    switch response {
    case .presentUserInfo(let user):
        print("presentUserInfo Presenter")
        let userViewModel = UserViewModel.init(photoUrlString: user?.photo100)
        viewController?.displayData(viewModel: PerfectFeed.Model.ViewModel.ViewModelData.displayUser(userViewModel: userViewModel))
    case .presentNewsFeed(let feed, let revealdedPostIds):
        print("presentNewsFeed Presenter")
        let cells = feed.items.map { (feedItem) in
            cellViewModel(from: feedItem,
                          profiles: feed.profiles,
                          groups: feed.groups,
                          revealedPostsIds: revealdedPostIds)
        }
        let footerTitle = String.localizedStringWithFormat(NSLocalizedString("record_count", comment: ""), cells.count)
        let feedViewModel = FeedViewModel.init(cells: cells, footerTitle: footerTitle)
        viewController?.displayData(viewModel: PerfectFeed.Model.ViewModel.ViewModelData.displayNewsFeed(feedViewModel: feedViewModel))
    case .presentFooterLoader:
        print("presentFooterLoader Presenter")
        viewController?.displayData(viewModel: PerfectFeed.Model.ViewModel.ViewModelData.displayFooterLoader)
    }
  }
    
    // MARK: Private functions
    
    // метод который заполняет содержимое ячеек РЕАЛЬНОЙ информацией
    private func cellViewModel(from feedItem: FeedItem, profiles: [Profile], groups: [Group], revealedPostsIds: [Int]) -> FeedViewModel.Cell {
        //FeedViewModel.Cell
        let profile = self.profile(for: feedItem.sourceId, profiles: profiles, groups: groups)
        
        let photoAttachemnts = self.photoAttachments(feedItem: feedItem)
        
        let date = Date(timeIntervalSince1970: feedItem.date)
        let dateTitle = dateFormatter.string(from: date)
        
        // пробегаемся по всему массиву revealedPostsIds, если хоть один элемент этого массива равен feedItem.postId то isFullSized == true
        
        let isFullSized = revealedPostsIds.contains { (postId) -> Bool in
            return postId == feedItem.postId
        }
        // короткая запись
        // let isFullSized = revealedPostsIds.contains(feedItem.postId)
        
        let postText = feedItem.text?.replacingOccurrences(of: "<br>", with: "\n")
        
        let sizes = cellLayoutCalculator.sizes(postText: postText, isFullSizedPost: isFullSized, photoAttachments: photoAttachemnts)
        return FeedViewModel.Cell.init(postId: feedItem.postId,
                                       iconUrlString: profile?.photo ?? "",
                                       name: profile?.name ?? "Noname",
                                       date: dateTitle,
                                       text: postText,
                                       likes: formattedCounter(feedItem.likes?.count),
                                       comments: formattedCounter(feedItem.comments?.count),
                                       shares: formattedCounter(feedItem.reposts?.count),
                                       views: formattedCounter(feedItem.views?.count),
                                       photoAttachements: photoAttachemnts,
                                       sizes: sizes)

        
    }
    
    // поиск профиля или группы по id
    private func profile(for id: Int, profiles: [Profile], groups: [Group]) -> ProfileRepresentable? {
        //print(id)
        let profilesOrGroups: [ProfileRepresentable] = id >= 0 ? profiles : groups
        let normalizeId = id >= 0 ? id : -id
        // находим по id первого кто совпал
        return profilesOrGroups.first(where: { (myProfileRepresentable) -> Bool in
            myProfileRepresentable.id == normalizeId
        })
    }
    
    private func formattedCounter(_ counter: Int?) -> String? {
        guard let counter = counter, counter > 0 else { return nil }
        var counterString = String(counter)
        if 4...6 ~= counterString.count {
            counterString = String(counterString.dropLast(3)) + "K"
        } else if counterString.count > 6 {
            counterString = String(counterString.dropLast(6)) + "M"
        }
        return counterString
    }
    
    private func photoAttachments(feedItem: FeedItem) -> [FeedViewModel.FeedCellPhotoAttachment] {
        guard let attachments = feedItem.attachments else { return [] }
        return attachments.compactMap({ attachment -> FeedViewModel.FeedCellPhotoAttachment? in
            guard let photo = attachment.photo else { return nil }
            return FeedViewModel.FeedCellPhotoAttachment.init(photoUrlString: photo.srcBig,
                                                                             width: photo.width,
                                                                             height: photo.height)
        })
    }
}
