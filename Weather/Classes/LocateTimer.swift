//
//  LocateTimer.swift
//  Weather
//
//  Created by Steven Spencer on 8/2/24.
//

import SwiftUI
import Combine

class LocateTimer: ObservableObject {
    @Published var timerDone: Bool = false

    func startTimer(duration: TimeInterval) {
        //print("timer - started")
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.timerDone = true
            //print("timer - finished")
            RadarMap(touchMap: false).center = false
        }
    }
}
