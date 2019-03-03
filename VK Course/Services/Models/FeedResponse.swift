//
//  FeedResponse.swift
//  VK Course
//
//  Created by Алексей Пархоменко on 22/01/2019.
//  Copyright © 2019 Алексей Пархоменко. All rights reserved.
//

import Foundation

struct FeedResponseWrapped: Decodable {
    let response: FeedResponse
}

struct FeedResponse: Decodable {
    var items: [FeedItem]
    var profiles: [Profile]
    var groups: [Group]
    var nextFrom: String?
}

struct FeedItem: Decodable {
    
    let sourceId: Int
    let date: Double
    let postId: Int
    let text: String?
    let signerId: Int?
    let comments: CountableItem?
    let likes: CountableItem?
    let reposts: CountableItem?
    let views: CountableItem?
    let attachments: [Attachment]?
    
}

struct CountableItem: Decodable {
    let count: Int
}

struct Attachment: Decodable {
    let photo: Photo?
}

//struct Photo: Decodable {
//    let srcBig: String
//    let height: Float
//    let width: Float
//}

struct Photo: Decodable {

    let sizes: [PhotoSize]

    var srcBig: String {
        return getPropperSize().url
    }

    var height: Float {
        return getPropperSize().height
    }

    var width: Float {
        return getPropperSize().width
    }

    private func getPropperSize() -> PhotoSize {
        if let sizeX = sizes.first(where: { $0.type == "x"}) {
            return sizeX
        } else if let fallbackSize = sizes.last {
            return fallbackSize
        } else {
            return PhotoSize(type: "wrong image", url: "wrong image", width: 0, height: 0)
        }
    }
}

struct PhotoSize: Decodable {
    let type: String
    let url: String
    let width: Float
    let height: Float
}


protocol ProfileRepresentable {
    var id: Int { get }
    var name: String { get }
    var photo: String { get }
}


struct Profile: Decodable, ProfileRepresentable {
    let id: Int
    let firstName: String
    let lastName: String
    let photo100: String
    
    var name: String { return firstName + " " + lastName }
    var photo: String { return photo100 }
}

struct Group: Decodable, ProfileRepresentable {
    let id: Int
    let name: String
    let photo100: String
    
    var photo: String { return photo100 }
}


