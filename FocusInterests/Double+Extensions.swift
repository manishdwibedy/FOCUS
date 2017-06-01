//
//  Double+Extensions.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 6/1/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
