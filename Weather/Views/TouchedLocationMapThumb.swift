import MapKit
import SwiftUI

struct TouchedLocationMapThumb: View {
        @State private var thumbnailImage: UIImage? = nil
        @StateObject var rvm = RadarViewModel()
        @State var width: CGFloat = 0.00 // this variable stores the width we want to get

        private var mapView = MKMapView()

        var body: some View {
            VStack {
                if (rvm.latest_time != 0) {
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
                    .onAppear {
                        // Add an overlay to the map
                        let time = rvm.latest_time
                        
                        
                        // Call the function to create the thumbnail with overlay
                        createMapThumbnailWithOverlayFromTouch(time: time, mapView: mapView)
                        { image in
                            thumbnailImage = image
                        }
                    }
                } else {
                    Text("Loading thumbnail...")
                        .frame(width: 325, height: 325)
                        .background(Color.gray.opacity(0.2))
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .onAppear {
                print(rvm.getTimesURL())
            }
        }
    }

func createMapThumbnailWithOverlayFromTouch(time: Int, mapView: MKMapView, completion: @escaping (UIImage?) -> Void) {
    // set location to the spot touched on map
    //print("latit: \(RadarMap(touchMap: false).latit), longi:\(RadarMap(touchMap: false).longi)")
    let location = CLLocationCoordinate2D(latitude: RadarMap(touchMap: false).latit, longitude: RadarMap(touchMap: false).longi)
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
        
        let tileUrl2 = "https://tilecache.rainviewer.com/v2/radar/\(time)/256/6/\(coordinateRegion.center.latitude)/\(coordinateRegion.center.longitude)/7/1_1.png"
        // print("test: z:\(z), x: \(x), y: \(y)")
        var overlayImage: UIImage?
        let url = URL(string: tileUrl2)
        
        getOverlayImageTouched(url: url!, completion: { data2 in
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
    
    func getOverlayImageTouched(url: URL, completion: @escaping (Data) -> Void) {
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






