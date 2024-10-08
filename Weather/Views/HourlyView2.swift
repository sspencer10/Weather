import SwiftUI

struct TouchedHourlyForecastViewSheet: View {
    @StateObject private var weatherService = WeatherViewModel()

    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        NavigationView {
            VStack {
                List(weatherService.forecast ?? []) { hour in
                    TouchedHourRowView(viewModel: WeatherViewModel(), hour: hour)
                        .listRowBackground(Color.black) // Set the row background color
                }
                .navigationTitle("Hourly Forecast")
                .listStyle(PlainListStyle())
            }
            .background(Color.black.edgesIgnoringSafeArea(.all)) // Extend the background color to safe areas
            .onAppear {
                print(weatherService.fetchWeather(filter: 24, location: "touched"))
            }
        }
    }
}

func formattedHour3(from dateString: String) -> String {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "h a"
    
    guard let date = inputFormatter.date(from: dateString) else {
        return "Invalid"
    }
    
    return outputFormatter.string(from: date)
}

struct TouchedHourRowView: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    let hour: Hour
    
    var body: some View {
        HStack {
            Text(formattedHour3(from: hour.time))
                .font(.headline)
                .foregroundColor(Color.white)
            Spacer()
            Text(String(format: "%.1f°F", hour.temp_f))
                .font(.subheadline)
                .foregroundColor(Color.white)
            Spacer()
            VStack {
                if let url = URL(string: "https:\(hour.condition.icon)") {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                    } placeholder: {
                        ProgressView()
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2)) // Background color for each row
        .cornerRadius(10)
    }
}

struct TouchedHourlyForecastView_Previews: PreviewProvider {
    static var previews: some View {
        TouchedHourlyForecastViewSheet()
    }
}
