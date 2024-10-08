//
//  WidgetClass.swift
//  Weather
//
//  Created by Steven Spencer on 7/30/24.
//

import Foundation
import Foundation
import SwiftUI

class WidgetClass: ObservableObject {
    @ObservedObject var wvm = WeatherViewModel()
    @AppStorage("current_icon", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var current_icon: String = ""
    @Published var dataImg: Data?
    
    init() {
        print(fetchIcon())
    }


    func fetchIcon() -> Data {
                if let url = URL(string: WeatherViewModel().current_icon) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    self.dataImg = UIImage(data: data)?.pngData() ?? Data()
                }

            }
        }
        return dataImg ?? Data()
    }
}
