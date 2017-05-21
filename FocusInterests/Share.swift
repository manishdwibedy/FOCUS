//
//  Share.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import TwitterKit
import FirebaseAuth
import Alamofire
import OhhAuth


func loginWithTwitter(){
    Twitter.sharedInstance().logIn { session, error in
        if (session != nil)
        {
            print("signed in as \(session!.userName)");
            if (session != nil) {
                let authToken = session?.authToken
                let authTokenSecret = session?.authTokenSecret
                let credential = FIRTwitterAuthProvider.credential(withToken: authToken!, secret: authTokenSecret!)
                
                let user = FIRAuth.auth()?.currentUser
                
                user?.link(with: credential, completion: { (user, error) in
                    if let error = error {
                        // ...
                        return
                    }
                    AuthApi.set(twitterToken: authToken!)
                    AuthApi.set(twitterTokenSecret: authTokenSecret!)
                })
                
            }
        }
        else
        {
            print("error: \(error!.localizedDescription)");
        }
    }
}

func postToTwitter(withStatus text: String){
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
