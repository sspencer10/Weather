//
//  AlertsModel.swift
//  Weather
//
//  Created by Steven Spencer on 8/26/24.
//

import Foundation
struct AlertsResponse: Codable {
    let alerts: [WeatherAlert]
}

struct WeatherAlert: Codable, Identifiable {
    var id: UUID { UUID() }
    let description: String
    let effective_local: String
    let ends_local: String
    let regions: [String]
}
