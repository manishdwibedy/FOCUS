//
//  InterestsPickerViewController.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/23/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class InterestsPickerViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var fakeNavBarView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    
    var fakeTabBar = [UIButton]()
    var tablePopulator = [["category" : InterestCategory.Sports, "interests" : [Constants.interests.basketball, Constants.interests.football, Constants.interests.soccer]], ["category" : InterestCategory.Art, "interests" : [Constants.interests.music, Constants.interests.modernArt, Constants.interests.museums]], ["category" : InterestCategory.Nightlife, "interests" : [Constants.interests.bars, Constants.interests.clubs, Constants.interests.events]], ["category" : InterestCategory.Food, "interests" : [Constants.interests.french, Constants.interests.italian, Constants.interests.mexican]], ["category" : InterestCategory.Shopping, "interests" : [Constants.interests.clothing, Constants.interests.electronics, Constants.interests.furniture]]]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "ChooseInterestsCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: Constants.tableCellReuseIDs.chooseInterestId)
        
        segmentedController.backgroundColor = UIColor.primaryGreen()
        segmentedController.tintColor = UIColor.white
        
        fakeTabBar = [button1, button2, button3, button4, button5]
        for button in fakeTabBar {
            button.setTitleColor(UIColor.white, for: .normal)
            button.setTitleColor(UIColor.darkGray, for: .selected)
        }
        
        fakeNavBarView.backgroundColor = UIColor.primaryGreen()
        submitButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        
        tableView.delegate = self
        
        let userIm = UIImage(named: "userunfilled")
        let mailIm = UIImage(named: "mail")
        let worldIm = UIImage(named: "world")
        let lockIm = UIImage(named: "lock")
        let searchIm = UIImage(named: "search-1")
        let tUser = userIm?.withRenderingMode(.alwaysTemplate)
        let tMail = mailIm?.withRenderingMode(.alwaysTemplate)
        let tWorld = worldIm?.withRenderingMode(.alwaysTemplate)
        let tLock = lockIm?.withRenderingMode(.alwaysTemplate)
        let tSearch = searchIm?.withRenderingMode(.alwaysTemplate)
        button1.setImage(tUser, for: .normal)
        button1.tintColor = UIColor.white
        button2.setImage(tMail, for: .normal)
        button2.tintColor = UIColor.white
        button3.setImage(tWorld, for: .normal)
        button3.tintColor = UIColor.white
        button4.setImage(tLock, for: .normal)
        button4.tintColor = UIColor.white
        button5.setImage(tSearch, for: .normal)
        button5.tintColor = UIColor.white
        
    }

    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSubmit(_ sender: Any) {
        print("will submit")
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
    }
    
    @IBAction func button1Tapped(_ sender: Any) {
        print("button1tapped")
    }
    
    @IBAction func button2Tapped(_ sender: Any) {
        print("button2tapped")
    }
    
    @IBAction func button3Tapped(_ sender: Any) {
        print("button3tapped")
    }
    
    @IBAction func button4Tapped(_ sender: Any) {
        print("button4tapped")
    }
    
    @IBAction func button5Tapped(_ sender: Any) {
        print("button5tapped")
    }
    
    // TableView Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return tablePopulator.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.tableCellReuseIDs.chooseInterestId) as? ChooseInterestsCell
        cell?.selectionStyle = .none
        return cell!
    }
    
    // TableViewDelegate
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? ChooseInterestsCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hView = UIView()
        hView.backgroundColor = UIColor.primaryGreen()
        let label = UILabel(frame: CGRect(x: 20, y: hView.frame.midY, width: 200, height: 35))
        label.textColor = UIColor.white
        label.font = UIFont(name: "Futura", size: 20)
        hView.addSubview(label)
        let addBtn = UIButton(frame: CGRect(x: self.view.frame.width - 50, y: 5, width: 30, height: 30))
        let oImage = UIImage(named: "plus")
        let tImage = oImage?.withRenderingMode(.alwaysTemplate)
        addBtn.tintColor = UIColor.white
        addBtn.setImage(tImage!, for: .normal)
        addBtn.addTarget(self, action: #selector(InterestsPickerViewController.addInterest), for: .touchUpInside)
        hView.addSubview(addBtn)
        let dict = tablePopulator[section]
        let enm = dict["category"] as? InterestCategory
        label.text = String(describing: enm!)
        return hView
    }
    
    func addInterest() {
        print("Button # )")
    }
    
    // CollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dict =  tablePopulator[collectionView.tag]
        let arr = dict["interests"] as? [Interest]
        return arr!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.tableCellReuseIDs.collectionCellId, for: indexPath) as? CellCollectionCellCollectionViewCell
        print("collectionview.tag: \(collectionView.tag)")
        let dict = tablePopulator[collectionView.tag]
        let arr = dict["interests"] as? [Interest]
        cell?.configure(interest: (arr![indexPath.row]))
        return cell!
    }
    
    // CollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellsAcross: CGFloat = 1
        let spaceBetweenCells: CGFloat = 1
        let dim = (collectionView.bounds.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
        print(indexPath.row)
        return CGSize(width: (dim / 3) - 7, height: dim / 2)
        
    }

}
