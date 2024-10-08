
import SwiftUI
import MapKit
import SwiftSoup

class RadarViewModel: ObservableObject {
    @Published var times: [Int] = []
    @Published var timesIndex: Int = 0
    @Published var doubleTimesIndex: Double = 0.0
    @Published var overlays: [MKTileOverlay] = []
    @Published var showProgress: Bool = true
    
    var cnt = 0
    
    func saveTileOverlaysToUserDefaults(overlays: [MKTileOverlay]) {
        let configs = overlays.map { overlay in
            TileOverlayConfig(
                urlTemplate: overlay.urlTemplate,
                tileSize: overlay.tileSize,
                minimumZ: overlay.minimumZ,
                maximumZ: overlay.maximumZ
            )
        }
        
        if let encoded = try? JSONEncoder().encode(configs) {
            UserDefaults.standard.set(encoded, forKey: "SavedTileOverlays")
        }
    }
    
    func loadTileOverlaysFromUserDefaults() -> [MKTileOverlay]? {
        if let savedOverlaysData = UserDefaults.standard.data(forKey: "SavedTileOverlays"),
           let configs = try? JSONDecoder().decode([TileOverlayConfig].self, from: savedOverlaysData) {
            return configs.map { config in
                let overlay = MKTileOverlay(urlTemplate: config.urlTemplate)
                overlay.tileSize = config.tileSize
                overlay.minimumZ = config.minimumZ
                overlay.maximumZ = config.maximumZ
                return overlay
            }
        }
        return nil
    }
    

    
    func getOverlayUrls() {
        
        guard let url = URL(string: "https://api.rainviewer.com/public/maps.json") else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [Int] {
                    DispatchQueue.main.async {
                        
                        self.times = jsonArray
                        print("\(self.times)")
                        self.timesIndex = jsonArray.count - 1
                        print("times index: \(self.timesIndex)")
                        self.doubleTimesIndex = Double(self.timesIndex)
                        print("double times index: \(self.doubleTimesIndex)")
                        UserDefaults.standard.setValue(Double(self.timesIndex), forKey: "timeIndex")
                        print(UserDefaults.standard.double(forKey: "timeIndex"))
                        for time in jsonArray {
                            
                            let template = "https://tilecache.rainviewer.com/v2/radar/\(time)/256/{z}/{x}/{y}/7/1_1.png"
                            
                            let overlay = MKTileOverlay(urlTemplate:template)
                            
                            self.overlays.append(overlay)
                        }
                        print("\(self.overlays)")
                        self.saveTileOverlaysToUserDefaults(overlays: self.overlays)
                        TimerManager(initialTime: 3, repeats: false).startTimer()
                        self.showProgress = false
                    }
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
        task.resume()
    }
    
    func refresh() {
        print("refresh")
        UserDefaults.standard.setValue(true, forKey: "updateOK")
        UserDefaults.standard.setValue(false, forKey: "loop")
        RadarView(wvm: WeatherViewModel()).loopMap = false
        UserDefaults.standard.setValue(true, forKey: "firstUpdate")
    }
}

struct RadarView: View {
    @ObservedObject var wvm: WeatherViewModel
    @StateObject private var rvm = RadarViewModel()
    @State var mapTime = "1600585200"
    @AppStorage("selectedMapStyle") var selectedMapStyle = 0
    @AppStorage("findme") var findMe = 0
    @State private var showingSheet = false
    @State private var showingSheet2 = false
    @State var loopMap: Bool = UserDefaults.standard.bool(forKey: "loop")
    @State var radarTimer: Timer?
    @State var a:Bool = false
    
    @State var timeIndex: Double = UserDefaults.standard.double(forKey: "timeIndex")
    
    private static let mapStyles: [MKMapType] = [.hybrid, .hybridFlyover, .mutedStandard, .satellite, .satelliteFlyover, .standard]

    func dateToString(_ epoch: Int) -> String{
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MM/dd hh:mm a"
        let date = Date(timeIntervalSince1970: TimeInterval(Int(exactly: epoch)!))
        return dateFormatterPrint.string(from: date)
    }
    
