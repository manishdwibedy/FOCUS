//
//  InvitationViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/3/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Contacts
import FacebookCore

class InvitationViewController: UIViewController {

    var objects: [CNContact]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.getContacts()
        
        self.getFacebookFriends()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getContacts() {
        let store = CNContactStore()
        
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {

            
            store.requestAccess(for: CNEntityType.contacts) { (isGranted, error) in
                print(isGranted)
                print(error)
                self.retrieveContactsWithStore(store: store)
            }

        } else if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            self.retrieveContactsWithStore(store: store)
        }
    }

    func retrieveContactsWithStore(store: CNContactStore) {
        do {
            
            let contactStore = CNContactStore()
            let keys = [CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactNicknameKey, CNContactPhoneNumbersKey, CNContactImageDataKey]
            let request1 = CNContactFetchRequest(keysToFetch: keys  as [CNKeyDescriptor])
            
            try? contactStore.enumerateContacts(with: request1) { (contact, error) in
                print("\(contact.givenName) \(contact.familyName)")
                print(contact.phoneNumbers)
                print(contact.imageData)
            }
        } catch {
            print(error)
        }
    }
    
    func getFacebookFriends(){
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
}
