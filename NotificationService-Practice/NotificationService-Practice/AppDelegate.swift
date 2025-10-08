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
        
        // * 커스텀 액션 버튼 추가
        let doneAction = UNNotificationAction(identifier: "action.done", title: "Done")
        let cancelAction = UNNotificationAction(identifier: "action.cancle", title: "Cancel")
        let categories = UNNotificationCategory(
            identifier: "myNotificationCategory",
            actions: [doneAction, cancelAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        center.setNotificationCategories([categories])
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            print(granted)
        }
        
        // 2. device 토큰 획득: application(_:didRegisterForRemoteNotificationsWithDeviceToken:) 메소드 호출
        application.registerForRemoteNotifications()
        center.delegate = self
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(#function)
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print(tokenString)
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // foreground에서 시스템 푸시를 수신했을 때 해당 메소드가 호출
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(#function)
        completionHandler([.sound, .badge, .banner])
    }
    
    // foreground, background에서 시스템 푸시를 탭하거나 dismiss했을때 해당 메소드가 호출
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(#function)
        print(response.actionIdentifier)
    }
}
