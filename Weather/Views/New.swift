import SwiftUI
import MapKit

struct NewView: View {
    @StateObject var rvm = RadarViewModel()
    let mapStyles: [MKMapType] = [.hybrid, .hybridFlyover, .mutedStandard, .satellite, .satelliteFlyover, .standard]
    @State var coordinate = CLLocationCoordinate2D?(CLLocationCoordinate2D.init(latitude: 0.0, longitude: 0.0))

    
    @State private var mapView = RadarMapView(mapStyle:  [.hybrid, .hybridFlyover, .mutedStandard, .satellite, .satelliteFlyover, .standard][1], overlay: RadarViewModel().overlays[Int(UserDefaults.standard.double(forKey: "timeIndex"))], lm: LocationManager(), wvm: WeatherViewModel(), rvm: RadarViewModel())
    var body: some View {
        VStack {
            mapView
            HStack {
                Button(action: {
                    mapView.clearCache()
                }) {
                    Text("Clear Cache")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                Button(action: {
                    mapView.disableCaching()
                }) {
                    Text("Disable Caching")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                Button(action: {
                    mapView.enableCaching()
                }) {
                    Text("Enable Caching")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
    }
}

