import CoreLocation
import SwiftUI
import MapKit

class Coordinator: NSObject, MKMapViewDelegate {
    @AppStorage("latest_time_storage", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var latest_time_storage: Int = 0
    @AppStorage("tile", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var tile: String = ""
    
    var parent: RadarMapView

    init(_ parent: RadarMapView) {
        self.parent = parent
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
                if let tileOverlay = overlay as? MKTileOverlay {
                    return MKTileOverlayRenderer(overlay: tileOverlay)
                }
                return MKOverlayRenderer(overlay: overlay)
            }
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        let touchPoint = gestureRecognizer.location(in: gestureRecognizer.view)
        let mapView = gestureRecognizer.view as! MKMapView
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)

        // Pass the coordinate back to the SwiftUI view
        parent.coordinate = touchCoordinate

    }
    

    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //print("region changed")
        _ = mapView.region
        let coordinateRegion = MKCoordinateRegion(center: mapView.region.center, span: mapView.region.span)
        mapView.setRegion(coordinateRegion, animated: true)
        //print(mapView.region.span)
        _ = mapView.calculateTileCoordinates(z: getZoomLevel(mapView: mapView))
        let tileUrl = "https://tilecache.rainviewer.com/v2/radar/\(latest_time_storage)/256/\(getZoomLevelInt(mapView: mapView))/\(coordinateRegion.center.latitude)/\(coordinateRegion.center.longitude)/7/1_1.png"
        tile = tileUrl
        //print ("span: \(getCoordinateSpan(zoomLevel: getZoomLevel(mapView: mapView), mapView: mapView))")
        //print(getZoomLevel(mapView: mapView))
        //print(tileUrl)
    }
    func getZoomLevel(mapView: MKMapView) -> Double {
        let region = mapView.region
        let span = region.span
        // Calculate the zoom level
        let zoomLevel = log2(360 * (Double(mapView.frame.size.width) / 256) / span.longitudeDelta)
        return zoomLevel
    }
    
    func getZoomLevelInt(mapView: MKMapView) -> Int {
        let region = mapView.region
        let span = region.span
        // Calculate the zoom level
        let zoomLevel = log2(360 * (Double(mapView.frame.size.width) / 256) / span.longitudeDelta)
        return Int(round(zoomLevel))
    }
    func getCoordinateSpan(zoomLevel: Double, mapView: MKMapView) -> (Int, CGFloat) {
        let frameSize = Double(mapView.frame.size.width)
        let longitudeDelta = 360 / pow(2, 7) * (256 / frameSize)
        _ = MKCoordinateSpan(latitudeDelta: longitudeDelta, longitudeDelta: longitudeDelta)
        //print("span\(span)")
        //
        
        let span2 = (0, 360/pow(2, 7.0)*mapView.frame.size.width/256);
        //print(span2)
        return span2
    }

    
}
