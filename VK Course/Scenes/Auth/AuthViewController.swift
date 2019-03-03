//
//  AuthViewController.swift
//  VK Course
//
//  Created by Алексей Пархоменко on 22/01/2019.
//  Copyright © 2019 Алексей Пархоменко. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController {

    private var authService: AuthService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // присваиваем authService которую объявиви выше authService которую объявливи в AppDelegate
        // зачем? 
        authService = AppDelegate.shared().authService
        authService.wakeUpSession()

      
    }

    @IBAction func signInTouch() {
        authService.wakeUpSession()
    }
}
