//
//  nums.swift
//  Weather
//
//  Created by Steven Spencer on 8/10/24.
//

import Foundation

class nums: ObservableObject {

    var one: Int = 1
    var one1: Int = 0
    
    var two: Int = 0
    var two1: Int = 0
    
    var three: Int = 0
    var three1: Int = 0
    
    var four: Int = 0
    var four1: Int = 0
    
    var five: Int = 0
    var five1: Int = 0
    
    let theHour = Calendar.current.component(.hour, from: Date())

    


    
    func setInt() {
        let h = theHour
        //print("theHour: \(h)")
        if (h + 1 < 24) {one = 0} else {one = 1}
        if (h + 1 < 24) {one1 = h + 1} else {one1 = (h + 1) - 24}
        
        if (h + 2 < 24) {two = 0} else {two = 1}
        if (h + 2 < 24) {two1 = h + 2} else {two1 = (h + 2) - 24}
        
        if (h + 3 < 24) {three = 0} else {three = 1}
        if (h + 3 < 24) {three1 = h + 3} else {three1 = (h + 3) - 24}
        
        if (h + 4 < 24) {four = 0} else {four = 1}
        if (h + 4 < 24) {four1 = h + 4} else {four1 = (h + 4) - 24}
        
        if (h + 5 < 24) {five = 0} else {one = 1}
        if (h + 5 < 24) {five1 = h + 5} else {five1 = (h + 5) - 24}
        //print("\(one), \(two), \(three), \(four), \(five), \(one1), \(two1), \(three1), \(four1), \(five1)")
    }
    
    
    func hourConv(x: Int) -> String {
        let newHour: Int = theHour + x
        var ampm: String = "am"
        var realHour: Int = 0
        if (newHour > 12 && newHour < 24) {
            ampm = "pm"
            realHour = newHour - 12
        }
        if (newHour > 23) {
            ampm = "am"
            realHour = newHour - 24
            if (realHour == 0) {
                realHour = 12
            }
        }
        return "\(realHour) \(ampm)"
    }
    

}
