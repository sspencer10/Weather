import Foundation
import SwiftUI
import Combine
import MapKit

class WeatherViewModel: ObservableObject {
    
    var locationManager = LocationManager()
    
    @Published var weather: WeatherResponse?
    
    @Published var day: Int = 1
    @Published var count: Int = 0
    @Published var alert: Bool = false
    @Published var showFirstView = true
    @Published var showView:Bool = false
    @Published var hourlyFinished: Date = Date()
    @Published var forecast: [Hour]? = nil
    @Published var thumbnailImage: UIImage? = nil
    @Published var time: String = ""
    @Published var precChane: String = ""
    @Published var uv: Int = 0
    @Published var alertData: AlertsResponse?
    
    @AppStorage("alert", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var alert_s: Bool = false
    @AppStorage("uv", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var uv_s: Int = 0
    @AppStorage("code", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var code: Int = 0
    @AppStorage("widgetUpdates", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var widgetUpdates: Int = 0
    @AppStorage("precChance", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var precChance_s: String = ""
    @AppStorage("location_name", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var location_name_s: String = "Des Moines"
    @AppStorage("isDay", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var isDay_s: String = "day_sky"
    @AppStorage("current_f", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var current_f_s: Double = 68.0
    @AppStorage("feels_like", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var feels_like_s: Double = 69.0
    @AppStorage("today_min", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var today_min_s: Double = 60.0
    @AppStorage("is_day", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var is_day_s: Int = 0
    @AppStorage("today_max", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var today_max_s: Double = 78.0
    @AppStorage("current_icon", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var current_icon_s: String = "http://cdn.weatherapi.com/weather/64x64/day/113.png"
    @AppStorage("current_text", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var current_text_s: String = "Sunny"
    @AppStorage("imageData", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var imageData_s: Data = UIImage(named: "defaultIcon")!.pngData() ?? Data()
    @AppStorage("locStr2", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var locStr2_s: String?
    @AppStorage("last_update", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var last_update_s: String?
    
    @AppStorage("gps_location", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var gps_location_s: String = ""
    @AppStorage("locStr", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var locStr: String = "Vinton, IA"
    @AppStorage("last_update", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var last_update: String = ""
    @AppStorage("data", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var allData: String = ""
    @AppStorage("currentLocation", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var currentLocation: String = ""
    @AppStorage("latit", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var latit: Double = 0.0
    @AppStorage("longi", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var longi: Double = 0.0
    @AppStorage("alertCount", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var alertCount: Int = 0
    @AppStorage("summary", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var summary_s: String = ""
    @AppStorage("daynight", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var daynight: String = "day"



    private var cancellables = Set<AnyCancellable>()

    func fetchWeather(filter: Int, location: String, completion: @escaping (WeatherResponse) -> Void) {
        DispatchQueue.main.async {
            self.showFirstView = true
            //print("refreshing")
        }
        //print("fetchWeather")
        var urlString = ""
        if (location == "current") {
            urlString = "http://api.weatherapi.com/v1/forecast.json?key=5aa6d70b54f7455fb2f141924241508&alerts=yes&q=\(LocationManager.shared.location?.coordinate.latitude ?? 42.1673839), \(LocationManager.shared.location?.coordinate.longitude ?? -92.0156213)&days=5"
        } else {
            urlString = "http://api.weatherapi.com/v1/forecast.json?key=5aa6d70b54f7455fb2f141924241508&alerts=yes&q=\(locStr)&days=5"
        }
        print(urlString)
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {

                do {
                    
                    let decodedData = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.currentLocation = "\(LocationManager.shared.location?.coordinate.latitude ?? 42.1673839), \(LocationManager.shared.location?.coordinate.longitude ?? -92.0156213)"
                        self.showFirstView = true
                        self.weather = decodedData
                        self.time = decodedData.location.localtime
                        self.count = decodedData.forecast.forecastday.count
                        self.day = decodedData.current.is_day
                        //print(decodedData.current.is_day)
                        self.is_day_s = decodedData.current.is_day
                        if (decodedData.current.is_day == 1) {
                            self.isDay_s = "day_sky"
                            self.daynight = "day"
                        } else {
                            self.isDay_s = "night_sky"
                            self.daynight = "night"
                        }
                        let rainChance = decodedData.forecast.forecastday[0].day.daily_chance_of_rain
                        let snowChance = decodedData.forecast.forecastday[0].day.daily_chance_of_snow
                        
                            if rainChance > 0 {
                                self.precChane = ("\(rainChance)%")
                                
                            } else if snowChance > 0 {
                                self.precChane = ("\(snowChance)%")
                            } else {
                                self.precChane = "0%"
                            }
                        self.precChance_s = self.precChane
                        self.uv = decodedData.forecast.forecastday[0].day.uv
                        self.uv_s = self.uv
                        self.current_icon_s = decodedData.current.condition.icon
                        self.code = decodedData.current.condition.code
                        self.location_name_s = decodedData.location.name
                        self.current_f_s = decodedData.current.temp_f
                        self.today_min_s = decodedData.forecast.forecastday[0].day.mintemp_f
                        self.today_max_s = decodedData.forecast.forecastday[0].day.maxtemp_f
                        self.feels_like_s = decodedData.current.feelslike_f
                        self.current_text_s = decodedData.current.condition.text
                        let df = DateFormatter()
                        df.dateFormat = "hh:mm"
                        self.last_update = df.string(from: Date())
                        
                        if (decodedData.alerts?.alert?.count ?? 0 > 0) {
                            self.alert = true
                            self.alert_s = true
                        } else {
                            self.alert = false
                            self.alert_s = false
                        }

                        let iconUrl = "http:\(decodedData.current.condition.icon)"
                        //print("icon: \(iconUrl)")
                        if let url = URL(string: iconUrl) {
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
                                DispatchQueue.main.async {
                                    
                                    // Process data
                                    self.imageData_s = UIImage(data: data)?.pngData() ?? Data()
                                }

                            }.resume() // Don't forget to call resume() to start the data task
                        } else {
                            print("Failed to create URL from string: \(iconUrl)")
                        }
                        
                        var urlString = ""
                        if (location == "current") {
                            urlString = "http://api.weatherapi.com/v1/forecast.json?key=5aa6d70b54f7455fb2f141924241508&alerts=yes&q=\(LocationManager.shared.location?.coordinate.latitude ?? 42.1673839), \(LocationManager.shared.location?.coordinate.longitude ?? -92.0156213)&days=5"
                        } else {
                            urlString = "http://api.weatherapi.com/v1/forecast.json?key=5aa6d70b54f7455fb2f141924241508&alerts=yes&q=\(self.locStr)&days=5"
                        }
                        //print(urlString)
                        guard let url = URL(string: urlString) else { return }
                        URLSession.shared.dataTaskPublisher(for: url)
                            .map { $0.data }
                            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
                            .receive(on: DispatchQueue.main)
                            .sink(receiveCompletion: { completion in
                                switch completion {
                                case .finished:
                                    self.hourlyFinished = Date()
                                    self.showView = true
                                    break
                                case .failure(let error):
                                    print("Error fetching data: \(error)")
                                }
                            }, receiveValue: { [weak self] response in
                                let allHours = response.forecast.forecastday.flatMap { $0.hour }
                                if (filter == 5) {
                                    self?.forecast = self?.filterNext5Hours(from: allHours)
                                    
                                } else {
                                    self?.forecast = self?.filterNext24Hours(from: allHours)
                                    
                                }
                                
                            })
                            .store(in: &self.cancellables)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.showFirstView = false
                        }
                        self.weatherSummary(data: decodedData, completion: { x in
                            self.summary_s = x
                            completion(decodedData)
                        })
                    }
                } catch {
                    print("Error decoding data: \(error)")
                }
            }
        }.resume()
    }
    
    func getHourly(filter: Int, location: String, completion: @escaping ([Hour]) -> Void) {
        var urlString = ""
        if (location == "current") {
            urlString = "http://api.weatherapi.com/v1/forecast.json?key=5aa6d70b54f7455fb2f141924241508&alerts=yes&q=\(LocationManager.shared.location?.coordinate.latitude ?? 42.1673839), \(LocationManager.shared.location?.coordinate.longitude ?? -92.0156213)&days=5"
        } else {
            urlString = "http://api.weatherapi.com/v1/forecast.json?key=5aa6d70b54f7455fb2f141924241508&alerts=yes&q=\(locStr)&days=5"
        }
        //print(urlString)
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.hourlyFinished = Date()
                    self.showView = true
                    break
                case .failure(let error):
                    print("Error fetching data: \(error)")
                }
            }, receiveValue: { [weak self] response in
                let allHours = response.forecast.forecastday.flatMap { $0.hour }
                if (filter == 5) {
                    self?.forecast = self?.filterNext5Hours(from: allHours)
                    completion(self?.forecast ?? [])

                } else {
                    self?.forecast = self?.filterNext24Hours(from: allHours)
                    completion(self?.forecast ?? [])

                }
                
            })
            .store(in: &self.cancellables)

    }
    
    func getDaily(filter: Int, location: String, completion: @escaping ([ForecastDay]) -> Void) {
        var urlString = ""
        if (location == "current") {
            urlString = "http://api.weatherapi.com/v1/forecast.json?key=5aa6d70b54f7455fb2f141924241508&alerts=yes&q=\(LocationManager.shared.location?.coordinate.latitude ?? 42.1673839), \(LocationManager.shared.location?.coordinate.longitude ?? -92.0156213)&days=5"
        } else {
            urlString = "http://api.weatherapi.com/v1/forecast.json?key=5aa6d70b54f7455fb2f141924241508&alerts=yes&q=\(locStr)&days=5"
        }
        //print(urlString)
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.hourlyFinished = Date()
                    self.showView = true
                    break
                case .failure(let error):
                    print("Error fetching data: \(error)")
                }
            }, receiveValue: { response in
                let allDays = response.forecast.forecastday.compactMap { $0 }
                completion(allDays)
            })
            .store(in: &self.cancellables)
            
    }
    
    private func filterNext24Hours(from hours: [Hour]) -> [Hour] {
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Filter hours starting from the next closest hour
        if let firstHourIndex = hours.firstIndex(where: {
            calendar.compare(currentDate, to: $0.date ?? Date(), toGranularity: .hour) == .orderedAscending
        }) {
            let endIndex = Swift.min(firstHourIndex + 24, hours.count)
            return Array(hours[firstHourIndex..<endIndex])
        }
        
        return []
    }
    
    private func filterNext5Hours(from hours: [Hour]) -> [Hour] {
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Filter hours starting from the next closest hour
        if let firstHourIndex = hours.firstIndex(where: {
            calendar.compare(currentDate, to: $0.date ?? Date(), toGranularity: .hour) == .orderedAscending
        }) {
            let endIndex = Swift.min(firstHourIndex + 5, hours.count)
            return Array(hours[firstHourIndex..<endIndex])
        }
        
        return []
    }
    
    func fetchIcon(iconUrlString: String) {
        let iconUrl = "http:\(iconUrlString)"
        //print("icon: \(iconUrl)")
        if let url = URL(string: iconUrl) {
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
                DispatchQueue.main.async {
                    // Process data
                    self.imageData_s = UIImage(data: data)?.pngData() ?? Data()

                }
            }.resume() // Don't forget to call resume() to start the data task
        } else {
            print("Failed to create URL from string: \(iconUrlString)")
        }
     }
    
    func refreshNow(completion: @escaping (String) -> Void) {
        DispatchQueue.main.async {
            //self.showFirstView = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            self.fetchWeather(filter: 5, location: "current", completion: { _ in
                //print("last update \(self.last_update)")
                completion("success")
            })
        }
    }
    
    
    func fetchData(completion: @escaping (WeatherResponse) -> Void) {
        gps_location_s = locationManager.locationString
        // Example using URLSession to fetch data from an API
        let urlStr = "http://api.weatherapi.com/v1/forecast.json?key=5aa6d70b54f7455fb2f141924241508&alerts=yes&q=\(gps_location_s)&days=5"
        guard let url = URL(string: urlStr) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {

                do {
                    let decodedData = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    DispatchQueue.main.async {
                        let iconUrl = "http:\(decodedData.current.condition.icon)"
                        if let url = URL(string: iconUrl) {
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
                                DispatchQueue.main.async {
                                    self.imageData_s = UIImage(data: data)?.pngData() ?? Data()
                                }
                            }.resume()
                        } else {
                            print("Failed to create URL from string: \(iconUrl)")
                        }
                        self.cacheData(decodedData)
                        completion(decodedData)
                    }
                } catch {print("Error decoding data: \(error)")}
            }
        }
        task.resume()
    }
    
    // Storing the data
    func cacheData(_ data: WeatherResponse) {
        if let encodedData = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encodedData, forKey: "cachedWidgetData")
        }
    }

    // Retrieving the data
    func retrieveCachedData() -> WeatherResponse? {
        if let savedData = UserDefaults.standard.data(forKey: "cachedWidgetData") {
            if let decodedData = try? JSONDecoder().decode(WeatherResponse.self, from: savedData) {
                return decodedData
            }
        }
        return nil
    }
    
    func imageName(forCode code: Int) -> String? {
        switch code {
                case 1000: return "113"
                case 1003: return "116"
                case 1006: return "119"
                case 1009: return "122"
                case 1030: return "143"
                case 1063: return "176"
                case 1066: return "179"
                case 1069: return "182"
                case 1072: return "185"
                case 1087: return "200"
                case 1114: return "227"
                case 1117: return "230"
                case 1135: return "248"
                case 1147: return "260"
                case 1150: return "263"
                case 1153: return "266"
                case 1168: return "281"
                case 1171: return "284"
                case 1180: return "293"
                case 1183: return "296"
                case 1186: return "299"
                case 1189: return "302"
                case 1192: return "305"
                case 1195: return "308"
                case 1198: return "311"
                case 1201: return "314"
                case 1204: return "317"
                case 1207: return "320"
                case 1210: return "323"
                case 1213: return "326"
                case 1216: return "329"
                case 1219: return "332"
                case 1222: return "335"
                case 1225: return "338"
                case 1237: return "350"
                case 1240: return "353"
                case 1243: return "356"
                case 1246: return "359"
                case 1249: return "362"
                case 1252: return "365"
                case 1255: return "368"
                case 1258: return "371"
                case 1261: return "374"
                case 1264: return "377"
                case 1273: return "386"
                case 1276: return "389"
                case 1279: return "392"
                case 1282: return "395"
                default: return nil
                }
    }
    
    func dayName(forCode code: Int) -> String? {
        switch code {
                case 0: return "night"
                case 1: return "day"
                default: return nil
        }
    }
    func getAlerts(completion: @escaping (AlertsResponse) -> Void) {
        let key = "81b8d0003a2646febba782c8887bdb23"
        let lat: Double = locationManager.latitude
        let lon: Double = locationManager.longitude
        let alertsUrl = "https://api.weatherbit.io/v2.0/alerts?lat=\(lat)&lon=\(lon)&key=\(key)"
        print("alertsUrl: \(alertsUrl)")
        if let url = URL(string: alertsUrl) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode(AlertsResponse.self, from: data)
                        DispatchQueue.main.async {
                            self.alertData = decodedData
                            self.alertCount = decodedData.alerts.count
                            if decodedData.alerts.count > 0 {
                                print("schedule notification")

                                
                                //scheduleLocalNotification()
                            } else {
                                print("no notifications")
                            }
                            completion(decodedData)
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }
    
    func getTouchedAlerts(completion: @escaping (AlertsResponse) -> Void) {
        let key = "81b8d0003a2646febba782c8887bdb23"
        let _: Double = locationManager.latitude
        let _: Double = locationManager.longitude
        let alertsUrl = "https://api.weatherbit.io/v2.0/alerts?lat=\(latit)&lon=\(longi)&key=\(key)"
        print("alertsUrl: \(alertsUrl)")
        if let url = URL(string: alertsUrl) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode(AlertsResponse.self, from: data)
                        DispatchQueue.main.async {
                            self.alertData = decodedData
                            completion(decodedData)
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }
    
    func weatherSummary(data: WeatherResponse?, completion: @escaping (String) -> Void) {
        let rainChance = data?.forecast.forecastday[0].day.daily_chance_of_rain
        let snowChance = data?.forecast.forecastday[0].day.daily_chance_of_snow
        
        if rainChance ?? 0 > 0 {
            self.precChane = ("\(rainChance ?? 0)%")
        } else if snowChance ?? 0 > 0 {
            self.precChane = ("\(snowChance ?? 0)%")
            } else {
                self.precChane = "0%"
            }
        self.precChance_s = self.precChane

        let summary: String = "Todays High will be \(String(format: "%.0f", data?.forecast.forecastday[0].day.maxtemp_f ?? 0.0))° and the Low will be \(String(format: "%.0f", data?.forecast.forecastday[0].day.mintemp_f ?? 0.0))°. The winds will be around \(String(format: "%.0f",data?.forecast.forecastday[0].day.maxwind_mph ?? 0.0)) mph. There is a \(self.precChance_s) chance of precipitation. The sun will rise at \(data?.forecast.forecastday[0].astro.sunrise ?? "") and will set at \(data?.forecast.forecastday[0].astro.sunset ?? "")."
        completion(summary)
    }
    
}
import UserNotifications

func scheduleLocalNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Open Specific View"
    content.body = "Tap to open the details."
    content.sound = .default
    content.userInfo = ["view": "specificSheet"]  // Custom data to identify the view

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    
    let request = UNNotificationRequest(identifier: "TestNotification", content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error adding notification: \(error)")
        }
    }
}
    
 

