//
//  ViewController.swift
//  EnkelSwift
//
//  Created by Markus on 2019-02-28.
//  Copyright © 2019 The App Factory AB. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ScannerDelegate {
    
    // Både UIImagePickerControllerDelegate, UINavigationControllerDelegate behövs för att visa kamera eller hämta bilder
    
    // MARK: Properties
    
    var todos = [Todo]()
    var posts = [Post]()
    var showPosts = false
    let noteId = "changeButtonColorIfTapped"
    let imagePicker = UIImagePickerController()
    
    // MARK: Outlets
    
    @IBOutlet weak var noteButton: UIButton!
    @IBOutlet weak var objectTableView: UITableView!
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ange datakälla och delegate för tabellen
        self.objectTableView.dataSource = self
        self.objectTableView.delegate = self
        
        // Övervaka när en notis tas emot av LocalNotificationCenter (ifall appen är aktiv)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.localNotificationReceived), name: Notification.Name(LocalNotificationHelper.notificationReceived), object: nil)
        
        // Övervaka när användaren trycker i en notis (ifall appen är aktiv)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.localNotificationTapped), name: Notification.Name(LocalNotificationHelper.tappedNotification), object: nil)
    }
    
    // MARK: Actions
    
    @IBAction func getTodoPressed(_ sender: UIButton) {
        // Hämta objekt (todos) från JSONPlaceholder
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
        // Hämta objekt (posts) från JSONPlaceholder
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
        // Posta ett objekt (todo) till JSONPlaceholder
        print("Post object button pressed")
        if todos.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(todos.count)))
            let todo = todos[randomIndex]
            let data = todo.data()
            WebRequestHelper.shared.postDictionary(method: "todos", params: data) { (statusCode) in
                print("Status: \(statusCode)")
                let result = "Status: \(statusCode)"
                let alert = UIAlertController(title: result, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Must get todos before posting object", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func localNotePressed(_ sender: UIButton) {
        // Skapa lokal notis om 10 sekunder
        let date = Date(timeIntervalSinceNow: 10)
        LocalNotificationHelper.shared.scheduleLocalNotification(date: date, id:noteId, title: "Hej", body: "Det här är innehållet i en notis", extra: "Gömd info jag vill skicka med, kanske ett id?")
        let alert = UIAlertController(title: "Note scheduled", message: "Successfully scheduled local notification in 10 seconds", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func photosPressed(_ sender: UIButton) {
        // Visa action sheet och låt användare välja kamera eller bildbibliotek
        let actionSheet = UIAlertController(title: "Välj källa", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Kamera", style: .default, handler: { (action) in
            // Öppna kameran
            self.importPhoto(library: false)
        }))
        actionSheet.addAction(UIAlertAction(title: "Bibliotek", style: .default, handler: { (action) in
            // Öppna biblioteket
            self.importPhoto(library: true)
        }))
        present(actionSheet, animated: true)
    }
    
    // MARK: Table view
    
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
    
    // MARK: Notification selectors
    
    @objc func localNotificationReceived(notification:Notification) {
        // Hämta ut id från notifikationen (ej samma som lokal notis)
        guard let id = notification.object as? String else {
            return
        }
        if id == noteId {
            // Ändra färg på knapp när notisen tas emot
            noteButton.setTitleColor(UIColor.green, for: UIControl.State.normal)
        }
    }
    
    @objc func localNotificationTapped(notification:Notification) {
        // Hämta ut id från notifikationen (ej samma som lokal notis)
        guard let id = notification.object as? String else {
            return
        }
        if id == noteId {
            // Ändra färg på knapp när notisen tas emot
            noteButton.setTitleColor(UIColor.red, for: UIControl.State.normal)
        }
    }
    
    // MARK: Bildkälla
    
    func importPhoto(library: Bool) {
        let source = library ? "library" : "camera"
        print("Will open \(source)...")
        imagePicker.delegate = self
        imagePicker.allowsEditing = true // Sätt till false om du inte vill visa editorn
        imagePicker.sourceType = library ? .photoLibrary : .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        // Använd UIImagePickerControllerOriginalImage nedan om du inte visar editorn ovan!
        guard let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage else {
            return
        }
        print("Will add image to view...")
        let imageView = UIImageView(image: pickedImage)
        // Visa bara en liten bild istället för en jättestor
        let ratio = imageView.frame.size.width / imageView.frame.size.height
        let thumbnail = CGFloat(100)
        let randomX = CGFloat(arc4random_uniform(UInt32(self.view.frame.size.width-thumbnail)))
        let randomY = CGFloat(arc4random_uniform(UInt32(self.view.frame.size.height-thumbnail/ratio)))
        imageView.frame = CGRect(x: randomX, y: randomY, width: thumbnail, height: thumbnail/ratio)
        self.view .addSubview(imageView)
        // Lägg till en tap gesture så att man kan klicka bort bilden från vyn
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped)))
        // Stäng bildvisaren eller kameran
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imageTapped(tapGesture:UITapGestureRecognizer) {
        // Ta bort bilden som innehåller denna tap
        print("Will remove image from view...")
        tapGesture.view?.removeFromSuperview()
    }
    
    // MARK: Barcode scanner notification
    
    func didScanCode(code: String) {
        let info = UIAlertController(title: "Data", message: code, preferredStyle: .alert)
        info.addAction(UIAlertAction(title: "Close", style: .default, handler: { (action) in
            self.dismiss(animated: true)
        }))
        present(info, animated: true)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scanSegue" {
            if let scanner = segue.destination as? ScannerViewController {
                scanner.scannerDelegate = self
            }
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
