//
//  MyWidgetCenter.swift
//  Steps
//
//  Created by Steven Spencer on 6/15/24.
//

import Foundation
import WidgetKit
import SwiftUI

class MyWidgetCenter: ObservableObject {
    
    public static var shared = MyWidgetCenter()
   
    func reloadAllTimelines() {
        WidgetCenter.shared.reloadAllTimelines()
        print("reloaded all timelines")
    }

}
