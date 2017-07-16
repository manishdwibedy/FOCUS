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
            result = shortVersion ? "\(components.year!)y ago":"\(components.year!) years ago"
        } else if components.year! >= 1 {
            if numericDates {
                result =  shortVersion ? "1y ago": "1 year ago"
            } else {
                result = "Last year"
            }
        } else if components.month! >= 2 {
            result = shortVersion ? "\(components.month!)mo ago": "\(components.month!) months ago"
        } else if components.month! >= 1 {
            if numericDates {
                result = shortVersion ? "1mo ago":"1 month ago"
            } else {
                result = "Last month"
            }
        } else if components.weekOfYear! >= 2 {
            result = shortVersion ? "\(components.weekOfYear!)w ago":"\(components.weekOfYear!) weeks ago"
        } else if components.weekOfYear! >= 1 {
            if numericDates {
                result = shortVersion ? "1w ago": "1 week ago"
            } else {
                result = "Last week"
            }
        } else if components.day! >= 2 {
            result = shortVersion ? "\(components.day!)d ago":"\(components.day!) days ago"
        } else if components.day! >= 1 {
            if numericDates {
                result = shortVersion ? "1d ago": "1 day ago"
            } else {
                result = "Yesterday"
            }
        } else if components.hour! >= 2 {
            result = shortVersion ? "\(components.hour!)h ago": "\(components.hour!) hours ago"
        } else if components.hour! >= 1 {
            if numericDates {
                result = shortVersion ? "1h ago":"1 hour ago"
            } else {
                result = "An hour ago"
            }
        } else if components.minute! >= 2 {
            result = shortVersion ? "\(components.minute!)m ago":"\(components.minute!) minutes ago"
        } else if components.minute! >= 1 {
            if numericDates {
                result = shortVersion ? "1m ago":"1 minute ago"
            } else {
                result = "A minute ago"
            }
        } else if components.second! >= 3 {
            result = shortVersion ? "\(components.second!)s ago": "\(components.second!) seconds ago"
        } else {
            result = "Just now"
        }
        
        return result
    }
}
