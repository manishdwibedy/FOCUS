//
//  MessagesLoadEarlierHeaderView.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/7/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import JSQMessagesViewController

extension JSQMessagesLoadEarlierHeaderView {
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        loadButton.setTitle("Load More", for: .normal)
        self.backgroundColor = UIColor.lightGray
    }
}
