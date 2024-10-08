import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), location: "Placeholder", feelsLike: 62.0, temp: 60.0, condition: "Sunny", min: 50.0, max: 65.0, image: Data())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), location: "Snapshot", feelsLike: 62.0, temp: 60.0, condition: "Sunny", min: 50.0, max: 65.0, image: Data())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        print("getting Timeline")
        let currentDate = Date()

        // Perform the actual weather data fetching
        fetchWeather { weatherData, imageData in
            let entries: [SimpleEntry]
            if let weather = weatherData {
                let entry = SimpleEntry(
                    date: currentDate,
                    location: weather.location.name,
                    feelsLike: weather.current.feelslike_f,
                    temp: weather.current.temp_f,
                    condition: weather.current.condition.text,
                    min: weather.forecast.forecastday[0].day.mintemp_f,
                    max: weather.forecast.forecastday[0].day.maxtemp_f,
                    image: imageData // Set the image data
                )
                entries = [entry]
            } else {
                // Fallback in case fetching fails
                entries = [SimpleEntry(date: currentDate, location: "Unknown", feelsLike: 0, temp: 0, condition: "Error", min: 0, max: 0, image: Data())]
            }

            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
            let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }

    // Fetch both weather data and image data, and return them via the completion handler
    func fetchWeather(completion: @escaping (_ data: WeatherResponse?, _ imgData: Data) -> Void) {
        @AppStorage("widgetLocation", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var widgetLocation_s: String = "Vinton, IA"
        @AppStorage("widgetLocationCurrent", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var widgetLocationCurrent: Bool = false
        @AppStorage("currentLocation", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var currentLocation: String = ""
        var myLocation = ""
        if widgetLocationCurrent {
            myLocation = currentLocation
        } else {
            myLocation = widgetLocation_s
        }
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=5aa6d70b54f7455fb2f141924241508&q=\(myLocation)&days=5"
        print("widget fetch url: \(urlString)")
        guard let url = URL(string: urlString) else {
            completion(nil, Data()) // Handle error case
            return
        }

        // Fetch weather data
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil, Data()) // Handle error case
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(WeatherResponse.self, from: data)
                
                // Fetch icon image after weather data is successfully decoded
                let iconUrl = "https:\(decodedData.current.condition.icon)"
                if let iconURL = URL(string: iconUrl) {
                    URLSession.shared.dataTask(with: iconURL) { imageData, response, error in
                        guard let imageData = imageData else {
                            completion(decodedData, Data()) // Return weather data but no image
                            return
                        }

                        // Call the completion handler with both the weather data and image data
                        completion(decodedData, imageData)
                    }.resume()
                } else {
                    // If image URL is invalid, return just the weather data
                    completion(decodedData, Data())
                }
            } catch {
                print("Error decoding data: \(error)")
                completion(nil, Data()) // Handle decoding error
            }
        }.resume()
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let location: String
    let feelsLike: Double
    let temp: Double
    let condition: String
    let min: Double
    let max: Double
    let image: Data
}

// Medium Widget
struct Medium_Widget: Widget {
    let kind: String = "Medium Weather Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MediumEntryView(entry: entry)
        }
        .supportedFamilies([.systemMedium])
    }
}

// Small Widget
struct Small_Widget: Widget {
    let kind: String = "Small Weather Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SmallEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall])
    }
}

// Lock Screen Widget
struct LockScreen_Widget: Widget {
    let kind: String = "Lockscreen Widget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LockScreenEntryView(entry: entry)
        }
        .supportedFamilies([.accessoryRectangular])
    }
}
