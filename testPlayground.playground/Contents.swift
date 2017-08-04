//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


let dateFormatter = DateFormatter()
dateFormatter.timeZone = NSTimeZone.default
dateFormatter.dateFormat = "MM/dd/yy, hh:mm a"

let currentDate = Date()
print(currentDate) // 2015-11-13 22:02:09 +0000
let dateString = dateFormatter.string(from: currentDate as Date)
print(dateString) // 11/13/15, 05:02 PM
let newDate = dateFormatter.date(from: dateString)
print(newDate)



let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mm a"
    dateFormatter.calendar = NSCalendar.current
    dateFormatter.timeZone = TimeZone.current

    let dt = dateFormatter.date(from: date)
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    dateFormatter.dateFormat = "H:mm:ss"

    return dateFormatter.string(from: dt!)
