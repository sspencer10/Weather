import CoreLocation
import SwiftUI
import MapKit

struct RadarMapContainer: View {
    var mapStyle: MKMapType
    var overlay: CachingTileOverlay
    @Binding var coordinate: CLLocationCoordinate2D?
    @Binding var center: Bool
    @Binding var zoom: Bool
    @Binding var latest: Int
    @Binding var previous: Int
    @Binding var color: Int
    @Binding var touchMap: Bool

    var body: some View {
        RadarMapView(mapStyle: mapStyle, overlay: overlay, coordinate: $coordinate, center: $center, zoom: $zoom, latest: $latest, previous: $previous, color: $color, touchMap: $touchMap)
    }
}

struct RadarMap: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var rvm = RadarViewModel()
    @State var touchMap: Bool
    @State private var showingSheet = false
    @State var loopMap: Bool = false
    @State var radarTimer: Timer?
    @State var latest: Int = .zero
    @State var previous: Int = .zero
    @State var timeIndex: Double = 0
    @State var tsArray:[Int] = UserDefaults.standard.array(forKey: "tsArray") as? [Int] ?? []
    @State var tsArrayIndex: Int = UserDefaults.standard.array(forKey: "tsArray")?.count as? Int ?? 0
    @State var coordinate: CLLocationCoordinate2D?
    @State private var showingPopover = false
    @State var tl:String = ""
    @State var center:Bool = false
    @State var zoom:Bool = true
    @State var showPicker = false
    @State var newState = true
    //@State var color: Int = 7
    @State var overlays: [CachingTileOverlay] = []
    @State var showProgress: Bool = true
    @State var c: Int = 0
    @State var selectedMap: Int = 7
    @StateObject var userDefaultsManager = UserDefaultsManager()
    @State var color: Int = UserDefaults.standard.integer(forKey: "radarColor")
    
    @AppStorage("previousColor", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var previousColor = 0
    @AppStorage("selectedMapStyle", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var selectedMapStyle = 0
    //@AppStorage("selectedColorScheme", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var selectedColorScheme: Int = 7
    @AppStorage("latit", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var latit: Double = 0.0
    @AppStorage("longi", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var longi: Double = 0.0
    @AppStorage("locStr", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var locStr: String = ""
    @State var showRadar: Bool = true
    
    let options = ["Black and White", "Original", "Universal Blue", "TITAN", "The Weather Channel", "Meteored", "NEXRAD Level III", "Rainbow", "Dark Sky"]
    
    let mapOptions = ["3-D Satellite w/ Roads", "Muted", "Standard"]
    
    
    private static var overlayArray: [MKTileOverlay] {
        RadarViewModel().loadTileOverlaysFromUserDefaults() ?? []
    }
    
    private static var timeArray: [Int] {
        RadarViewModel().getTimesURL()
    }
    
    private static let mapStyles: [MKMapType] = [.hybridFlyover, .mutedStandard, .standard]
    
    func dateToString(_ epoch: Int) -> String{
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MM/dd hh:mm a"
        let date = Date(timeIntervalSince1970: TimeInterval(Int(exactly: epoch)!))
        return dateFormatterPrint.string(from: date)
    }
    //@Environment(\.colorScheme) var colorScheme
    var body: some View {
        
        ZStack {
            Color("bg")
                .ignoresSafeArea()
            
            VStack{
                
                if (showProgress) {
                    ProgressView()
                        .controlSize(.large)
                        .onAppear {
                            rvm.getOverlayUrls(color: userDefaultsManager.color, completion: { x in
                                overlays = x
                                //timeIndex = Double(rvm.timesIndex)
                                print("timeIndex: \(timeIndex)")
                                showProgress = false
                            })
                        }
                } else {
                    var inx: Double = 15
                    ZStack() {
                        
                        if overlays == [] {
                            ProgressView()
                                .onAppear {
                                    rvm.getOverlayUrls(color: userDefaultsManager.color, completion: { x in
                                        overlays = x
                                        //timeIndex = Double(rvm.timesIndex)
                                        print("timeIndex: \(timeIndex)")
                                        showProgress = false
                                    })
                                }
                        } else {
                            RadarMapView(mapStyle: RadarMap.mapStyles[selectedMapStyle], overlay: rvm.overlays[Int(timeIndex)], coordinate: $coordinate, center: $center, zoom: $zoom, latest: $latest, previous: $previous, color: $userDefaultsManager.color, touchMap: $touchMap)
                            
                            
                                .onChange(of: coordinate) { newCoordinate, _ in
                                    
                                    locStr = ("\(coordinate?.latitude ?? 0.0), \(coordinate?.longitude ?? 0.0)")
                                    latit = coordinate?.latitude ?? 0.0
                                    longi = coordinate?.longitude ?? 0.0
                                    //print("touched location: \(locStr)")
                                    showingPopover = true
                                    
                                    
                                }
                            
                                .onChange(of: selectedMapStyle) {
                                    //overlays = []
                                    //showPicker = false
                                    showingSheet = false
                                }
                            
                                .onChange(of: color) {
                                    UserDefaults.standard.set(color, forKey: "radarColor")
                                    
                                    // Clear existing overlays and cache
                                    for overlay in overlays {
                                        if let cachingOverlay = overlay as? CachingTileOverlay {
                                            cachingOverlay.clearCache()
                                        }
                                    }
                                    
                                    overlays = []
                                    showPicker = false
                                    showingSheet = false
                                    
                                    // Fetch new overlays based on the selected color
                                    rvm.getOverlayUrls(color: userDefaultsManager.color) { newOverlays in
                                        overlays = newOverlays  // Update overlays state variable
                                        
                                        // Ensure the map is refreshed with new overlays
                                        refreshMap()
                                    }
                                }
                            
                                .sheet(isPresented: $showingPopover) {
                                    LocationWeather(updateCenter: MyWidgetCenter(), nums: nums())
                                    
                                }
                            
                        }
                        if showPicker {
                            VStack {
                                Text("Select a Color Scheme")
                                    .font(.headline)
                                //.padding()
                                
                                Picker("Options", selection: $color) {
                                    ForEach(0..<9) { index in
                                        Text(options[index]).tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .tint(.green)
                                .padding(.bottom, 10)
                                .onChange(of: color) {x, y in
                                    UserDefaults.standard.set(color, forKey: "radarColor")
                                }
                                
                                Button(action: {
                                    showPicker = false
                                }, label: {
                                    Text("Close")
                                })
                                .buttonStyle(.borderedProminent)
                                .tint(.white)
                                .foregroundColor(.black)
                            }
                            
                            .frame(width: 370, height: 150)
                            .background(Color(.black).opacity(0.75))
                            .cornerRadius(20)
                        }
                        
                        if showingSheet {
                            VStack {
                                Text("Select a Map Style")
                                    .font(.headline)
                                //.padding()
                                    .foregroundColor(.white)
                                
                                Picker("Options", selection: $selectedMapStyle) {
                                    ForEach(0..<3) { index in
                                        Text(mapOptions[index]).tag(index)
                                    }
                                    
                                }
                                .pickerStyle(MenuPickerStyle())
                                .tint(.green)
                                .padding(.bottom, 10)
                                
                                Button(action: {
                                    showingSheet = false
                                    
                                }, label: {
                                    Text("Close")
                                })
                                .buttonStyle(.borderedProminent)
                                .tint(.white)
                                .foregroundColor(.black)
                                
                            }
                            
                            .frame(width: 370, height: 150)
                            .background(Color(.black).opacity(0.75))
                            .cornerRadius(20)
                        }
                        
                        
                        
                        
                        VStack {
                            HStack {
                                Button(action: {
                                    dismiss()
                                    // Handle button tap
                                }) {
                                    Image(systemName: "xmark")
                                        .padding()
                                        .foregroundColor(.white).opacity(1.0)
                                        .background(Color.black).opacity(0.75)
                                        .clipShape(Circle())
                                    
                                }
                                .padding(.leading, 20)
                                .padding(.top, 20)
                                Spacer()
                                Button(action: {
                                    print("Location")
                                    center = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        center = false
                                    }
                                    // Handle button tap
                                }) {
                                    Image(systemName: "location")
                                        .padding()
                                        .foregroundColor(.white).opacity(1.0)
                                        .background(Color.black).opacity(0.75)
                                        .clipShape(Circle())
                                    
                                }
                                .padding(.trailing, 20)
                                .padding(.top, 20)
                            }
                            
                            HStack {
                                Spacer()
                                Button(action: {
                                    print("Maps")
                                    showPicker = false
                                    showingSheet = true
                                    // Handle button tap
                                }) {
                                    Image(systemName: "map")
                                        .padding()
                                        .foregroundColor(.white).opacity(1.0)
                                        .background(Color.black).opacity(0.75)
                                        .clipShape(Circle())
                                }
                                
                                
                                .padding(.trailing, 20)
                                .padding(.top, 20)
                            }
                            
                            HStack {
                                Spacer()
                                Button(action: {
                                    print("Layers")
                                    showingSheet = false
                                    showPicker = true
                                    // Handle button tap
                                }) {
                                    Image(systemName: "square.3.layers.3d")
                                        .padding()
                                        .foregroundColor(.white).opacity(1.0)
                                        .background(Color.black).opacity(0.75)
                                        .clipShape(Circle())
                                    
                                }
                                .padding(.trailing, 20)
                                .padding(.top, 20)
                            }
                            Spacer()
                        }
                    }
                    .onAppear {
                        timeIndex = 12
                        print("timeIndex: \(timeIndex)")
                    }
                    
                    HStack {
                        
                        VStack {
                            
                            Slider(value: $timeIndex.animation(.smooth), in: 0...15.0, step: 1)
                            Text("\(dateToString(rvm.times[Int(timeIndex)]))").padding(.leading, 67)
                        }
                        .tint(.green)
                        .onAppear {
                        }
                        
                        Button(action: {
                            
                            loopMap.toggle()
                            if (loopMap) {
                                zoom = false
                                print("c: \(c)")
                                if c == 0 {
                                    timeIndex = 0
                                    c = 1
                                }
                                inx = 0
                                radarTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
                                    if rvm.overlays.count > 0 {
                                        withAnimation{
                                            timeIndex = Double((Int(timeIndex) + 1) % 16)
                                            print("time Index: \(timeIndex)")
                                            if (c == 1) {
                                                c = 2
                                                previous = latest
                                                latest = tsArray[Int(inx)]
                                            }
                                            
                                            if (latest != tsArray[Int(inx)]) {
                                                previous = latest
                                            }
                                        }
                                    }
                                }
                            } else {
                                zoom = true
                                //timeIndex = 12
                                inx = 15
                                radarTimer?.invalidate()
                                
                            }
                        }, label: {
                            if !loopMap {
                                Text("Loop ")
                            } else {
                                Text("Pause")
                            }
                        })
                        
                        .buttonStyle(.borderedProminent)
                        .padding(.bottom, 25)
                        .tint(.green)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    
                    
                }
            }
            
            .onAppear {
                rvm.getOverlayUrls(color: userDefaultsManager.color, completion: { x in
                    //timeIndex = 12
                    overlays = x
                    color = userDefaultsManager.color
                    print("timeIndex: \(timeIndex)")
                    showProgress = false
                    selectedMap = selectedMapStyle
                    
                })
                
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            
        }
        
        
    }
    func refreshMap() {
        print("refreshMap")
        rvm.getOverlayUrls(color: userDefaultsManager.color, completion: { x in
            //timeIndex = 12
            overlays = x
            print("timeIndex: \(timeIndex)")
            showProgress = false
            selectedMap = selectedMapStyle
            //RadarMapContainer(mapStyle: RadarMap.mapStyles[selectedMapStyle], overlay: overlays[Int(timeIndex)], coordinate: $coordinate, center: $center, zoom: $zoom, latest: $latest, previous: $previous, color: $userDefaultsManager.color, touchMap: $touchMap)
            
        })
        
    }
}

//class RadarMapView: UIViewRepresentable {
struct RadarMapView: UIViewRepresentable {
    
    
    func makeCoordinator() -> Coordinator {
        //print("makeCoordinator()")
        return Coordinator(self)
    }
    let mapView = MKMapView()
    var mapStyle: MKMapType
    var overlay: CachingTileOverlay
    
    @Binding var coordinate: CLLocationCoordinate2D?
    @Binding var center: Bool
    @Binding var zoom: Bool
    @Binding var latest: Int
    @Binding var previous: Int
    @Binding var color: Int
    @Binding var touchMap: Bool
    
    
    func makeUIView(context: Context) -> MKMapView {
        
        mapView.delegate = context.coordinator
        
        // Create and configure the long press gesture recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: mapView.delegate, action: #selector(Coordinator.handleLongPress(_:)))
        longPressRecognizer.minimumPressDuration = 0.6
        mapView.addGestureRecognizer(longPressRecognizer)
        var location = CLLocationCoordinate2D(latitude: LocationManager.shared.location?.coordinate.latitude ?? 42.1673839, longitude: LocationManager.shared.location?.coordinate.longitude ?? -92.0156213)
        if (touchMap) {
            location = CLLocationCoordinate2D(latitude: RadarMap(touchMap: touchMap).latit, longitude: RadarMap(touchMap: true).longi)
        }
        
        let span = MKCoordinateSpan(latitudeDelta: 4.317626953125, longitudeDelta: 4.317626953125)
        let coordinateRegion = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(coordinateRegion, animated: true)
        
        mapView.mapType = self.mapStyle
        
        return mapView
    }
    
    func createMapThumbnail() {
        
        
        let mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: 200, height: 200)) // Adjust size as needed
        mapView.addOverlay(overlay)
        mapView.setVisibleMapRect(overlay.boundingMapRect, animated: false)
        // Give some time for the tiles to load
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            let renderer = UIGraphicsImageRenderer(size: mapView.bounds.size)
            let mapImage = renderer.image { ctx in
                mapView.layer.render(in: ctx.cgContext)
            }
            guard let data = mapImage.jpegData(compressionQuality: 0.5) else { return }
            let encoded = try! PropertyListEncoder().encode(data)
            UserDefaults.standard.set(encoded, forKey: "mapImage")
        }
        
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.delegate = context.coordinator
        
        // Remove all overlays
        if !mapView.overlays.isEmpty {
            mapView.removeOverlays(mapView.overlays)
        }
        CachingTileOverlay().clearCache()
        
        // Add new overlays
        mapView.addOverlay(overlay)
        
        // Set map type based on style
        mapView.mapType = self.mapStyle
        
        // Handle centering and zoom logic
        if center {
            let location = CLLocationCoordinate2D(
                latitude: LocationManager.shared.location?.coordinate.latitude ?? 42.1673839,
                longitude: LocationManager.shared.location?.coordinate.longitude ?? -92.0156213
            )
            let span = MKCoordinateSpan(latitudeDelta: 3.5, longitudeDelta: 3.5)
            let coordinateRegion = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(coordinateRegion, animated: true)
        }
        
        mapView.isZoomEnabled = zoom
    }
}

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension MKMapView {
    func captureSnapshot() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        return renderer.image { _ in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
    }
}


struct RadarMap_Previews: PreviewProvider {
    static var previews: some View {
        RadarMap(touchMap: false)
    }
}




