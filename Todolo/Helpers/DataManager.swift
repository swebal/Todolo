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
    var currentPost:Post?
    var currentTodo:Todo?
    
    var f:Float = 1.9
    
    func saveAll() {
        saveData()
        saveCurrentPost()
    }
    
    func appendData(string:String) {
        data.append(string)
        saveData()
    }
    
    private func saveData() {
        UserDefaults.standard.set(data, forKey: "data")
    }
    
    private func saveCurrentPost() {
        UserDefaults.standard.set(currentPost?.data(), forKey: "currentPost")
    }
    
    private func loadAll() {
        data = UserDefaults.standard.array(forKey: "data") as! [String]
//        currentPost = Post(data: UserDefaults.standard.dictionary(forKey: "currentPost")!)
    }
    
    private override init() {
        super.init()
        loadAll()
        print("Jag lever!")
    }
}
