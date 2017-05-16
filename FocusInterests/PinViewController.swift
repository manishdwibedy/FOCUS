//
//  PinViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/16/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class PinViewController: UIViewController {
    var place: Place?
    @IBOutlet weak var interestStackView: UIStackView!
    
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    @IBOutlet weak var streetAddress: UILabel!
    
    @IBOutlet weak var hoursStackView: UIStackView!
    
    @IBOutlet weak var infoScreenHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for (index, category) in (self.place?.categories.enumerated())!{
            let textLabel = UILabel()
            
            if index == 0{
                textLabel.textColor = UIColor.green
            }
            
            textLabel.text  = category.name
            textLabel.textAlignment = .center
            
            interestStackView.addArrangedSubview(textLabel)
            interestStackView.translatesAutoresizingMaskIntoConstraints = false;
        }
        streetAddress.text = place?.address[0]
        cityStateLabel.text = place?.address[1]
        phoneLabel.text = place?.phone
        
        
        let hours = getOpenHours((place?.hours)!)
        infoScreenHeight.constant += CGFloat(20 * hours.count)
        
        for (_, hour) in (hours.enumerated()){
            let textLabel = UILabel()
        
            textLabel.text  = hour
            textLabel.textAlignment = .left
            
            hoursStackView.addArrangedSubview(textLabel)
            hoursStackView.translatesAutoresizingMaskIntoConstraints = false;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
