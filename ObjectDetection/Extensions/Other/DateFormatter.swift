//
//  DateFormatter.swift
//  HauteCurator
//
//  Created by LShiva on 1/28/19.
//  Copyright © 2019 What3words. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    // MARK: - Public methods
    
    static func fullDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }
    
    static func hoursMinutesDateFormatter() -> DateFormatter {
        let hoursMinutesFormatter = DateFormatter()
        hoursMinutesFormatter.dateFormat = "HH:mm"
        return hoursMinutesFormatter
    }
    
    static func dayMonthDateFormatter() -> DateFormatter {
        let dayMonthDateFormatter = DateFormatter()
        dayMonthDateFormatter.dateFormat = "EEEE, MMMM dd"
        return dayMonthDateFormatter
    }
    
}
