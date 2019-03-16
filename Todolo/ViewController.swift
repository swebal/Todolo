//
//  ViewController.swift
//  EnkelSwift
//
//  Created by Markus on 2019-02-28.
//  Copyright © 2019 The App Factory AB. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var todos = [Todo]()
    var posts = [Post]()
    var showPosts = false
    let noteId = "changeButtonColorIfTapped"
    
    @IBOutlet weak var objectTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.objectTableView.dataSource = self
        self.objectTableView.delegate = self
        // Övervaka när en notis tas emot av LocalNotificationCenter (ifall appen är aktiv)
        let receivedNote = Notification.Name(LocalNotificationHelper.notificationReceived)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.localNotificationReceived), name: receivedNote, object: nil)
        // Övervaka när användaren trycker i en notis (ifall appen är aktiv)
        let tappedNote = Notification.Name(LocalNotificationHelper.tappedNotification)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.localNotificationTapped), name: tappedNote, object: nil)
    }
    
    // Outlets
    
    @IBOutlet weak var noteButton: UIButton!
    
    // Actions
    
    @IBAction func getTodoPressed(_ sender: UIButton) {
        print("Get todos button pressed")
        WebRequestHelper.shared.getArray(method: "todos") { (array) in
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
        WebRequestHelper.shared.getArray(method: "posts") { (array) in
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
            WebRequestHelper.shared.postDictionary(method: "todos", params: data) { (statusCode) in
                print("Status: \(statusCode)")
            }
        } else if posts.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(posts.count)))
            let post = posts[randomIndex]
            let data = post.data()
            WebRequestHelper.shared.postDictionary(method: "posts", params: data) { (statusCode) in
                print("Status: \(statusCode)")
            }
        }
    }
    
    @IBAction func localNotePressed(_ sender: UIButton) {
        // Skapa notis
        let date = Date(timeIntervalSinceNow: 30) // Bör inte vara mindre än 30 sek (prova att öka denna om notisen inte dyker upp)
        LocalNotificationHelper.shared.scheduleLocalNotification(date: date, id:noteId, title: "Hej", body: "Det här är innehållet i en notis", extra: "Gömd info jag vill skicka med, kanske ett id?")
        let alert = UIAlertController(title: "Note scheduled", message: "Successfully scheduled local notification in 30 seconds", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // Table view
    
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
    
    // Notifications
    
    @objc func localNotificationReceived(notification:Notification) {
        // Hämta ut id från notifikationen (ej samma som lokal notis)
        guard let id = notification.object as? String else {
            return
        }
        if id == noteId {
            // Ändra färg på knapp när notisen tas emot
            noteButton.setTitleColor(UIColor.green, for: UIControlState.normal)
        }
    }
    
    @objc func localNotificationTapped(notification:Notification) {
        // Hämta ut id från notifikationen (ej samma som lokal notis)
        guard let id = notification.object as? String else {
            return
        }
        if id == noteId {
            // Ändra färg på knapp när notisen tas emot
            noteButton.setTitleColor(UIColor.red, for: UIControlState.normal)
        }
    }
}

