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
        
        //self.getFacebookFriends()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getContacts() {
        let store = CNContactStore()
        
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {

            
            store.requestAccess(for: CNEntityType.contacts) { (isGranted, error) in
                self.retrieveContactsWithStore(store: store)
            }

        } else if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            self.retrieveContactsWithStore(store: store)
        }
    }

    func retrieveContactsWithStore(store: CNContactStore) {
//        do {
        
            let contactStore = CNContactStore()
            let keys = [CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactNicknameKey, CNContactPhoneNumbersKey, CNContactImageDataKey]
            let request1 = CNContactFetchRequest(keysToFetch: keys  as [CNKeyDescriptor])
            
//            try? contactStore.enumerateContacts(with: request1) { (contact, error) in
//                
//            }
//        } catch {
//            print(error)
//        }
    }
    
}
