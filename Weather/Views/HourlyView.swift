import SwiftUI

struct HourlyForecastViewSheet: View {
    @StateObject private var weatherService = WeatherViewModel()
    @State var isDay: Int = 1
    @State var dayNight: String?

    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }


    var body: some View {
        NavigationView {
            if weatherService.showView {
                VStack {
                    List {
                        // Custom header as a static view
                        HStack {
                            Text("Time")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                                .foregroundColor(.white)
                            Text("  Temp")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white)
                                .padding(.leading, 12)
                            Text(" RealFeel")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white)
                                .padding(.leading, 5)
                            Text("Condition")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white)
                        }
                        .font(.headline)
                        .padding()
                        .background(Color.black.opacity(0.92))
                        .listRowInsets(EdgeInsets())
                            
                            ForEach(weatherService.forecast ?? []) { hour in
                                HourRowView(viewModel: WeatherViewModel(), hour: hour)
                                    .listRowBackground(Color.black.opacity(0.7)) // Set the row background color
                            }
                        
                    }
                    .navigationTitle("Hourly Forecast")
                    .listStyle(.plain)


                }
                .background(Color.black.opacity(0.7).edgesIgnoringSafeArea(.all)) // Extend the background color to safe areas
            } else {
                ProgressView()
                    .onAppear {
                        weatherService.getHourly(filter: 24, location: "current", completion: {_ in })
                        weatherService.fetchWeather(filter: 24, location: "current", completion: { x in
                            isDay = x.current.is_day
                            if isDay == 0 {
                                dayNight = "night"
                            } else {
                                dayNight = "day"
                            }
                            
                        })
                    }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

struct TouchedHourlyForecastViewSheet: View {
    @StateObject private var weatherService = WeatherViewModel()
    @State var showView: Bool = false
    @State var isDay: Int = 1
    @State var dayNight: String?

    init() {
        let appearance = UINavigationBarAppearance()
        //appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        NavigationView {
            if weatherService.showView {
                VStack {
                    List {
                        // Custom header as a static view
                        HStack {
                            Text("Time")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                                .foregroundColor(.white)
                            Text("  Temp")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white)
                                .padding(.leading, 12)
                            Text(" RealFeel")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white)
                                .padding(.leading, 5)
                            Text("Condition")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white)
                        }
                        .font(.headline)
                        .padding()
                        .background(Color.black.opacity(0.92))
                        .listRowInsets(EdgeInsets())
                            
                            ForEach(weatherService.forecast ?? []) { hour in
                                HourRowView(viewModel: WeatherViewModel(), hour: hour)
                                    .listRowBackground(Color.black.opacity(0.7)) // Set the row background color
                            }
                        
                    }
                    .navigationTitle("Hourly Forecast")
                    .listStyle(.plain)

                    

                }
                .background(Color.black.opacity(0.7).edgesIgnoringSafeArea(.all)) // Extend the background color to safe areas
                
            } else {
                ProgressView()
                    .onAppear {
                        weatherService.getHourly(filter: 24, location: "touched", completion: {x in})
                        weatherService.fetchWeather(filter: 24, location: "touched", completion: { x in
                            isDay = x.current.is_day
                            if isDay == 0 {
                                dayNight = "night"
                            } else {
                                dayNight = "day"
                            }
                        })
                    }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

func formattedHour(from dateString: String) -> String {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "h a"
    
    guard let date = inputFormatter.date(from: dateString) else {
        return "Invalid"
    }
    
    return outputFormatter.string(from: date)
}

struct HourRowView: View {
    @Environment(\.scenePhase) var scenePhase

    @ObservedObject var viewModel: WeatherViewModel
    @State var isHidden = true
    @State var dayNight: String?
    @State var isDay: Int = 1


    let hour: Hour
    
    var body: some View {
        HStack {
            Text(formattedHour(from: hour.time))
                .font(.headline)
                .foregroundColor(Color.white)
            if !isHidden {
                Text("\(viewModel.hourlyFinished)")
            }
                
            Spacer()
            Text(String(format: "%.1f°F", hour.temp_f))
                .font(.subheadline)
                .foregroundColor(Color.white)
            Spacer()
            Text(String(format: "%.1f°F", hour.feelslike_f))
                .font(.subheadline)
                .foregroundColor(Color.white)
            Spacer()
            VStack {
                Image("\(viewModel.dayName(forCode: hour.is_day) ?? "day")/\(viewModel.imageName(forCode: hour.condition.code) ?? "")")

                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 48, height: 48)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2)) // Background color for each row
        .cornerRadius(10)
        .onChange(of: scenePhase) {oldPhase, newPhase in
            viewModel.getHourly(filter: 24, location: "touched", completion: {x in
                if (x[0].is_day == 1) {
                    print("h")
                }
            })

        }
    }
}

struct HourlyForecastView_Previews: PreviewProvider {
    static var previews: some View {
        HourlyForecastViewSheet()
    }
}


