import SwiftUI

struct FiveDayView: View {
    
    @StateObject private var wvm = WeatherViewModel()
    @State var isDay: Int = 1
    @State var dayNight: String?
    @State var days: [ForecastDay] = []
    @State var selectedDay: Day?
    @State var show: Bool = false

    var body: some View {
            if show {
                HStack {
                    ForEach(days) { day in
                        FiveDayRowView(forecastday: day)
                    }
                    .padding()
                }
            } else {
                ProgressView()
                .onAppear {
                    wvm.getDaily(filter: 24, location: "current", completion: {x in
                        days = x
                        show = true
                    })
                }
            }

    }
}

struct TouchedFiveDayView: View {
    
    @StateObject private var weatherService = WeatherViewModel()
    @State var isDay: Int = 1
    @State var dayNight: String?
    @State var selectedDay: Day?
    @State var show: Bool = false
    @State var days: [ForecastDay] = []


    var body: some View {
        
            if show {
                HStack {
                    ForEach(days) { day in
                        FiveDayRowView(forecastday: day)
                    }
                }
            } else {
                ProgressView()
                .onAppear {
                    weatherService.getDaily(filter: 24, location: "touched", completion: {x in
                        days = x
                        show = true
                    })
                }
            }

    }
}

struct FiveDayRowView: View {
    
    @Environment(\.scenePhase) var scenePhase
    @StateObject var wvm = WeatherViewModel()
    @State var isHidden = true
    @State var dayNight: String?
    @State var isDay: Int = 1

    //let day: Day
    let forecastday: ForecastDay
    
    var body: some View {
        VStack {
            Text(forecastday.date.toDayOfWeek())
            //Text("\(weather.forecast.forecastday[4].date.toDayOfWeek())")
                .font(.system(size: 14))
                //.foregroundColor(Color.white)
            Image("day/\(wvm.imageName(forCode: forecastday.day.condition.code) ?? "")")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)

            Text("\(forecastday.day.mintemp_f, specifier: "%.0f")°/\(forecastday.day.maxtemp_f, specifier: "%.0f")°")
                .font(.system(size: 13))
                //.foregroundColor(Color.white)
        }
    }
}

struct FiveDayView_Previews: PreviewProvider {
    static var previews: some View {
        FiveDayView()
    }
}


