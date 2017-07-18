//
//  DateFormatter+Extensions.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/9/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation

extension DateFormatter {
    /**
     Formats a date as the time since that date (e.g., “Last week, yesterday, etc.”).
     
     - Parameter from: The date to process.
     - Parameter numericDates: Determines if we should return a numeric variant, e.g. "1 month ago" vs. "Last month".
     
     - Returns: A string with formatted `date`.
     */
    func timeSince(from: Date, numericDates: Bool = false, shortVersion: Bool = true) -> String {
        let calendar = Calendar.current
        let now = NSDate()
        
        let earliest = now.earlierDate(from as Date)
        let latest = earliest == now as Date ? from : now as Date
        let components = calendar.dateComponents([.year, .weekOfYear, .month, .day, .hour, .minute, .second], from: earliest, to: latest as Date)
        
        var result = ""
        
        if components.year! >= 2 {
            result = shortVersion ? "\(components.year!)y":"\(components.year!) years"
        } else if components.year! >= 1 {
            if numericDates {
                result =  shortVersion ? "1y": "1 year"
            } else {
                result = "Last year"
            }
        } else if components.month! >= 2 {
            result = shortVersion ? "\(components.month!)mo": "\(components.month!) months"
        } else if components.month! >= 1 {
            if numericDates {
                result = shortVersion ? "1mo":"1 month"
            } else {
                result = "Last month"
            }
        } else if components.weekOfYear! >= 2 {
            result = shortVersion ? "\(components.weekOfYear!)w":"\(components.weekOfYear!) weeks"
        } else if components.weekOfYear! >= 1 {
            if numericDates {
                result = shortVersion ? "1w": "1 week"
            } else {
                result = "Last week"
            }
        } else if components.day! >= 2 {
            result = shortVersion ? "\(components.day!)d":"\(components.day!) days"
        } else if components.day! >= 1 {
            if numericDates {
                result = shortVersion ? "1d": "1 day"
            } else {
                result = "Yesterday"
            }
        } else if components.hour! >= 2 {
            result = shortVersion ? "\(components.hour!)h": "\(components.hour!) hours"
        } else if components.hour! >= 1 {
            if numericDates {
                result = shortVersion ? "1h":"1 hour"
            } else {
                result = "An hour"
            }
        } else if components.minute! >= 2 {
            result = shortVersion ? "\(components.minute!)m":"\(components.minute!) minutes"
        } else if components.minute! >= 1 {
            if numericDates {
                result = shortVersion ? "1m":"1 minute"
            } else {
                result = "A minute"
            }
        } else if components.second! >= 3 {
            result = shortVersion ? "\(components.second!)s": "\(components.second!) seconds"
        } else {
            result = "Just now"
        }
        
        return result
    }
}
