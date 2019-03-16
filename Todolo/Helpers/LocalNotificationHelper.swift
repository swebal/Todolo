//
//  LocalNotificationHelper.swift
//  Todolo
//
//  Created by Markus Karlsson on 2019-03-16.
//  Copyright © 2019 The App Factory AB. All rights reserved.
//

import UIKit
import UserNotifications

class LocalNotificationHelper : NSObject, UNUserNotificationCenterDelegate {
    
    static let categoryIdentifier = "TODOLO_CATEGORY"
    static let shared = LocalNotificationHelper()
    
    override init() {
        super.init()
        // Definiera kategori för lokala notiser (obligatoriskt)
        let category = UNNotificationCategory(identifier: LocalNotificationHelper.categoryIdentifier, actions: [], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        // Lyssna på notiser som anländer då appen är aktiv
        UNUserNotificationCenter.current().delegate = self
    }
    
    private func authorizeNotifications(success:@escaping(Bool) -> Void) {
        // Fråga om tillåtelse från användaren
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if !granted {
                print("Notifications permission denied because: \(String(describing: error?.localizedDescription)).")
            }
            success(granted)
        }
    }
    
    func scheduleLocalNotification(date:Date, id:String, title:String, body:String, extra:String) {
        authorizeNotifications { (success) in
            if (success) {
                // Innehåll i notis
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.userInfo["extra"] = extra
                content.sound = UNNotificationSound.default()
                content.categoryIdentifier = LocalNotificationHelper.categoryIdentifier
                // Datum
                let calendar = Calendar.current
                let components = calendar.dateComponents([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day, Calendar.Component.hour, Calendar.Component.minute], from: date)
                // Skall avfyras på en kalenderdag
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                // Förfrågan för att boka notis
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                let center = UNUserNotificationCenter.current()
                center.add(request) { (error) in
                    if error != nil {
                        print("Local notification failed")
                    } else {
                        print("Local notification scheduled")
                    }
                }
            }
        }
    }
    
    // Visar notis i förgrunden ifall appen är aktiv
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Did receive local notification")
        let name = NSNotification.Name(notification.request.identifier)
        NotificationCenter.default.post(name: name, object: nil)
        completionHandler([.alert, .badge, .sound])
    }
    
    // Hantera knapptryckningar i en notis
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User did tap in notification")
        completionHandler()
    }
}
