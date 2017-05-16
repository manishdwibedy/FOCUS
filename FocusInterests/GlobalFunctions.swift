//
//  GlobalFunctions.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

func featuresToString(features: [Feature]) -> String {
    var strArray = [String]()
    for f in features {
        strArray.append(f.featureName!)
    }
    let joinedStr = strArray.joined(separator: ", ")
    return joinedStr
}

func getYelpToken(completion: @escaping (_ result: String) -> Void){
    let url = "https://api.yelp.com/oauth2/token"
    let parameters: [String: String] = [
        "client_id" : "vFAIR9-9TE52_DCWXHrXew",
        "client_secret" : "Bb3UszmDi1zoFMsWqhnodGrOhK3s8SBKaV6SK2gdn3sE3txhVOxSjGHdcFsitovD",
        "grant_type": "client_credentials"
        
        
    ]
    
    let headers: HTTPHeaders = [
        "content-type": "application/x-www-form-urlencoded",
        "cache-contro": "no-cache"
    ]
    
    Alamofire.request(url, method: .post, parameters:parameters, headers: headers).responseJSON { response in
        let json = JSON(data: response.data!)
        let token = json["access_token"].stringValue
        
        AuthApi.set(yelpAccessToken: token)
        
        completion(token)
        
    }
}
