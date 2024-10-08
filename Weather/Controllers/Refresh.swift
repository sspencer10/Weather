//
//  Refresh.swift
//  Weather
//
//  Created by Steven Spencer on 8/15/24.
//

import Foundation
import SwiftUI
import MapKit
import WidgetKit

struct Refresh {
    @ObservedObject var rvm: RadarViewModel
    @ObservedObject var viewModel: WeatherViewModel
    @State var thumbnailImage: UIImage? = nil
    var updateCenter = MyWidgetCenter()
    private let interval: TimeInterval = 5 * 60 // 5 minutes in seconds
    
    public static var shared = Refresh(rvm: RadarViewModel(), viewModel: WeatherViewModel())
    
    func canRunFunc() -> Bool {
        let lastRun = UserDefaults.standard.double(forKey: "refreshKey")
        let now = Date().timeIntervalSince1970
        return now - lastRun > interval
    }
    
    func refreshNow() {
        UserDefaults.standard.setValue(true, forKey: "firstView")
        let mapView = MKMapView()
        //viewModel.fetchWeather(filter: 5, location: "current", completion: { _ in })
        viewModel.getHourly(filter: 5, location: "current", completion: { _ in })
        _ = rvm.getTimesURL()
 
        let _: [CachingTileOverlay] = RadarViewModel.shared.loadTileOverlaysFromUserDefaults() ?? []
        let _: Int = RadarViewModel.shared.loadTileOverlaysFromUserDefaults()?.count ?? 1
        let time = rvm.latest_time_storage
        createMapThumbnailWithOverlay(time: time, mapView: mapView) { image in
            thumbnailImage = image
        }
        WidgetCenter.shared.reloadAllTimelines()
        //print("last update \(viewModel.last_update)")
    }
    
    func willRefresh() {
        if canRunFunc() {
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "refreshKey")
            let mapView = MKMapView()
            //print("refresh")
            _ = rvm.getTimesURL()
            WidgetCenter.shared.reloadAllTimelines()
            WeatherViewModel().fetchWeather(filter: 5, location: "current", completion: { _ in })
            //print(RadarViewModel().getOverlayUrls())
            let _: [CachingTileOverlay] = RadarViewModel.shared.loadTileOverlaysFromUserDefaults() ?? []
            let _: Int = RadarViewModel.shared.loadTileOverlaysFromUserDefaults()?.count ?? 1
            let time = rvm.latest_time_storage
            createMapThumbnailWithOverlay(time: time, mapView: mapView) { image in
                thumbnailImage = image
            }
        }
    }
    
}
