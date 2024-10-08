//
//  RadarAPI.swift
//  Weather
//
//  Created by Steven Spencer on 7/26/24.
//

import Foundation

struct TileOverlayConfig: Codable {
    let urlTemplate: String?
    let tileSize: CGSize
    let minimumZ: Int
    let maximumZ: Int
}
