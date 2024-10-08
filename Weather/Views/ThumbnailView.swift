import MapKit
import SwiftUI

struct MyThumbnailView: View {
    @State private var thumbnailImage: UIImage? = nil
    @StateObject var rvm = RadarViewModel()
    @State var width: CGFloat = 0.00 // this variable stores the width we want to get
    @State var show: Bool = false
    @AppStorage("selectedColorScheme", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var selectedColorScheme: Int = 7


    private var mapView = MKMapView()

    var body: some View {
        VStack {
            if show {
                VStack {
                    if let image = thumbnailImage {
                        
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 325, height: 325)
                            .clipShape(.rect(cornerRadius: 10))
                            .shadow(radius: 10)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                    } else {
                        Text("Error Loading thumbnail...")
                            .frame(width: 325, height: 325)
                            .background(Color.gray.opacity(0.2))
                    }
                }
            } else {
                VStack {
                    Text("Loading thumbnail...")
                        .frame(width: 325, height: 325)
                        .background(Color.gray.opacity(0.2))
                }
                
                .onAppear {
                    rvm.getOverlayUrls(color: 7, completion: { x in
                        let time = rvm.latest_time
                        print("time: \(time)")
                        // Call the function to create the thumbnail with overlay
                        createMapThumbnailWithOverlay(time: time, mapView: mapView) { image in
                            thumbnailImage = image
                            show = true
                        }
                    })
                }
            }
        }
    }
}
// Function to create a map thumbnail with overlay

func createMapThumbnailWithOverlay(time: Int, mapView: MKMapView, completion: @escaping (UIImage?) -> Void) {
    @AppStorage("selectedColorScheme", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var selectedColorScheme: Int = 7

    //set location to current
    let location = CLLocationCoordinate2D(latitude: LocationManager.shared.location?.coordinate.latitude ?? 42.1673839, longitude: LocationManager.shared.location?.coordinate.longitude ?? -92.0156213)
    let span = MKCoordinateSpan(latitudeDelta: 4.317626953125, longitudeDelta: 4.317626953125)
    let coordinateRegion = MKCoordinateRegion(center: location, span: span)
    let options = MKMapSnapshotter.Options()
    options.region = coordinateRegion
    options.size = CGSize(width: 325, height: 325) // Adjust size as needed
    options.scale = UIScreen.main.scale

    let snapshotter = MKMapSnapshotter(options: options)
    snapshotter.start { snapshot, error in
        guard let snapshot = snapshot else {
            print("Snapshot error: \(String(describing: error))")
            completion(nil)
            return
        }
        
        // Get the base map image from the snapshot
        let baseImage = snapshot.image
        
        let tileUrl2 = "https://tilecache.rainviewer.com/v2/radar/\(time)/256/6/\(coordinateRegion.center.latitude)/\(coordinateRegion.center.longitude)/\(selectedColorScheme)/1_1.png"
        // print("test: z:\(z), x: \(x), y: \(y)")
        var overlayImage: UIImage?
        let url = URL(string: tileUrl2)
        
        getOverlayImage(url: url!, completion: { data2 in
            overlayImage = UIImage(data: data2)!
            // Create a new context to combine the images
            UIGraphicsBeginImageContextWithOptions(baseImage.size, true, 0)
            // Draw the base map image
            baseImage.draw(at: .zero)
            // Draw the overlay image on top
            let rect = CGRect(x: 0, y: 0, width: baseImage.size.width, height: baseImage.size.height)
            overlayImage?.draw(in: rect, blendMode: .normal, alpha: 1.0)
            // Get the final combined image
            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            completion(finalImage)
            
        })
    }
}

func getOverlayImage(url: URL, completion: @escaping (Data) -> Void) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        // Handle error
        if let error = error {
            print("Failed to fetch icon: \(error.localizedDescription)")
            return
        }
        // Validate response
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            print("Failed to fetch icon: HTTP \(httpResponse.statusCode)")
            return
        }
        // Validate data
        guard let data = data else {
            print("Failed to fetch icon: Data is nil")
            return
        }
        completion(UIImage(data: data)?.pngData() ?? Data())
   
    }.resume()
}

func getZoomLevel(mapView: MKMapView) -> Double {
    _ = Double(mapView.frame.size.width)
    //print("FrameSize: \(frameSize)")
    let span = MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)
    let zoomLevel = log2(360 * (Double(mapView.frame.size.width) / 256) / span.longitudeDelta)
    return zoomLevel
}



extension MKMapView {

    
    func calculateTileCoordinates(z: Double) -> (x: Int, y: Int) {
        
        let region = self.region
        let centerCoordinate = region.center
        
        // Convert latitude and longitude to radians
        let latRad = centerCoordinate.latitude * .pi / 180
        
        let n = pow(2.0, z)
        
        // Calculate x and y tile coordinates
        let xTile = (centerCoordinate.longitude + 180.0) / 360.0 * n
        let yTile = (1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / .pi) / 2.0 * n
        
        // Check for valid xTile and yTile values
        guard !xTile.isNaN && !xTile.isInfinite,
              !yTile.isNaN && !yTile.isInfinite else {
            return (x: 0, y: 0)  // Return a default value in case of an error
        }
        
        return (x: Int(xTile), y: Int(yTile))
    }
    


}
