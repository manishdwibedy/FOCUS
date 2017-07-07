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
import SwiftyJSON

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
        let params = ["fields": "friends{picture, name}"]
        if let token = AuthApi.getFacebookToken(){
            let accessToken = AccessToken(authenticationToken: token)
            
            let connection = GraphRequestConnection()
            connection.add(GraphRequest(graphPath: "me", parameters: params, accessToken: accessToken)) { httpResponse, result in
                switch result {
                case .success(let response):
                    let friends = response.dictionaryValue?["friends"] as! [String : Any]
                    
                    var friend_info = [[String:String]]()
                    for friend in (friends["data"] as? [[String:Any]])!{
                        let name = friend["name"] as? String
                        var picture_url = ""
                        if let picture = friend["picture"] as? [String:Any]{
                            if let data = picture["data"] as? [String:Any]{
                                picture_url = (data["url"] as? String)!
                            }
                        }
                        
                        friend_info.append([
                            "name": name!,
                            "image": picture_url
                            ])
                        //                    print("\(String(describing: friend["first_name"]!)) \(String(describing: friend["last_name"]!) )")
                        //
                        //                    print(String(describing: friend["id"]!))
                    }
                    print(friend_info)
                case .failed(let error):
                    print("Graph Request Failed: \(error)")
                }
            }
            connection.start()
        }
        
    }
    
    
    static func getUserContacts(email : String, completion: @escaping ([[String:String]])->Void){
        if let token = AuthApi.getGoogleToken(){
            var url = URL(string: "https://www.google.com/m8/feeds/contacts/default/thin?max-results=10000&alt=json")
            
            var users = [[String:String]]()
            let headers: HTTPHeaders = [
                "authorization": "Bearer \(token)",
                "GData-Version": "3.0"
            ]
            
            Alamofire.request(url!, method: .get, parameters:nil, headers: headers).responseJSON { response in
                let json = JSON(data: response.data!)
                
                let userData = json["feed"]["entry"]
                
                if let userData = userData.array{
                    for user in userData{
                        let name = user["title"]["$t"].stringValue
                        let email = user["gd$email"][0]["address"].stringValue
                        let image = user["link"][0]["href"].stringValue
                        
                        users.append([
                            "name": name,
                            "email": email,
                            "image": image
                            ])
                    }
                    completion(users)
                }
                
                
            }
        }
        
    }
}
