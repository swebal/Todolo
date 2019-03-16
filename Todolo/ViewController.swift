//
//  ViewController.swift
//  EnkelSwift
//
//  Created by Markus on 2019-02-28.
//  Copyright © 2019 The App Factory AB. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var todos = [Todo]()
    var posts = [Post]()
    var showPosts = false
    
    @IBOutlet weak var objectTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.objectTableView.dataSource = self
        self.objectTableView.delegate = self
    }

    @IBAction func getTodoPressed(_ sender: UIButton) {
        print("Get todos button pressed")
        get(method: "todos") { (array) in
            for obj in array {
                let todo = Todo(data: obj)
                self.todos.append(todo)
            }
            // Uppdatera vår tabell
            self.showPosts = false
            self.objectTableView.reloadData()
        }
    }
    
    @IBAction func getPostPressed(_ sender: UIButton) {
        print("Get posts button pressed")
        get(method: "posts") { (array) in
            for obj in array {
                let post = Post(data: obj)
                self.posts.append(post)
            }
            // Uppdatera vår tabell
            self.showPosts = true
            self.objectTableView.reloadData()
        }
    }
    
    @IBAction func postObjectPressed(_ sender: UIButton) {
        print("Post object button pressed")
        if todos.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(todos.count)))
            let todo = todos[randomIndex]
            let data = todo.data()
            post(method: "todos", params: data) { (statusCode) in
                print("Status: \(statusCode)")
            }
        } else if posts.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(posts.count)))
            let post = posts[randomIndex]
            let data = post.data()
            self.post(method: "posts", params: data) { (statusCode) in
                print("Status: \(statusCode)")
            }
        }
    }
    
    // 1) Skapa request med url
    // 2) Ange http typ och parametrar (om post)
    // 3) Skapa session och task från request
    // 4) Ta emot data (om !error) göra om data -> foundation-objekt (array, dictionary, string etc.)
    // 5) Returnera foundation-objekt till den som anropade metoden (anropa ui-tråden)
    
    func get(method:String, onCompletion:@escaping([[String:Any]]) -> Void) {
        
        let base = "https://jsonplaceholder.typicode.com/"
        
        guard let url = URL(string: base+method) else {
            print("Invalid url!")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let json = data else {
                return
            }
            guard let array = try? JSONSerialization.jsonObject(with: json, options: []) as! [[String:Any]] else {
                DispatchQueue.main.async {
                    onCompletion([[String:Any]]())
                }
                return
            }
            DispatchQueue.main.async {
                onCompletion(array)
            }
        }
        task.resume()
    }
    
    func post(method:String, params:[String:Any], onCompletion:@escaping(Int) -> Void) {
        
        let base = "https://jsonplaceholder.typicode.com/"
        
        guard let url = URL(string: base+method) else {
            print("Invalid url!")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            print("Could not parse params as body!")
            return
        }
        urlRequest.httpBody = httpBody
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                DispatchQueue.main.async {
                    onCompletion(0)
                }
                return
            }
            DispatchQueue.main.async {
                onCompletion(httpResponse.statusCode)
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showPosts ? posts.count : todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if (showPosts) {
            let post = posts[indexPath.row]
            cell.textLabel?.text = post.title
        } else {
            let todo = todos[indexPath.row]
            cell.textLabel?.text = todo.title
        }
        return cell
    }
}

