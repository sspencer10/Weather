//
//  DateExtensions.swift
//  Weatherly
//
//  Created by Steven Spencer on 10/2/24.
//

// DateExtensions.swift
import Foundation

extension Date {
    func hour() -> Int {
        return Calendar.current.component(.hour, from: self)
    }
}
