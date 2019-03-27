//
//  DataManager.swift
//  Todolo
//
//  Created by Markus on 2019-03-27.
//  Copyright © 2019 The App Factory AB. All rights reserved.
//

import UIKit

class DataManager: NSObject {
    
    static let shared = DataManager()
    
    // Lägg till all data du vill dela mellan klasser här!
    var data = [String]()
    
    override init() {
        super.init()
        print("Jag lever!")
    }
}
