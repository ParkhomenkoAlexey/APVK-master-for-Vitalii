//
//  NewFeedPresenter.swift
//  VK Course
//
//  Created by Алексей Пархоменко on 28/02/2019.
//  Copyright (c) 2019 Алексей Пархоменко. All rights reserved.
//

import UIKit

protocol NewFeedPresentationLogic {
    func presentUserInfo(response: NewFeed.GetUser.Response)
    func presentNewsFeed(response: NewFeed.GeneralFeedResponse)
    func presentFooterLoader()
}

class NewFeedPresenter: NewFeedPresentationLogic {

  weak var viewController: NewFeedDisplayLogic?
  var cellLayoutCalculator: FeedCellLayoutCalculatorProtocol = FeedCellLayoutCalculator() // some kind of worker for presenter
    
  let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ru_RU")
    dateFormatter.dateFormat = "d MMM 'в' HH:mm"
    return dateFormatter
    }()

    // MARK: NewFeedPresentationLogic
    
    func presentUserInfo(response: NewFeed.GetUser.Response) {
        print("presentUserInfo Presenter")
        let viewModel = NewFeed.GetUser.ViewModel.init(photoUrlString: response.userResponse?.photo100)
        viewController?.displayUser(viewModel: viewModel)
    }
    
    func presentNewsFeed(response: NewFeed.GeneralFeedResponse) {
        print("presentNewsFeed Presenter")
        
        let cells = response.feedResponse.items.map { (feedItem) in
            
            cellViewModel(from: feedItem,
                          profiles: response.feedResponse.profiles,
                          groups: response.feedResponse.groups,
                          revealedPostsIds: response.revealdedPostIds)
            
        }
        let footerTitle = String.localizedStringWithFormat(NSLocalizedString("record_count", comment: ""), cells.count)
        let viewModel = NewFeed.GeneralFeedViewModel.init(cells: cells, footerTitle: footerTitle)
        viewController?.displayNewsFeed(viewModel: viewModel)
    }

    func presentFooterLoader() {
        print("presentFooterLoader Presenter")
        viewController?.displayFooterLoader()
    }
    
    // MARK: Private functions
    
    // метод который заполняет содержимое ячеек РЕАЛЬНОЙ информацией
    private func cellViewModel(from feedItem: FeedItem, profiles: [Profile], groups: [Group], revealedPostsIds: [Int]) -> NewFeed.GeneralFeedViewModel.Cell {
        
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
        
        return NewFeed.GeneralFeedViewModel.Cell.init(postId: feedItem.postId,
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
    
    // видимо поиск профиля или группы по id
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
    
    private func photoAttachments(feedItem: FeedItem) -> [NewFeed.GeneralFeedViewModel.FeedCellPhotoAttachment] {
        guard let attachments = feedItem.attachments else { return [] }
        return attachments.compactMap({ attachment -> NewFeed.GeneralFeedViewModel.FeedCellPhotoAttachment? in
            guard let photo = attachment.photo else { return nil }
            return NewFeed.GeneralFeedViewModel.FeedCellPhotoAttachment.init(photoUrlString: photo.srcBig,
                                                                             width: photo.width,
                                                                             height: photo.height)

        })
    }
}
