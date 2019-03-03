//
//  AuthService.swift
//  VK Course
//
//  Created by Алексей Пархоменко on 22/01/2019.
//  Copyright © 2019 Алексей Пархоменко. All rights reserved.
//

import Foundation
import VKSdkFramework

protocol AuthServiceDelegate: class {
    func authServiceShouldShow(_ viewController: UIViewController)
    func authServiceDidSignIn()
    func authServiceDidSignInFail()
}


final class AuthService: NSObject, VKSdkDelegate, VKSdkUIDelegate {
    
    private let appId = "6829664"
    private let vkSdk: VKSdk
    
    var delegate: AuthServiceDelegate?
    
    override init() {
        vkSdk = VKSdk.initialize(withAppId: appId)
        super.init()
        vkSdk.register(self)
        vkSdk.uiDelegate = self
    }
    
    var token: String? {
        return VKSdk.accessToken()?.accessToken
    }
    
    var userId: String? {
        return VKSdk.accessToken()?.userId
    }
    
    func wakeUpSession() {
        let scope = ["wall", "friends"]
        
        // Этот метод пытается извлечь токен из хранилища и проверить, разрешено ли приложению использовать токен доступа пользователя.
        VKSdk.wakeUpSession(scope, complete: { [delegate] state, error in
            
            // если состояние приложения - пользователь авторизирован, то вызывается метод делегата
            if state == VKAuthorizationState.authorized {
                // если чувак авторизирован то вызывается метод делегата
                delegate?.authServiceDidSignIn()
                
            } else if state == VKAuthorizationState.initialized { // SDK initialized and ready to authorize
                print("ready to authorize")
                // Запускает процесс авторизации для получения неограниченного токена. Если VKapp доступен в системе, он открывается и запрашивает доступ у пользователя. В противном случае для запроса доступа будет открыт SFSafariViewController или webview.
                VKSdk.authorize(scope)
            } else {
                print("auth problems, state: \(state) error: \(String(describing: error))")
                delegate?.authServiceDidSignInFail()
            }
            
        })
    }
    
    // MARK: - VKSdkDelegate
    
    
    // Уведомляет о том, что авторизация завершена, и возвращает результат авторизации с новым токеном или ошибкой.
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        delegate?.authServiceDidSignIn()
    }
    
    func vkSdkUserAuthorizationFailed() {
        print(#function)
    }
    
    // MARK: - VKSdkUIDelegate
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        delegate?.authServiceShouldShow(controller)
    }

    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        print(#function)
    }
    
    
}
