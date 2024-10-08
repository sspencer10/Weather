import SwiftUI
// used for LocationWeather
class RadarClass: ObservableObject {
    
    @Published var weather2: WeatherResponse?

    @Published var day2: Int = 1
    @Published var count2: Int = 0
    @Published var showFirstView = true
    @Published var showFirstView2 = true
    @Published var tl: String = ""
    @Published var alert: Bool = false
    @Published var show: Bool = true
    @Published var icon: String = "false"


    var apiKey = "5aa6d70b54f7455fb2f141924241508"
    
    @AppStorage("locStr", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var locStr: String = "Des Moines, IA"
    @AppStorage("isDay", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var isDay: String = ""
    @AppStorage("current_icon", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var current_icon: String = ""
    @AppStorage("imageData", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var imageData: Data = Data()

    var shouldRefress: Bool = false
    
    func fetchLocationWeather() {
        
        //print("fetchLocationWeather")
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=\(self.apiKey)&alerts=yes&q=\(locStr)&days=5"
        //print(urlString)
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to fetch data: \(error.localizedDescription)")
                return
            }
            
            // Validate response
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Failed to fetch data: HTTP \(httpResponse.statusCode)")
                return
            }

            if let data = data {
                do {
                    
                    let decodedData = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    DispatchQueue.main.async {
                        
                        self.weather2 = decodedData
                        self.count2 = decodedData.forecast.forecastday.count
                        self.day2 = decodedData.current.is_day
                        if (decodedData.current.is_day == 1) {
                            self.isDay = "day_sky"
                        } else {
                            self.isDay = "night_sky"
                        }
                        if (decodedData.alerts?.alert?.count ?? 0 > 0) {
                            self.alert = true
                        }
                        self.icon = self.weather2?.current.condition.icon ?? ""
                        self.show = false

                    }
                    
                } catch {
                    print("Error decoding data: \(error)")
                }
            }
        }.resume()
       
    }

}

