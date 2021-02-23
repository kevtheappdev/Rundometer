//
//  Extensions.swift
//  Rundometer
//
//  Created by Kevin Turner on 2/22/21.
//

import Foundation

extension Date {
    static func beginningOfCurrentYear() -> Date {
        let calendar = Calendar.current
        let yearComponent = calendar.component(.year, from: Date())
        let components = DateComponents(year: yearComponent, month: 1, day: 1)
        
        guard let startOfYear = calendar.date(from: components) else {
            fatalError("Failed to compute start of year")
        }
        return startOfYear
    }
    
    static func beginningOfCurrentMonth() -> Date {
        let calendar = Calendar.current
        let currentDate = Date()
        let yearComponenet = calendar.component(.year, from: currentDate)
        let monthComponent = calendar.component(.month, from: currentDate)
        let components = DateComponents(year: yearComponenet, month: monthComponent, day: 1)
        
        guard let startOfMonth = calendar.date(from: components) else {
            fatalError("Failed to compute start of month")
        }
        return startOfMonth
    }
}
