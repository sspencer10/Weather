import Foundation
import Combine
import SwiftUI

class WeatherService2: ObservableObject {
    @ObservedObject var locationManager = LocationManager()

    
    @Published var forecast: [Hour]? = nil
    @AppStorage("locStr", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var locStr: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    func fetchHourlyForecast() {
        guard let url = URL(string: "https://api.weatherapi.com/v1/forecast.json?key=5aa6d70b54f7455fb2f141924241508&alerts=yes&q=\(locationManager.gps_location)&days=2") else {
            return
        }
        //print("hourly url\(url)")
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching data: \(error)")
                }
            }, receiveValue: { [weak self] response in
                let allHours = response.forecast.forecastday.flatMap { $0.hour }
                self?.forecast = self?.filterNext24Hours(from: allHours)
            })
            .store(in: &cancellables)
    }
    
    
    func fetchHourlyForecast2() {
        guard let url = URL(string: "https://api.weatherapi.com/v1/forecast.json?key=5aa6d70b54f7455fb2f141924241508&alerts=yes&q=\(RadarMap(touchMap: false).locStr)&days=2") else {
            return
        }
        //print("hourly url\(url)")
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching data: \(error)")
                }
            }, receiveValue: { [weak self] response in
                let allHours = response.forecast.forecastday.flatMap { $0.hour }
                self?.forecast = self?.filterNext24Hours(from: allHours)
            })
            .store(in: &cancellables)
    }
    
    func fetchHourlyForecast5Hours() {
        guard let url = URL(string: "https://api.weatherapi.com/v1/forecast.json?key=5aa6d70b54f7455fb2f141924241508&alerts=yes&q=\(locationManager.gps_location)&days=2") else {
            return
        }
        //print("hourly 5 url: \(url)")
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching data: \(error)")
                }
            }, receiveValue: { [weak self] response in
                let allHours = response.forecast.forecastday.flatMap { $0.hour }
                self?.forecast = self?.filterNext5Hours(from: allHours)
            })
            .store(in: &cancellables)
    }
    
    
    private func filterNext24Hours(from hours: [Hour]) -> [Hour] {
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Filter hours starting from the next closest hour
        if let firstHourIndex = hours.firstIndex(where: {
            calendar.compare(currentDate, to: $0.date ?? Date(), toGranularity: .hour) == .orderedAscending
        }) {
            let endIndex = min(firstHourIndex + 24, hours.count)
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
            let endIndex = min(firstHourIndex + 5, hours.count)
            return Array(hours[firstHourIndex..<endIndex])
        }
        
        return []
    }
}
