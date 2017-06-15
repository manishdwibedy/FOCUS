//
//  GeneralSearchViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/15/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class GeneralSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var specificLocationSearchBar: UISearchBar!
    @IBOutlet weak var currentLocationSearchBar: UISearchBar!
    @IBOutlet weak var generalSearchTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let generalSearchNib = UINib(nibName: "GeneralSearchCellTableViewCell", bundle: nil)
        self.generalSearchTableView.register(generalSearchNib, forCellReuseIdentifier: "generalSearchCell")
//        UISearchBar.appearance().setImage(UIImage(named: "new_search_icon"), forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal)
    self.currentLocationSearchBar.image(for: ., state: <#T##UIControlState#>)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.generalSearchTableView.dequeueReusableCell(withIdentifier: "generalSearchCell", for: indexPath) as! GeneralSearchCellTableViewCell
        cell.searchChoiceLabel.text = "Restaurant"
        return cell
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
