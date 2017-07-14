//
//  Character+Extensions.swift
//  FocusInterests
//
//  Created by Nicolas on 14/07/2017.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation

extension Character {
    var isUppercase: Bool {
        let str = String(self)
        return str.isUppercased(at: str.startIndex)
    }
}
