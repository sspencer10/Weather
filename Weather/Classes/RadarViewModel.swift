import CoreLocation
import SwiftUI
import MapKit
//import SwiftSoup

class RadarViewModel: ObservableObject {
    
    public static var shared = RadarViewModel()
    
    @Published var latest_time: Int = 0
    @Published var times: [Int] = []
    @Published var timesIndex: Int = 0
    @Published var doubleTimesIndex: Double = 0.0
    @Published var currentTime: [Int] = []
    @Published var futureTime: [Int] = []
    @Published var overlays: [CachingTileOverlay] = []
    @Published var showProgress: Bool = true
    
    @StateObject var userDefaultsManager = UserDefaultsManager()
    
    //var color = UserDefaults.standard.integer(forKey: "selectedColorScheme")
    //@AppStorage("selectedColorScheme", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var selectedColorScheme: Int = 7
    @AppStorage("latest_time_storage", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var latest_time_storage: Int = 0
    

    
    var cnt = 0
    
    func saveTileOverlaysToUserDefaults(overlays: [CachingTileOverlay]) {
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
    
    func loadTileOverlaysFromUserDefaults() -> [CachingTileOverlay]? {
        if let savedOverlaysData = UserDefaults.standard.data(forKey: "SavedTileOverlays"),
           let configs = try? JSONDecoder().decode([TileOverlayConfig].self, from: savedOverlaysData) {
            return configs.map { config in
                let overlay = CachingTileOverlay(urlTemplate: config.urlTemplate)
                overlay.tileSize = config.tileSize
                overlay.minimumZ = config.minimumZ
                overlay.maximumZ = config.maximumZ
                return overlay
            }
        }
        return nil
    }
    /*
    func getTimesURL() -> [Int] {
        var count: Int = 0
        var arrStr:[Int] = []
        guard let url = URL(string: "https://api.rainviewer.com/public/maps.json") else { return [] }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [Int] {
                    DispatchQueue.main.async {
                        
                        self.times = jsonArray
                        print(self.times)
                        arrStr = jsonArray
                        count = arrStr.count - 1
                        self.latest_time = arrStr[count]
                        self.latest_time_storage = arrStr[count]
                        //print("latest_time \(self.latest_time)")
                    }
                }
                
            } catch {
                print("Failed to decode JSON: \(error)")
            }
            
        }
        task.resume()
        return arrStr
    }
     */
    
    func getTimesURL() -> [Int] {
        var count: Int = 0
        var arrStr:[Int] = []
        guard let url = URL(string: "https://api.rainviewer.com/public/weather-maps.json") else { return [] }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            // Decode the JSON data into a TimeData instance
            do {
                let timeData = try JSONDecoder().decode(TimeData.self, from: data)
                DispatchQueue.main.async {
                    // Combine "time" values from radar past and nowcast into a single array
                    arrStr = timeData.radar.past.map { $0.time } + timeData.radar.nowcast.map { $0.time }
                    self.times = arrStr
                    count = arrStr.count - 1
                    self.latest_time = arrStr[count]
                    self.latest_time_storage = arrStr[count]
                    
                    // Print the combined times
                    print("Radar Times: \(arrStr)")
                    print("count: \(count)")
                }
                
            } catch {
                print("Failed to decode JSON: \(error)")
            }
            
        }
        task.resume()
        return arrStr
    }
    
    func getOverlayUrls(color: Int, completion: @escaping ([CachingTileOverlay]) -> Void) {
        var count: Int = 0
        var arrStr:[Int] = []
        guard let url = URL(string: "https://api.rainviewer.com/public/weather-maps.json") else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            // Decode the JSON data into a TimeData instance
            do {
                let timeData = try JSONDecoder().decode(TimeData.self, from: data)
                DispatchQueue.main.async {
                    arrStr = timeData.radar.past.map { $0.time } + timeData.radar.nowcast.map { $0.time }
                    UserDefaults.standard.set(arrStr.count - 1, forKey: "timeIndex")
                    self.times = arrStr

                    count = arrStr.count - 1
                    self.latest_time = arrStr[12]
                    self.latest_time_storage = arrStr[12]
                    self.timesIndex = count
                    self.doubleTimesIndex = Double(self.timesIndex)
                    UserDefaults.standard.setValue(self.times, forKey: "tsArray")

                    self.currentTime = timeData.radar.past.map { $0.time }
                    self.futureTime = timeData.radar.nowcast.map { $0.time }

                    let paths = timeData.radar.nowcast.map({$0.path})

                    // Clear the old overlays before adding new ones
                    self.overlays.removeAll()

                    for time in timeData.radar.past.map({ $0.time }) {
                        let template = "https://tilecache.rainviewer.com/v2/radar/\(time)/256/{z}/{x}/{y}/\(color)/1_1.png"
                        print(template)
                        let overlay = CachingTileOverlay(urlTemplate: template)
                        self.overlays.append(overlay)
                    }

                    for path in paths {
                        let template = "https://tilecache.rainviewer.com/\(path)/256/{z}/{x}/{y}/\(color)/1_1.png"
                        let overlay = CachingTileOverlay(urlTemplate: template)
                        self.overlays.append(overlay)
                    }

                    self.saveTileOverlaysToUserDefaults(overlays: self.overlays)
                    TimerManager(initialTime: 3, repeats: false, value: true).startTimer()
                    self.showProgress = false
                    completion(self.overlays)
                }

            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
        task.resume()
    }
    func getOverlayUrls() -> [CachingTileOverlay] {
        var count: Int = 0
        var arrStr:[Int] = []
        guard let url = URL(string: "https://api.rainviewer.com/public/weather-maps.json") else { return [] }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            // Decode the JSON data into a TimeData instance
            do {
                
                let timeData = try JSONDecoder().decode(TimeData.self, from: data)
                DispatchQueue.main.async {
                    arrStr = timeData.radar.past.map { $0.time } + timeData.radar.nowcast.map { $0.time }
                    UserDefaults.standard.set(arrStr.count - 1, forKey: "timeIndex")

                    self.times = arrStr
                    
                    count = arrStr.count - 1
                    self.latest_time = arrStr[count]
                    self.latest_time_storage = arrStr[count]
                    let paths = timeData.radar.nowcast.map({$0.path})
                    
                    // Print the combined times
                    //print("Radar Times: \(arrStr)")
                    print("count: \(count)")
                    self.overlays.removeAll()
                    for time in timeData.radar.past.map({ $0.time }) {
                        let template = "https://tilecache.rainviewer.com/v2/radar/\(time)/256/{z}/{x}/{y}/\(self.userDefaultsManager.color)/1_1.png"
                        print(template)
                        let overlay = CachingTileOverlay(urlTemplate:template)
                        if (self.overlays.count == 13) {
                            self.overlays.removeFirst()
                        }
                        
                        self.overlays.append(overlay)
                    }
                    
                    for path in paths {
                        let template = "https://tilecache.rainviewer.com/\(path)/256/{z}/{x}/{y}/\(self.userDefaultsManager.color)/1_1.png"
                        print(template)
                        let overlay = CachingTileOverlay(urlTemplate:template)
                        if (self.overlays.count == 3) {
                            self.overlays.removeFirst()
                        }
                        self.overlays.append(overlay)
                    }
                    
                    //print("overlays: \(self.overlays)")
                    self.saveTileOverlaysToUserDefaults(overlays: self.overlays)
                    TimerManager(initialTime: 3, repeats: false, value: true).startTimer()
                    self.showProgress = false
                }

            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
        task.resume()
        return overlays
    }
    
    func refresh() {
        //print("refresh")
        UserDefaults.standard.setValue(true, forKey: "updateOK")
        UserDefaults.standard.setValue(false, forKey: "loop")
        RadarMap(touchMap: false).loopMap = false
        UserDefaults.standard.setValue(true, forKey: "firstUpdate")
    }
}
