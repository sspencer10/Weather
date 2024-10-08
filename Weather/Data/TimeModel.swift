import Foundation

struct TimeData: Codable {
    let version: String
    let generated: Int
    let host: String
    let radar: Radar
    let satellite: Satellite

    struct Radar: Codable {
        let past: [RadarData]
        let nowcast: [RadarData]
        
        struct RadarData: Codable {
            let time: Int
            let path: String
        }
    }

    struct Satellite: Codable {
        let infrared: [SatelliteData]
        
        struct SatelliteData: Codable {
            let time: Int
            let path: String
        }
    }
}
