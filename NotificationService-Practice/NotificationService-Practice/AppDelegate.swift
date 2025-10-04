//
//  AppDelegate.swift
//  NotificationService-Practice
//
//  Created by 박신영 on 10/4/25.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print(#function)
        
        // 1. 푸시 권한 요청
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            print(granted)
        }
        
        // 2. device 토큰 획득: application(_:didRegisterForRemoteNotificationsWithDeviceToken:) 메소드 호출
        application.registerForRemoteNotifications()
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(#function)
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print(tokenString)
    }

}
