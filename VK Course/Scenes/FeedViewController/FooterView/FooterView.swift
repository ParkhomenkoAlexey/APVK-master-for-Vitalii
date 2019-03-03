//
//  FooterView.swift
//  VK Course
//
//  Created by Алексей Пархоменко on 10/02/2019.
//  Copyright © 2019 Алексей Пархоменко. All rights reserved.
//

import UIKit

class FooterView: UIView {
    
    private var mylabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = #colorLiteral(red: 0.6319127679, green: 0.6468527317, blue: 0.664311111, alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        loader.hidesWhenStopped = true
        loader.translatesAutoresizingMaskIntoConstraints = false
        
        return loader
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        addSubview(mylabel)
        addSubview(loader)
        
        mylabel.anchor(top: topAnchor,
                       leading: leadingAnchor,
                       bottom: nil,
                       trailing: trailingAnchor,
                       padding: UIEdgeInsets.init(top: 8, left: 20, bottom: 666, right: 20))
        
        loader.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loader.topAnchor.constraint(equalTo: mylabel.bottomAnchor, constant: 8).isActive = true
        
        
    }
    
    func setTitle(_ title: String?) {
        loader.stopAnimating()
        mylabel.text = title
    }
    
    func showLoader() {
        loader.startAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
