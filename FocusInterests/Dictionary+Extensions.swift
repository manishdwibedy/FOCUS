//
//  Dictionary+Extensions.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/13/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}
