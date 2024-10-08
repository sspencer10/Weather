import Foundation

struct WeatherResponse: Codable {
    let location: Location
    let current: CurrentWeather
    let forecast: Forecast
    let alerts: Alerts?

    static var placeholder: WeatherResponse {
        return WeatherResponse(
            location: Location.placeholder,
            current: CurrentWeather.placeholder,
            forecast: Forecast.placeholder,
            alerts: Alerts.placeholder
        )
    }
}

struct Location: Codable {
    let name: String
    let region: String
    let country: String
    let localtime: String

    static var placeholder: Location {
        return Location(
            name: "San Francisco",
            region: "California",
            country: "USA",
            localtime: "2024-08-24 10:00"
        )
    }
}

struct CurrentWeather: Codable {
    let temp_f: Double
    let is_day: Int
    let wind_dir: String
    let wind_mph: Double
    let gust_mph: Double
    let uv: Int
    let dewpoint_f: Double
    let humidity: Double
    let feelslike_f: Double
    let condition: WeatherCondition

    static var placeholder: CurrentWeather {
        return CurrentWeather(
            temp_f: 72.0,
            is_day: 1,
            wind_dir: "NW",
            wind_mph: 5.0,
            gust_mph: 7.0,
            uv: 5,
            dewpoint_f: 55.0,
            humidity: 60.0,
            feelslike_f: 72.0,
            condition: WeatherCondition.placeholder
        )
    }
}

struct WeatherCondition: Codable {
    let text: String
    let icon: String
    let code: Int

    static var placeholder: WeatherCondition {
        return WeatherCondition(
            text: "Sunny",
            icon: "https://example.com/sunny.png",
            code: 1000
        )
    }
}

struct Forecast: Codable {
    let forecastday: [ForecastDay]

    static var placeholder: Forecast {
        return Forecast(
            forecastday: [ForecastDay.placeholder]
        )
    }
}

struct ForecastDay: Codable, Identifiable {
    var id: UUID { UUID() }
    let day: Day
    let date: String
    let hour: [Hour]
    let astro: Astro

    static var placeholder: ForecastDay {
        return ForecastDay(
            day: Day.placeholder,
            date: "2024-08-24",
            hour: [Hour.placeholder],
            astro: Astro.placeholder
        )
    }
    
    
}

struct Day: Codable, Identifiable {
    var id: UUID { UUID() }
    let maxtemp_f: Double
    let mintemp_f: Double
    let avgtemp_f: Double
    let maxwind_mph: Double
    let avghumidity: Double
    let condition: DayCondition
    let daily_chance_of_rain: Int
    let daily_chance_of_snow: Int
    let uv: Int

    static var placeholder: Day {
        return Day(
            maxtemp_f: 78.0,
            mintemp_f: 58.0,
            avgtemp_f: 68.0,
            maxwind_mph: 8.0,
            avghumidity: 60.0,
            condition: DayCondition.placeholder,
            daily_chance_of_rain: 10,
            daily_chance_of_snow: 0,
            uv: 5
        )
    }
}

struct DayCondition: Codable {
    let text: String
    let icon: String
    let code: Int

    static var placeholder: DayCondition {
        return DayCondition(
            text: "Partly Cloudy",
            icon: "https://example.com/partly_cloudy.png",
            code: 1000
        )
    }
}

struct Hour: Identifiable, Codable {
    let id: UUID
    let time: String
    let temp_f: Double
    let feelslike_f: Double
    let is_day: Int
    let condition: Condition

    var date: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.date(from: time)
    }

    // CodingKeys excludes the 'id' property because it is generated programmatically
    enum CodingKeys: String, CodingKey {
        case time, temp_f, feelslike_f, is_day, condition
    }

    // Custom initializer for decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()  // Generate a unique UUID
        self.time = try container.decode(String.self, forKey: .time)
        self.temp_f = try container.decode(Double.self, forKey: .temp_f)
        self.feelslike_f = try container.decode(Double.self, forKey: .feelslike_f)
        self.is_day = try container.decode(Int.self, forKey: .is_day)
        self.condition = try container.decode(Condition.self, forKey: .condition)
    }

    // Custom encoder to exclude the 'id' property
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(time, forKey: .time)
        try container.encode(temp_f, forKey: .temp_f)
        try container.encode(feelslike_f, forKey: .feelslike_f)
        try container.encode(is_day, forKey: .is_day)
        try container.encode(condition, forKey: .condition)
    }

    // Static placeholder property
    static var placeholder: Hour {
        return Hour(
            id: UUID(),  // Generate a unique UUID
            time: "2024-08-24 12:00",
            temp_f: 70.0,
            feelslike_f: 70.0,
            is_day: 1,
            condition: Condition.placeholder
        )
    }

    // Initializer to create Hour instances manually
    init(id: UUID = UUID(), time: String, temp_f: Double, feelslike_f: Double, is_day: Int, condition: Condition) {
        self.id = id
        self.time = time
        self.temp_f = temp_f
        self.feelslike_f = feelslike_f
        self.is_day = is_day
        self.condition = condition
    }
}

struct Condition: Codable {
    let text: String
    let icon: String
    let code: Int

    static var placeholder: Condition {
        return Condition(
            text: "Clear",
            icon: "https://example.com/clear.png",
            code: 1000
        )
    }
}

struct Astro: Codable {
    let sunrise: String
    let sunset: String
    let moonrise: String
    let moonset: String

    static var placeholder: Astro {
        return Astro(
            sunrise: "06:00 AM",
            sunset: "08:00 PM",
            moonrise: "07:00 PM",
            moonset: "05:00 AM"
        )
    }
}

struct Alerts: Codable {
    let alert: [Alert]?

    static var placeholder: Alerts {
        return Alerts(
            alert: [Alert.placeholder]
        )
    }
}



struct Alert: Codable, Identifiable {
    var id: UUID { UUID() }
    let headline: String
    let msgtype: String
    let severity: String
    let urgency: String
    let areas: String
    let category: String
    let certainty: String
    let event: String
    let note: String
    let effective: String
    let expires: String
    let desc: String
    let instruction: String

    static var placeholder: Alert {
        return Alert(
            headline: "Severe Thunderstorm Warning",
            msgtype: "Alert",
            severity: "Severe",
            urgency: "Immediate",
            areas: "San Francisco",
            category: "Meteorological",
            certainty: "Likely",
            event: "Thunderstorm",
            note: "Be prepared for severe weather conditions.",
            effective: "2024-08-24T10:00:00Z",
            expires: "2024-08-24T11:00:00Z",
            desc: "A severe thunderstorm warning is in effect for the following areas.",
            instruction: "Seek shelter immediately."
        )
    }
}
