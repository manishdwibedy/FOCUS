//
//  CommentsViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/7/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var addCommentView: UIView!
    @IBOutlet weak var postButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let commentsNib = UINib(nibName: "CommentsTableViewCell", bundle: nil)
        self.commentsTableView.register(commentsNib, forCellReuseIdentifier: "commentsCell")
        
        self.addCommentView.layer.borderWidth = 2
        self.addCommentView.layer.borderColor = UIColor.white.cgColor
        self.addCommentView.allCornersRounded(radius: 5.0)
        self.postButton.roundCorners(radius: 5.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        print("you are loading cell now")
        let followersCell = tableView.dequeueReusableCell(withIdentifier: "commentsCell", for: indexPath) as! CommentsTableViewCell
        
        return followersCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
