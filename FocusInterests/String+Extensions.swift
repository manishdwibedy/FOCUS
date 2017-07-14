//
//  String+Extensions.swift
//  FocusInterests
//
//  Created by Nicolas on 14/07/2017.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation

extension String {
    func isUppercased(at: Index) -> Bool {
        let range = at..<self.index(after: at)
        return self.rangeOfCharacter(from: .uppercaseLetters, options: [], range: range) != nil
    }
}
