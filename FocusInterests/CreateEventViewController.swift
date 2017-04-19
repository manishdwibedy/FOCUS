//
//  CreateEventViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 4/18/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController {

    @IBOutlet weak var when: UITextField!
    var event: Event?
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Create Pin"
        showDateTime()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createPin(_ sender: UIButton) {
        self.event = Event(title: "Dummy", description: "desc", place: "2656 Ellendale Pl. ", date: Date(), time: "8:00PM" )
    }

    func showDateTime(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dateTimeSelected))
        toolbar.setItems([done], animated: false)
        when.inputAccessoryView = toolbar
        when.inputView = datePicker
        
    }
    
    func dateTimeSelected(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"

        self.when.text = "\(dateFormatter.string(from: self.datePicker.date))"
        self.view.endEditing(true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_event"{
            let destinationVC = segue.destination as! MapViewController
            destinationVC.createdEvent = self.event
        }
    }
}
