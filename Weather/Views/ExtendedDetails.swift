import SwiftUI
import Combine

struct ExtendedDetailView: View {
    @StateObject private var wvm = WeatherViewModel()
    @State var isDay: Int = 1
    @State var dayNight: String?
    @State var days: [ForecastDay] = []
    @State var selectedDay: Day?
    @State var show: Bool = false



    var body: some View {
        //ZStack {

        
            NavigationView {
                ZStack {

                    if show {
                        VStack {
                            
                            ScrollView {
                                
                                ForEach(days) { forecastday in
                                    FiveDayDetailRowView(forecastday: forecastday)
                                }
                            }
                            
                        }.padding(.top, 10)
                    } else {
                        ProgressView()
                            .onAppear {
                                wvm.getDaily(filter: 5, location: "current", completion: { x in
                                    days = x
                                    show = true
                                })
                            }
                    }
                }
            }
            .foregroundColor(.white)
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
    }
}
struct FiveDayDetailRowView: View {
    
    @Environment(\.scenePhase) var scenePhase
    @StateObject var wvm = WeatherViewModel()
    @State var isHidden = true
    @State var dayNight: String?
    @State var isDay: Int = 1
    @State var precip: Double = 0.0
    let gradient = Gradient(colors: [.green, .yellow, .red])



    //let day: Day
    let forecastday: ForecastDay
    
    var body: some View {
        ScrollView {
            
                HStack {
                    Text(forecastday.date.toDayOfWeek())
                        .padding(.leading, 0)
                        .foregroundColor(Color.white.opacity(0.5))
                    
                    Spacer()
                }
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(Color.black.opacity(0.1))
                    .padding(-5)
                HStack {
                    
                    Text("\(forecastday.day.mintemp_f, specifier: "%.0f")°/\(forecastday.day.maxtemp_f, specifier: "%.0f")°")
                        .font(.system(size: 30))
                    Spacer()
                    Image("day/\(wvm.imageName(forCode: forecastday.day.condition.code) ?? "")")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 96, height: 64)
                }
                //.padding()
           
            let columns = [
                GridItem(.fixed(70)),
                GridItem(.fixed(75)),
                GridItem(.fixed(0)),
                GridItem(.fixed(90)),
                GridItem(.fixed(75))
                
            ]
            LazyVGrid(columns: columns, spacing: 10) {
                Text("    Wind:")
                    .bold()
                Text("\(forecastday.day.maxwind_mph, specifier: "%.0f") mph")
                Text("  ")
                Text("   Humidity:")
                    .bold()
                Text("\(forecastday.day.avghumidity, specifier: "%.0f") %")
                Text("Sunrise:")
                    .bold()
                Text("\(forecastday.astro.sunrise)")
                Text("  ")
                Text("Sunset:")
                    .bold()
                Text("\(forecastday.astro.sunset)")
            
            }
            
                
                VStack {
                    Text(" ")
                    HStack {
                        Text("Chance of Precipitation: ")
                            .bold()
                        Text("\(precChance(rain: Double(forecastday.day.daily_chance_of_rain), snow: Double(forecastday.day.daily_chance_of_snow)), specifier: "%.0f")%")
                    }
                
                
                
                
                
            }

            
        }
        .cardBackground()
            .padding(.top, 0)
            .padding(.bottom, 2)
            .padding(.leading)
            .padding(.trailing)
        .navigationTitle("5 day forecast")
    }
    func precChance(rain: Double, snow: Double) -> Double {
        var percent: Double = 0
        if rain > 0 {
            percent = rain
        }
        if snow > 0 {
            if snow > rain {
                percent = snow
            }
        }
        return percent
    }
}

struct ExtendedDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExtendedDetailView()
    }
}
