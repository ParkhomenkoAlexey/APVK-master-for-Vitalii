//
//  UpdateRowLayout.swift
//  Pinterest
//
//  Created by Алексей Пархоменко on 07/02/2019.
//  Copyright © 2019 Razeware LLC. All rights reserved.
//

import UIKit

protocol UpdateRowLayoutDelegate: class {
  
  func collectionView(_ collectionView: UICollectionView, photoAtIndexPath indexPath: IndexPath) -> CGSize
  
}

class UpdateRowLayout: UICollectionViewLayout {

  // 1
  weak var delegate: UpdateRowLayoutDelegate!
  
  // 2
    static var numberOfRows: CGFloat = 1
  fileprivate var cellPadding: CGFloat = 8
  
  // 3
  fileprivate var cache = [UICollectionViewLayoutAttributes]()
  
  // 4
  // будет все время изменяться
  fileprivate var contentWidth: CGFloat = 0
  
  // константа
  fileprivate var contentHeight: CGFloat {
    guard let collectionView = collectionView else { return 0 }
    
    let insets = collectionView.contentInset
    return collectionView.bounds.height - (insets.left + insets.right)
  }
  
  // 5
  override var collectionViewContentSize: CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }
    
  override func prepare() {
    contentWidth = 0 // если уберем то пролистывать фотки будем до бесконечности (почти, зависит от предыдущего collectionView), хотя там уже будет пусто
    cache = [] // cache.isEmpty == true просто нужно убрать
    
    // 1
    guard cache.isEmpty == true, let collectionView = collectionView else { return }
    
    // 1.5 достали массив с фотографиями
    var photos = [CGSize]()
    for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
      let indexPath = IndexPath(item: item, section: 0)
      let photoSize = delegate.collectionView(collectionView, photoAtIndexPath: indexPath)
      photos.append(photoSize)
    }
    let superviewWidth = collectionView.frame.width
    
    // 1.7
    guard var rowHeight = UpdateRowLayout.rowHeightCounter(superviewWidth: superviewWidth, photosArray: photos) else { return }
    rowHeight = rowHeight / UpdateRowLayout.numberOfRows
    
    
    let photosRatios = photos.map {$0.height / $0.width}
    
    // 2
    var yOffset = [CGFloat]()
    for row in 0 ..< Int(UpdateRowLayout.numberOfRows) {
      yOffset.append(CGFloat(row) * rowHeight)
    }
    
    var row = 0
    var xOffset = [CGFloat](repeating: 0, count: Int(UpdateRowLayout.numberOfRows))
    
    // 3
    for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
      let indexPath = IndexPath(item: item, section: 0)
      
    // 4
    let ratio = photosRatios[indexPath.row]
    let width = rowHeight / ratio
    let frame = CGRect(x: xOffset[row], y: yOffset[row], width: width, height: rowHeight)
    let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
    // 5
      let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
      attributes.frame = insetFrame
      cache.append(attributes)
      
    // 6
      contentWidth = max(contentWidth, frame.maxX)
      xOffset[row] = xOffset[row] + width
        row = row < Int((UpdateRowLayout.numberOfRows - 1)) ? (row + 1) : 0
    }
    
  } // prepare()
  
    // если эта функция больше нигде не понадобится то убрать из нее superviewWidth
    static func rowHeightCounter(superviewWidth: CGFloat, photosArray: [CGSize]) -> CGFloat? {
        var rowHeight: CGFloat
        
        // проанализировав размеры всех фото нашли такую высоту фото
        // которая позволит вмещать даже самое длинное фото на полный экран в ущерб маленьким фото (но это не критично)
        let photoWithMinRatio = photosArray.min { (first, second) -> Bool in
            (first.height / first.width) < (second.height / second.width)
        }
        
        //print(superviewWidth)
        guard let myPhotoWithMinRatio = photoWithMinRatio else {
            //print("не нашло")
            return nil
        }
        
        //print(myPhotoWithMinRatio)
        let difference = superviewWidth / myPhotoWithMinRatio.width
        //print(difference)
        rowHeight = myPhotoWithMinRatio.height * difference
        //print(rowHeight)
        rowHeight = rowHeight * UpdateRowLayout.numberOfRows
        return rowHeight
    }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
    
    for attributes in cache {
      if attributes.frame.intersects(rect) {
        visibleLayoutAttributes.append(attributes)
      }
    }
    return visibleLayoutAttributes
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return cache[indexPath.item]
  }
}
