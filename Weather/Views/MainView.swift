import SwiftUI
import MapKit

struct MainView: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var wvm = WeatherViewModel()
    @StateObject var lm = LocationManager()
    @StateObject var day = DayClass()

   // @State var isDay: String
    @State var weather: WeatherResponse?
    @State var bgTime: Int = 0
    @State var activeTime: Int = 0
    @State var isDay: String = "day_sky"
    var body: some View {
        ZStack {
                if (isDay == "day_sky") {
                    Image("day_sky")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Image("night_sky")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                }
            
            TabView() {
                
                ContentView()
                //RadarMap(touchMap: false)
                    .tabItem {
                        Label("Weather", systemImage: "sun.max.circle")
                    }
             
               
           

              
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationBarBackButtonHidden()
        .onChange(of: scenePhase) {oldPhase, newPhase in
            if newPhase == .background {
                let secondsStamp = Int(Date().timeIntervalSince1970)
                UserDefaults.standard.set(secondsStamp, forKey: "backgrounded")
            } else if newPhase == .active {
                wvm.fetchWeather(filter: 5, location: "current", completion: { x in
                        let is_day = weather?.current.is_day
                            if is_day == 1 {
                                print("Day")
                                isDay = day.bgImg(dayInt: 1)
                            } else {
                                print("Night")
                                isDay = day.bgImg(dayInt: 0)
                            }
                        
                    })
                }
             else {
                LocationManager().manager.stopUpdatingLocation()
                LocationManager().manager.startMonitoringSignificantLocationChanges()
            }
            
        }
        .onAppear {
            wvm.fetchWeather(filter: 5, location: "current", completion: { x in
                isDay = wvm.isDay_s
                print("first appeared")
            })
            //print("sky: \(wvm.isDay_s)")
        }
        .ignoresSafeArea()
    }
}

