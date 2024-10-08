//
//  Day.swift
//  Weather
//
//  Created by Steven Spencer on 8/22/24.
//

import Foundation
import SwiftUI
import Combine
import MapKit

class DayClass: ObservableObject {
    
    func bgImg(dayInt: Int) -> String {
        if dayInt == 1 {
            return "day_sky"
        } else {
            return "night_sky"
        }
    }
}
