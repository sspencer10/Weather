import SwiftUI
import MapKit

struct ContentView2: View {
    
        @StateObject var locationMgr = NewLocationManager()
        @State private var mapCamPos: MapCameraPosition = .automatic
        
        var body: some View {
            ZStack {
                Map(position: $mapCamPos)
                    .onReceive(locationMgr.$direction) { direction in
                        mapCamPos =  .camera(MapCamera(
                            centerCoordinate: self.locationMgr.location.coordinate,
                            distance: 900800,
                            heading: direction
                        ))
                    }
                    .onReceive(locationMgr.$location) { location in
                        mapCamPos =  .camera(MapCamera(
                            centerCoordinate: location.coordinate,
                            distance: 900800,
                            heading: self.locationMgr.direction
                        ))
                    }
               

            }
        }
}

#Preview {
    ContentView2()
}


final class NewLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.500685, longitude: -0.124570), altitude: .zero, horizontalAccuracy: .zero, verticalAccuracy: .zero, timestamp: Date.now)
    @Published var direction: CLLocationDirection = .zero
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        Task { [weak self] in
            try? await self?.requestAuthorization()
        }
    }
    
    func requestAuthorization() async throws {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.forEach { [weak self] location in
            Task { @MainActor [weak self]  in
                self?.location = location
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        Task { @MainActor [weak self]  in
            self?.direction = newHeading.trueHeading
        }
    }
    
}
