import SwiftUI

struct HourlyForecastFiveView: View {
    @StateObject private var weatherService = WeatherViewModel()

    init() {

    }

    var body: some View {

        if weatherService.showView {
            HStack {
                ForEach(weatherService.forecast ?? []) { hour in
                    HourRowView2(viewModel: WeatherViewModel(), hour: hour).frame(width: 60)
                }

            }

        } else {
            ProgressView()
                .onAppear {
                    weatherService.getHourly(filter: 5, location: "current", completion: { _ in })
                }
        }
        }
    
}

struct TouchedHourlyForecastFiveView: View {
    @StateObject private var weatherService = WeatherViewModel()

    init() {

    }

    var body: some View {
        if weatherService.showView {

            HStack {
                ForEach(weatherService.forecast ?? []) { hour in
                    HourRowView2(viewModel: WeatherViewModel(), hour: hour)
                }
                //.navigationTitle("Hourly Forecast")

            }
            
        } else {
            ProgressView()
                .onAppear {
                    weatherService.getHourly(filter: 5, location: "touched", completion: { _ in })
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
    @ObservedObject var viewModel: WeatherViewModel
    @State var isHidden = true

    let hour: Hour
    
    var body: some View {
        VStack {
            VStack {
                Text(formattedHour(from: hour.time))
                // .font(.headline)
                    .font(.system(size: 14))
                    .foregroundColor(Color.white)
                if !isHidden {
                    Text("\(viewModel.hourlyFinished)")
                }
                
                VStack {
                    Image("\(viewModel.dayName(forCode: hour.is_day) ?? "day")/\(viewModel.imageName(forCode: hour.condition.code) ?? "")")

                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 36, height: 36)
                }
                
                VStack {
                    Text(String(format: "%.0f°", hour.temp_f))
                    //.font(.subheadline)
                        .foregroundColor(Color.white)
                        .font(.system(size: 14))
                }
                //.padding()
            }
            //.padding()
        }.padding(.leading, 8)
            .padding(.trailing, 8)
    }
        
}

struct HourlyForecastView1_Previews: PreviewProvider {
    static var previews: some View {
        HourlyForecastFiveView()
    }
}

struct TouchedHourlyForecastView_Previews: PreviewProvider {
    static var previews: some View {
        TouchedHourlyForecastFiveView()
    }
}
