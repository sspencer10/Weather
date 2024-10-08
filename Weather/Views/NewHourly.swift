import SwiftUI

struct HourlyForecastView2: View {
    @StateObject private var weatherService = WeatherService()

    var body: some View {
        NavigationView {
            VStack {

                
                ScrollView {
                    LazyVStack {
                        ForEach(weatherService.forecast) { hour in
                            HourRowView2(hour: hour)
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .padding(.bottom, 5)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Hourly Forecast")
            .onAppear {
                weatherService.fetchHourlyForecast()
            }
        }
    }
}


func formattedHour2(from dateString: String) -> String {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "h a"
    
    guard let date = inputFormatter.date(from: dateString) else {
        return "Invalid"
    }
    
    return outputFormatter.string(from: date)
}


struct HourRowView2: View {
    let hour: Hour
    
    var body: some View {
        HStack {
            Text(formattedHour2(from: hour.time))
                .font(.headline)
            Spacer()
            Text(String(format: "%.1f°F", hour.temp_f))
                .font(.subheadline)
            Spacer()
            VStack {
                Text(hour.condition.text)
                    .font(.subheadline)
                AsyncImage(url: URL(string: "https:\(hour.condition.icon)"))
                    .frame(width: 30, height: 30)
            }
        }
    }
}

struct HourlyForecastView2_Previews: PreviewProvider {
    static var previews: some View {
        HourlyForecastView2()
    }
}