    @State private var coordinate: CLLocationCoordinate2D?
    @State private var showingPopover = false
    var body: some View {
        
            
                VStack{
                    if (rvm.showProgress) {
                        
                    } else {
                        RadarMapView(coordinate: $coordinate, mapStyle: RadarView.mapStyles[selectedMapStyle], overlay: rvm.overlays[rvm.timesIndex], lm: LocationManager(), wvm: WeatherViewModel(), rvm: RadarViewModel())
                        .onChange(of: coordinate) { newCoordinate, _ in
                            if newCoordinate != nil {
                                showingPopover = true
                                let locStr = ("\(coordinate?.latitude ?? 0.0), \(coordinate?.longitude ?? 0.0)")
                                UserDefaults.standard.setValue(locStr, forKey: "location")
                            }
                        }
                        .popover(isPresented: $showingPopover) {
                            NavigationStack {
                                LocationWeather(viewModel: WeatherViewModel(), updateCenter: MyWidgetCenter(), rvm: RadarViewModel(), locationManager: LocationManager())
                            }
                        }
    
                        HStack{
                            VStack{
                                
                                
                                Slider(value: $rvm.doubleTimesIndex.animation(.linear), in: 0...Double(rvm.overlays.count), step: 1)
                                Text("\(dateToString(rvm.times[Int(timeIndex)]))")
                            }
                            
                            Button(action: {

                                loopMap.toggle()
                                
                                if (loopMap) {
                                    var tI = timeIndex
                                    UserDefaults.standard.setValue(false, forKey: "updateOK")
                                    
                                    radarTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                                        if rvm.overlays.count > 0 {
                                            withAnimation {
                                                timeIndex = Double(Int(Double(timeIndex) + 1) % Int(Double(rvm.overlays.count)))
                                            }
                                        }
                                    }
                                } else {
                                    //a = false
                                    var x = rvm.$timesIndex
                                    timeIndex = Double(rvm.timesIndex)
                                    radarTimer?.invalidate()
                                }
                            }, label: {
                                if !loopMap {
                                    Text("Loop")
                                } else {
                                    Text("Pause")
                                }
                            })
                            .buttonStyle(.borderedProminent)
                            .padding(.bottom, 25)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.horizontal)
                        .padding(.top, 0)
                        .padding(.bottom, -55)
                    
                    
                        HStack(){
                            Spacer(minLength: 40)
                            Button(action: {
                                showingSheet.toggle()
                            }, label: {
                                Image(systemName: "gearshape.fill").resizable()
                                    .renderingMode(.template)
                                    .font(.title)
                                    .foregroundColor(Color.white)
                                    .frame(width: 30, height: 30)
                                    .padding(.leading, 30)
                                    .padding(.trailing, 30)
                                    .padding(.top, 30)
                                    .padding(.bottom, -10)
                            }).padding()
                            
                                .actionSheet(isPresented: $showingSheet) {
                                    ActionSheet(title: Text("What map style do you want?"), message: Text("Please select one option below"), buttons: [
                                        .default(Text("Muted")) { self.selectedMapStyle = 2 },
                                        .default(Text("Satellite")) { self.selectedMapStyle = 3 },
                                        .default(Text("Satellite w/ Roads")) { self.selectedMapStyle = 0 },
                                        .default(Text("Satellite 3-D")) { self.selectedMapStyle = 4 },
                                        .default(Text("3-D Satellite w/ Roads")) { self.selectedMapStyle = 1 },
                                        .default(Text("Standard")) { self.selectedMapStyle = 5 },
                                        .default(Text("Refresh")) {RadarViewModel().refresh()},
                                        .cancel(Text("Dismiss"))
                                    ])
                                }
                        }
                    }
                }

                .onAppear {
                    rvm.getOverlayUrls()
                    rvm.refresh()
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
    }


struct RadarMapView: UIViewRepresentable {
    @Binding var coordinate: CLLocationCoordinate2D?
    var mapStyle: MKMapType
    var overlay: MKTileOverlay
    
    @ObservedObject var lm: LocationManager
    @ObservedObject var wvm: WeatherViewModel
    @ObservedObject var rvm: RadarViewModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.mapType = self.mapStyle
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress))
        mapView.addGestureRecognizer(longPressGesture)
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        
        mapView.mapType = self.mapStyle

        mapView.delegate = context.coordinator
        let overlays = mapView.overlays
        for overlay in overlays {
            mapView.removeOverlay(overlay)
        }
        //let overlayArray = rvm.loadTileOverlaysFromUserDefaults()
        print("updateUI")
        mapView.addOverlay(overlay)

        let _: CLLocationDistance = 50000
            
        if (UserDefaults.standard.bool(forKey: "firstUpdate")) {
            UserDefaults.standard.setValue(false, forKey: "firstUpdate")
            let location = CLLocationCoordinate2D(latitude: Double(wvm.getLatS()) ?? 42.1673838, longitude: Double(wvm.getLongS()) ?? -92.0156213)
            let span = MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)
            let coordinateRegion = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(coordinateRegion, animated: true)

        }

    }
}
        
class Coordinator: NSObject, MKMapViewDelegate {
    var parent: RadarMapView

    init(_ parent: RadarMapView) {
        self.parent = parent
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKTileOverlayRenderer(overlay: overlay)
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("region changed")
        //UserDefaults.standard.setValue(true, forKey: "updateOK")
        let newRegion = mapView.region
        let coordinateRegion = MKCoordinateRegion(center: mapView.region.center, span: mapView.region.span)
        mapView.setRegion(coordinateRegion, animated: true)
        
        print("New Region: \(newRegion)")
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        let mapView = gestureRecognizer.view as! MKMapView
        let point = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        parent.coordinate = coordinate
    }
    
}

import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct RadarView_Previews: PreviewProvider {
    static var previews: some View {
        RadarView(wvm: WeatherViewModel())
    }
}
