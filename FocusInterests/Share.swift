//
//  Share.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/21/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import FacebookShare
import TwitterKit
import FirebaseAuth
import Alamofire
import OhhAuth
import FacebookCore

class Share{
    static func facebookShare(with url: URL, description: String) throws{
        var content = LinkShareContent(url: url)
        content.description = description
        
        let shareDialog = ShareDialog(content: content)
        shareDialog.mode = .native
        shareDialog.completion = { result in
            print(result)
            
        }
        try shareDialog.show()
    }
    
    static func facebookMessage(with url: URL, description: String) throws{
        var content = LinkShareContent(url: url)
        content.description = description
        
        let shareDialog = MessageDialog(content: content)
        shareDialog.completion = { result in
            print(result)
            
        }
        try shareDialog.show()
    }
    
    static func loginTwitter(){
        Twitter.sharedInstance().logIn { session, error in
            if (session != nil)
            {
                print("signed in as \(session!.userName)");
                if (session != nil) {
                    let authToken = session?.authToken
                    let authTokenSecret = session?.authTokenSecret
                    let credential = TwitterAuthProvider.credential(withToken: authToken!, secret: authTokenSecret!)
                    
                    let user = Auth.auth().currentUser
                    
                    user?.link(with: credential, completion: { (user, error) in
                        AuthApi.set(twitterToken: authToken!)
                        AuthApi.set(twitterTokenSecret: authTokenSecret!)
                        
                        if error != nil {
                            // ...
                            return
                        }
                    })
                    
                }
            }
            else
            {
                print("error: \(error!.localizedDescription)");
            }
        }
    }
    
    static func postToTwitter(withStatus text: String){
        if AuthApi.getTwitterToken() != nil{
            let cc = (key: Constants.Twitter.consumerKey, secret: Constants.Twitter.consumerSecret)
            let uc = (key: AuthApi.getTwitterToken()!, secret: AuthApi.gettwitterTokenSecret()!)
            
            var req = URLRequest(url: URL(string: "https://api.twitter.com/1.1/statuses/update.json")!)
            
            let paras = ["status": text]
            
            req.oAuthSign(method: "POST", urlFormParameters: paras, consumerCredentials: cc, userCredentials: uc)
            
            let task = URLSession(configuration: .ephemeral).dataTask(with: req) { (data, response, error) in
                
                if let error = error {
                    print(error)
                }
                else if let data = data {
                    print(String(data: data, encoding: .utf8) ?? "Does not look like a utf8 response :(")
                }
            }
            task.resume()
        }
        
    }
    
    static func getFacebookFriends(){
        let params = ["fields": "id, first_name, last_name, middle_name, name, email, picture"]
        let token = AccessToken(authenticationToken: AuthApi.getFacebookToken()!)
        
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "me/taggable_friends", parameters: params, accessToken: token)) { httpResponse, result in
            switch result {
            case .success(let response):
                //                print("Graph Request Succeeded: \(response)")
                let friends = response.dictionaryValue?["data"] as! [[String : AnyObject]]
                
                for friend in friends{
                    print("\(String(describing: friend["first_name"]!)) \(String(describing: friend["last_name"]!) )")

                    print(String(describing: friend["id"]!))
                }
            case .failed(let error):
                print("Graph Request Failed: \(error)")
            }
        }
        connection.start()
    }
    
    
    static func getUserContacts(email : String){
        var request = URLRequest(url: URL(string: "https://google.com/m8/feeds/contacts/\(email)/full")!)
        request.timeoutInterval = 120.0
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
        
            
        }
        
        task.resume()
    }
}
