//
//  ChooseInterestsCell.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/25/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class ChooseInterestsCell: UITableViewCell {

    @IBOutlet private weak var collectionView: UICollectionView!
    
    var interests: [Interest]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundView?.backgroundColor = UIColor.primaryGreen()
        let cellNib = UINib(nibName: "CellCollectionCellCollectionViewCell", bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: Constants.tableCellReuseIDs.collectionCellId)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D, forRow row: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.reloadData()
    }
    
    // CollectionView datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (interests?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.tableCellReuseIDs.collectionCellId, for: indexPath) as? CellCollectionCellCollectionViewCell
        cell?.label.text = interests?[indexPath.row].name!
        return cell!
    }
    
}
