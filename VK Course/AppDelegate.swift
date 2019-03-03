//
//  AppDelegate.swift
//  VK Course
//
//  Created by Алексей Пархоменко on 22/01/2019.
//  Copyright © 2019 Алексей Пархоменко. All rights reserved.
//

import UIKit
import VKSdkFramework

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var authService: AuthService!
    
    
    // метод нужен для того, чтобы достучаться из файла AuthViewController конкретно в authService которая находится в этом файле
    // паттерн проектирования Singleton
    static func shared() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        self.authService = AuthService() // синициировали AuthService
        authService.delegate = self
        
        let authVC: AuthViewController = AuthViewController.loadFromStoryboard()
        window?.rootViewController = authVC
        window?.makeKeyAndVisible()
        
        return true
    }

    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        VKSdk.processOpen(url, fromApplication: UIApplication.OpenURLOptionsKey.sourceApplication.rawValue)
        return true
    }
    
    
}

extension AppDelegate: AuthServiceDelegate {
    
    func authServiceShouldShow(_ viewController: UIViewController) {
        window?.rootViewController?.present(viewController, animated: true, completion: nil)
    }
    
    func authServiceDidSignIn() {
        if !(window?.rootViewController is PerfectFeedViewController) {
            
            let feedVC = PerfectFeedViewController.loadFromStoryboard()
            let navVC = UINavigationController(rootViewController: feedVC)
            window?.rootViewController = navVC
        }
    }
    
    func authServiceDidSignInFail() {
        if !(window?.rootViewController is AuthViewController) {
            window?.rootViewController = AuthViewController.loadFromStoryboard()
        }
    }
}
