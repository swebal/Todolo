//
//  Todo.swift
//  EnkelSwift
//
//  Created by Markus on 2019-03-07.
//  Copyright © 2019 The App Factory AB. All rights reserved.
//

import UIKit

class Post {
    
    var userId = 0
    var id = 0
    var title = "title"
    var body = "body"
    
    init(data:[String:Any]) {
        if let uid = data["userId"] as? Int {
            userId = uid
        }
        if let iid = data["id"] as? Int {
            id = iid
        }
        if let tt = data["title"] as? String {
            title = tt
        }
        if let bo = data["body"] as? String {
            body = bo
        }
    }
    
    func data() -> [String:Any] {
        var data = [String:Any]()
        data["userId"] = userId
        data["id"] = id
        data["title"] = title
        data["body"] = body
        return data
    }
}
