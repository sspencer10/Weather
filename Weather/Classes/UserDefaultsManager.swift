//
//  UserDefaultsManager.swift
//  Weather
//
//  Created by Steven Spencer on 10/4/24.
//

import Foundation
import SwiftUI

class UserDefaultsManager: ObservableObject {
    @Published var color: Int = UserDefaults.standard.integer(forKey: "radarColor")

    private var observation: NSKeyValueObservation?

    init() {
        // Add observer for UserDefaults changes
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(radarColorChanged),
                                               name: UserDefaults.didChangeNotification,
                                               object: nil)
      
    }
    
    @objc private func radarColorChanged(notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.color = UserDefaults.standard.integer(forKey: "radarColor")
        }
    }
  
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
