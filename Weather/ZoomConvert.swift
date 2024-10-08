import MapKit
import SwiftUI

class ZoomConvert: ObservableObject {
    
    @ObservedObject var rv = RadarViewModel()
    @ObservedObject var lm = LocationManager()
    var zoomLevel2: Int?
    var centerCoordinate2: CLLocationCoordinate2D?
    var lonDelta: Decimal?
    var latDelta: Decimal?
    var mapView2: MKMapView?

    //func coordinateSpan(lat: Double?, lon: Double?, zoom: Int?) {

}
