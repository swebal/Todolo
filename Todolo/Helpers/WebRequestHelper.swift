//
//  WebRequestHelper.swift
//  Todolo
//
//  Created by Markus Karlsson on 2019-03-16.
//  Copyright © 2019 The App Factory AB. All rights reserved.
//

import UIKit

class WebRequestHelper: NSObject {
    
    static let shared = WebRequestHelper()
    
    // --- SKAPA EGNA REQUESTS TILL EN RESTFUL WEB SERVICE --- //
    
    // 1) Skapa request med url
    // 2) Ange http typ och parametrar (om post)
    // 3) Skapa session och task från request
    // 4) Ta emot data (om !error) göra om data -> foundation-objekt (array, dictionary, string etc.)
    // 5) Returnera foundation-objekt till den som anropade metoden (anropa ui-tråden)
    
    func getRequest(method:String) -> URLRequest? {
        
        let base = "https://jsonplaceholder.typicode.com/"
        
        guard let url = URL(string: base+method) else {
            print("Invalid url!")
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        return urlRequest
    }
    
    func getDictionary(method:String, onCompletion:@escaping([String:Any]) -> Void) {
        
        guard let urlRequest = getRequest(method: method) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let json = data else {
                return
            }
            guard let dictionary = try? JSONSerialization.jsonObject(with: json, options: []) as! [String:Any] else {
                DispatchQueue.main.async {
                    onCompletion([String:Any]())
                }
                return
            }
            DispatchQueue.main.async {
                onCompletion(dictionary)
            }
        }
        task.resume()
    }
    
    func getArray(method:String, onCompletion:@escaping([[String:Any]]) -> Void) {
        
        guard let urlRequest = getRequest(method: method) else {
            return
        }
        
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
    
    func postRequest(method:String, params:[String:Any]) -> URLRequest? {
        
        let base = "https://jsonplaceholder.typicode.com/"
        
        guard let url = URL(string: base+method) else {
            print("Invalid url!")
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            print("Could not parse params as body!")
            return nil
        }
        urlRequest.httpBody = httpBody
        
        return urlRequest
    }
    
    func postDictionary(method:String, params:[String:Any], onCompletion:@escaping(Int) -> Void) {
        
        guard let urlRequest = postRequest(method: method, params: params) else {
            return
        }
        
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
    
}
