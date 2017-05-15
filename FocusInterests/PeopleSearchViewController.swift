//
//  PeopleSearchViewController.swift
//  
//
//  Created by Manish Dwibedy on 5/14/17.
//
//

import UIKit

class PeopleSearchViewController: UIViewController, NavigationInteraction {

    @IBOutlet weak var navigation: MapNavigationView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigation.backgroundColor = UIColor.black
        navigation.showSearchBar = false
        navigation.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userProfileClicked() {
        let VC:UIViewController = UIStoryboard(name: "people", bundle: nil).instantiateViewController(withIdentifier: "Home") as! UITabBarController
        
        self.present(VC, animated:true, completion:nil)
    }
    
    func messagesClicked() {
        let VC:UIViewController = UIStoryboard(name: "Messages", bundle: nil).instantiateViewController(withIdentifier: "Home") as! UINavigationController
        
        self.present(VC, animated:true, completion:nil)
    }
    
    func notificationsClicked() {
        let vc = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        self.present(vc, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
