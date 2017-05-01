//
//  GlobalFunctions.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation

func featuresToString(features: [Feature]) -> String {
    var strArray = [String]()
    for f in features {
        strArray.append(f.featureName!)
    }
    let joinedStr = strArray.joined(separator: ", ")
    return joinedStr
}
