//
//  InterestListViewController.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 4/3/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

protocol InterestPickerDelegate {
    func add(interests: [Interest])
}

class InterestListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var fakeNavBar: UIView!
    
    var delegate: InterestPickerDelegate?
    var user: FocusUser?
    var choices = [Interest]()
    var interests = [Interest]()
    let dictionary = FirebaseDownstream.shared.giantInterestMap
    var container = [([Interest]?, String)]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "interestCellChoice")
        
        titleLabel.font = UIFont(name: "Futura", size: 20)
        titleLabel.text = "Interests"
        
        let buttonFont = UIFont(name: "Futura", size: 17)
        let attr = [NSForegroundColorAttributeName:UIColor.white]
        let str = NSAttributedString(string: "Confirm", attributes: attr)
        confirmButton.titleLabel?.font = buttonFont!
        confirmButton.setAttributedTitle(str, for: .normal)
        
        fakeNavBar.backgroundColor = UIColor.primaryGreen()
        
        
        for (k,v) in dictionary {
            let tuple = (v as? [Interest],k)
            container.append(tuple)
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confirmInterests(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dictionary.keys.count
    }
    
    // TableViewDatasource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "interestCellChoice")
        if let name = container[indexPath.section].0?[indexPath.row] {
            cell?.textLabel?.text = name.name!
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let arr = container[section].0 {
            return arr.count
        }
        return 0
    }
    
    // TableViewDelegate
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.primaryGreen()
        let label = UILabel(frame: CGRect(x: 50, y: 5, width: self.view.frame.width - 100, height: 40))
        label.font = UIFont(name: "Futura", size: 19)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.text = container[section].1
        view.addSubview(label)
        return view
    }
}
