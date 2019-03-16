//
//  BackgroundFetchHelper.swift
//  Todolo
//
//  Created by Markus Karlsson on 2019-03-16.
//  Copyright © 2019 The App Factory AB. All rights reserved.
//

import UIKit

class BackgroundFetchHelper: NSObject {
    
    static let shared = BackgroundFetchHelper()
    
    override init() {
        super.init()
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
    }
    
    func fetchWithCompletionHandler(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        let date = Date(timeIntervalSinceNow: 1)
        
        // TODO: Hämta ny data från en server? Här bör en koppling finnas till en gemensam DataManager eller dylikt
        
        // Skapa en ny notis ifall det finns något ny data
        LocalNotificationHelper.shared.scheduleLocalNotification(date: date, id: "backgroundFetch", title: "Hämtade data", body: "Fick tillfälle att hämta lite data, så jag passade på", extra: "bonus")
        completion(UIBackgroundFetchResult.noData) // Använd .newData ifall du faktiskt hämtar något!
    }
}
