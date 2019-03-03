//
//  TitleView.swift
//  VK Course
//
//  Created by Алексей Пархоменко on 09/02/2019.
//  Copyright © 2019 Алексей Пархоменко. All rights reserved.
//

import UIKit

protocol TitleViewViewModel {
    var photoUrlString: String? { get }
}

class TitleView: UIView {
    
    
    private var myTextField = InsetableTextField()
    
    private var myAvatarView: WebImageView = {
       let imageView = WebImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .blue
        imageView.clipsToBounds = true // если уберем то моя аватарка станет квадратной несмотря на "override var bounds: CGRect"
        return imageView
    }()
    
    override var bounds: CGRect {
        didSet {
            myAvatarView.layoutIfNeeded()
            myAvatarView.layer.cornerRadius = myAvatarView.frame.width / 2
        }
    }
    
    func set(userViewModel: TitleViewViewModel) {
        myAvatarView.set(imageUrl: userViewModel.photoUrlString)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false // позволяет растягиваться view
        
        addSubview(myTextField)
        addSubview(myAvatarView)
    
        makeConstraints()
    }
    
    private func makeConstraints() {
        // myAvatarView constraints
        myTextField.anchor(top: topAnchor,
                           leading: leadingAnchor,
                           bottom: bottomAnchor,
                           trailing: myAvatarView.leadingAnchor,
                           padding: UIEdgeInsets.init(top: 4, left: 4, bottom: 4, right: 12))
        
        
        myAvatarView.anchor(top: topAnchor,
                            leading: nil,
                            bottom: nil,
                            trailing: trailingAnchor,
                            padding: UIEdgeInsets.init(top: 4, left: 666, bottom: 666, right: 4))
        myAvatarView.heightAnchor.constraint(equalTo: myTextField.heightAnchor, multiplier: 1).isActive = true
        myAvatarView.widthAnchor.constraint(equalTo: myTextField.heightAnchor, multiplier: 1).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
    
}
