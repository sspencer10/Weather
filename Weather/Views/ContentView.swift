//
//  SevenDay.swift
//  Weather
//    let gradient = Gradient(colors: [.green, .yellow, .red])

//  Created by Steven Spencer on 7/23/24.
//

import SwiftUI
import BackgroundTasks
import MapKit

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismiss) var dismiss

    @StateObject var viewModel = WeatherViewModel()
    @StateObject var lm = LocationManager()
    @State private var showSheet: Bool = false
    @State private var radarSheet: Bool = false
    @State private var hourlySheet: Bool = false
    @State private var hourlyLineSheet: Bool = false
    @State public var alertSheet: Bool = false
    @State public var locationPer: Bool = false
    @State private var navigateToMainView = false // State to control navigation
    @State public var showLine: Bool = false
    @State var dayNight: String? = nil
    @State var isAlert: Bool = false
    @State var isAlert2: Bool = false
    @State var height: CGFloat = 50.0
    @State var alerts: AlertsResponse? = nil
    @State private var isSheetPresented = false
    @State private var viewToPresent: String? = nil
    @State var show: Bool = false
    @State var days: [ForecastDay] = []
    @State var extendedforecastsheet: Bool = false
    @State var xx: String = ""
    @State var isChecked: Bool = AlertView(updateCenter: MyWidgetCenter()).isChecked
    @ObservedObject var updateCenter = MyWidgetCenter()
    let gradient = Gradient(colors: [.green, .yellow, .red])
    @State var isDay: Int = 1

    @State var permissions: Bool = false
    var body: some View {
        NavigationStack {
            ZStack {
                if (isDay == 1) {
                    Image("day_sky")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Image("night_sky")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .ignoresSafeArea(edges: .bottom) // Extend to the bottom

                }
                ScrollView {
                    if !permissions {
                        ProgressView()
                            .controlSize(.large)
                            .padding(.top, 250)
                            .onAppear {
                                lm.showPermissionView(completion: { x in
                                    permissions = x
                                })
                            }
                            .onChange(of:lm.permish) {
                                permissions = lm.permish ?? true
                            }
                    } else {
                        
                        if viewModel.showFirstView {
                            VStack {
                                Spacer() // To push the content above up and leave space for the toolbar
                                
                                ProgressView()
                                    .controlSize(.large)
                                Text(" ")
                                
                            }
                            .padding(.top, 250)
                        } else {
                            if let weather = viewModel.weather {
                                PullToRefresh(coordinateSpaceName: "pullToRefresh") {
                                    print("refresh")
                                    
                                    let a = Date().timeIntervalSince1970 - 5*60
                                    UserDefaults.standard.set(a, forKey: "updateTimer")
                                    updateCenter.reloadAllTimelines()
                                    viewModel.fetchWeather(filter: 5, location: "current", completion: { _ in })
                                }
                                ZStack {
                                    if isAlert {
                                        VStack {
                                            Spacer() // To push the content above up and leave space for the toolbar
                                            
                                            HStack {
                                                VStack {
                                                    Spacer() // To push the content above up and leave space for the toolbar
                                                    
                                                    Image(systemName: "exclamationmark.triangle")
                                                        .resizable()
                                                        .foregroundColor(Color.red)
                                                        .frame(width: 30, height: 30, alignment: .leading)
                                                        .padding()
                                                }
                                                //Spacer()
                                                Text("Severe Weather Alert")
                                                    .font(.system(size: 18))
                                                    .padding(.leading, 30)
                                                
                                                Spacer()
                                                
                                            }
                                        }.cardBackground()
                                            .padding(.top, 50)
                                            .padding(.bottom, 2)
                                            .padding(.leading)
                                            .padding(.trailing)
                                            .onTapGesture(count: 1, perform: {
                                                alertSheet = true
                                            })
                                            .sheet(isPresented: $alertSheet) {
                                                ZStack {
                                                    Color("bg").edgesIgnoringSafeArea(.all)
                                                    AlertsView()
                                                }
                                            }
                                    }
                                }
                                
                                VStack {
                                    Spacer() // To push the content above up and leave space for the toolbar
                                    
                                    HStack {
                                        Text(weather.location.name)
                                            .font(.system(size: 18))
                                    }
                                    
                                    VStack {
                                        Spacer() // To push the content above up and leave space for the toolbar
                                        
                                        HStack {
                                            VStack {
                                                Spacer() // To push the content above up and leave space for the toolbar
                                                
                                                
                                                HStack {
                                                    Text("\(weather.current.temp_f, specifier: "%.0f")°")
                                                        .font(.system(size: 60))
                                                    Text("F").font(.system(size: 40))
                                                }
                                                
                                                Text("Feels Like \(weather.current.feelslike_f, specifier: "%.0f")°")
                                                    .font(.system(size: 20))
                                            }
                                            .padding()
                                            Spacer()
                                            VStack {
                                                Spacer() // To push the content above up and leave space for the toolbar
                                                
                                                if isAlert2 {
                                                    if !UserDefaults.standard.bool(forKey: "warningAcknowledged") {
                                                        //if AlertsView(updateCenter: MyWidgetCenter()).isChecked {
                                                        
                                                        Image(systemName: "exclamationmark.triangle")
                                                            .resizable()
                                                            .renderingMode(.template)
                                                            .font(.title)
                                                            .foregroundColor(Color.red)
                                                            .frame(width: 50, height: 50)
                                                            .padding()
                                                            .padding(.trailing, 30)
                                                            .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                                                                alertSheet = true
                                                            })
                                                            .sheet(isPresented: $alertSheet) {
                                                                ZStack {
                                                                    Color("bg").edgesIgnoringSafeArea(.all)
                                                                    AlertsView()
                                                                }
                                                            }
                                                    } else {
                                                        Image("\(dayNight ?? "day")/\(viewModel.imageName(forCode: weather.current.condition.code) ?? "")")
                                                        
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .frame(width: 96, height: 32)
                                                            .onTapGesture(count: 1, perform: {
                                                                alertSheet = true
                                                            })
                                                            .sheet(isPresented: $alertSheet) {
                                                                ZStack {
                                                                    Color("bg").edgesIgnoringSafeArea(.all)
                                                                    AlertsView()
                                                                }
                                                            }
                                                        
                                                        
                                                        
                                                        
                                                        
                                                    }
                                                } else {
                                                    
                                                    Image("\(dayNight ?? "day")/\(viewModel.imageName(forCode: weather.current.condition.code) ?? "")")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 122, height: 32)
                                                }
                                            }
                                        }
                                        
                                        VStack {
                                            Spacer() // To push the content above up and leave space for the toolbar
                                            
                                            Spacer()
                                            Text("\(weather.current.condition.text)")
                                                .multilineTextAlignment(.center)
                                                .font(.system(size: 22))
                                                .padding(.top, 15)
                                                .padding(.bottom, 15)
                                        }
                                        
                                        HStack {
                                            
                                            Gauge(value: weather.forecast.forecastday[0].day.maxtemp_f, in: weather.forecast.forecastday[0].day.mintemp_f...weather.forecast.forecastday[0].day.maxtemp_f) {
                                                
                                            } currentValueLabel: {
                                                
                                            } minimumValueLabel: {
                                                Text("\(weather.forecast.forecastday[0].day.mintemp_f, specifier: "%.0f")°")
                                                    .foregroundColor(.white)
                                            } maximumValueLabel: {
                                                Text("\(weather.forecast.forecastday[0].day.maxtemp_f, specifier: "%.0f")°")
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .tint(gradient)
                                        .gaugeStyle(.linearCapacity)
                                        .padding(.leading, 20)
                                        .padding(.trailing, 20)
                                        .padding(.bottom, 15)
                                        .padding(.top, 10)
                                        
                                        
                                    }
                                    let columns = [
                                        GridItem(.fixed(30)),
                                        GridItem(.fixed(80)),
                                        GridItem(.fixed(30)),
                                        GridItem(.fixed(30)),
                                        GridItem(.fixed(80))
                                        
                                    ]
                                    LazyVGrid(columns: columns, spacing: 20) {
                                        
                                        Image(systemName: "wind")
                                            .resizable()
                                            .renderingMode(.template)
                                            .font(.title)
                                            .foregroundColor(Color.white)
                                            .frame(width: 30, height: 30)
                                        
                                        Text("\(weather.current.wind_mph, specifier: "%.0f") mph")
                                            .font(.system(size: 17))
                                        Text("")
                                        
                                        Image(systemName: "location").resizable()
                                            .renderingMode(.template)
                                            .font(.title)
                                            .foregroundColor(Color.white)
                                            .frame(width: 24, height: 24)
                                        
                                        Text("\(weather.current.wind_dir) ")
                                            .font(.system(size: 17))
                                        
                                        
                                        
                                        
                                        Image(systemName: "humidity")
                                            .resizable()
                                            .renderingMode(.template)
                                            .font(.title)
                                            .foregroundColor(Color.white)
                                            .frame(width: 30, height: 30)
                                        
                                        Text("\(weather.current.humidity, specifier: "%.0f")%")
                                            .font(.system(size: 17))
                                        Text(" ")
                                        
                                        Image("dew.point").resizable()
                                            .renderingMode(.template)
                                            .font(.title)
                                            .foregroundColor(Color.white)
                                            .frame(width: 30, height: 30)
                                        
                                        Text("\(weather.current.dewpoint_f, specifier: "%.0f")°")
                                            .font(.system(size: 17))
                                        
                                        
                                        Image(systemName: "sunrise")
                                            .resizable()
                                            .renderingMode(.template)
                                            .font(.title)
                                            .foregroundColor(Color.white)
                                            .frame(width: 30, height: 30)
                                        
                                        Text(weather.forecast.forecastday[0].astro.sunrise)
                                            .font(.system(size: 17))
                                        Text(" ")
                                        
                                        Image(systemName: "sunset").resizable()
                                            .renderingMode(.template)
                                            .font(.title)
                                            .foregroundColor(Color.white)
                                            .frame(width: 30, height: 30)
                                        
                                        Text("\(weather.forecast.forecastday[0].astro.sunset)")
                                            .font(.system(size: 17))
                                        
                                    }
                                    .padding()
                                    
                                    
                                    
                                    
                                }.cardBackground()
                                    .padding(.top, height)
                                    .padding(.bottom, 2)
                                    .padding(.leading)
                                    .padding(.trailing)
                                
                                VStack {
                                    Spacer() // To push the content above up and leave space for the toolbar
                                    
                                    HStack {
                                        Text("Summary")
                                            .padding(.leading, 0)
                                            .foregroundColor(Color.white.opacity(0.3))
                                        
                                        Spacer()
                                    }
                                    
                                    Rectangle()
                                        .frame(height: 2)
                                        .foregroundColor(Color.black.opacity(0.1))
                                        .padding(-5)
                                    
                                    Text(viewModel.summary_s)
                                        .font(.system(size: 17, design: .rounded))
                                        .lineSpacing(5)
                                        .padding(.bottom, 10)
                                    
                                }
                                .cardBackground()
                                .padding(.top, 0)
                                .padding(.bottom, 2)
                                .padding(.leading)
                                .padding(.trailing)
                                
                                
                                
                                VStack {
                                    Spacer() // To push the content above up and leave space for the toolbar
                                    
                                    HStack {
                                        Text("Hourly")
                                            .padding(.leading, 0)
                                            .foregroundColor(Color.white.opacity(0.3))
                                        
                                        Spacer()
                                    }
                                    
                                    Rectangle()
                                        .frame(height: 2)
                                        .foregroundColor(Color.black.opacity(0.1))
                                        .padding(-5)
                                    
                                    VStack {
                                        Spacer() // To push the content above up and leave space for the toolbar
                                        
                                        HourlyForecastFiveView()
                                            .padding(.top, 10)
                                            .padding(.bottom, 10)
                                    }
                                    
                                }
                                .cardBackground()
                                .padding(.top, 0)
                                .padding(.bottom, 2)
                                .padding(.leading)
                                .padding(.trailing)
                                .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                                    hourlySheet = true
                                })
                                .sheet(isPresented: $hourlySheet) {
                                    ZStack {
                                        Color("bg").edgesIgnoringSafeArea(.all)
                                        HourlyForecastViewSheet()
                                    }
                                    
                                }
                                
                                VStack {
                                    Spacer() // To push the content above up and leave space for the toolbar
                                    
                                    HStack {
                                        Text("Radar")
                                            .padding(.leading, 0)
                                            .foregroundColor(Color.white.opacity(0.3))
                                        
                                        Spacer()
                                    }
                                    
                                    Rectangle()
                                        .frame(height: 2)
                                        .foregroundColor(Color.black.opacity(0.1))
                                        .padding(-5)
                                    
                                    VStack {
                                        Spacer() // To push the content above up and leave space for the toolbar
                                        
                                        MyThumbnailView()
                                            .padding(.bottom, 15)
                                    }
                                    .onTapGesture(count: 1, perform: {
                                        radarSheet = true
                                    })
                                    .sheet(isPresented: $radarSheet) {
                                        ZStack {
                                            Color("bg").edgesIgnoringSafeArea(.all)
                                            RadarMap(touchMap: false)
                                            //NotificationView()
                                        }
                                        
                                    }
                                }
                                .cardBackground()
                                .padding(.top, 0)
                                .padding(.bottom, 2)
                                .padding(.leading)
                                .padding(.trailing)
                                
                                VStack {
                                    Spacer() // To push the content above up and leave space for the toolbar
                                    
                                    HStack {
                                        Text("Extended Forecast")
                                            .padding(.leading, 0)
                                            .foregroundColor(Color.white.opacity(0.3))
                                        
                                        Spacer()
                                    }
                                    
                                    Rectangle()
                                        .frame(height: 2)
                                        .foregroundColor(Color.black.opacity(0.1))
                                        .padding(-5)
                                    
                                    if show {
                                        HStack {
                                            ForEach(days) { day in
                                                FiveDayRowView(forecastday: day).frame(width: 60)
                                            }
                                            .padding(.bottom, 15)
                                            
                                        }
                                    } else {
                                        ProgressView()
                                            .onAppear {
                                                viewModel.getDaily(filter: 24, location: "current", completion: {x in
                                                    days = x
                                                    show = true
                                                })
                                            }
                                    }
                                    
                                }
                                .cardBackground()
                                .padding(.top, 0)
                                .padding(.bottom, 40)
                                .padding(.leading)
                                .padding(.trailing)
                                .onTapGesture(count: 1, perform: {
                                    extendedforecastsheet = true
                                })
                                .sheet(isPresented: $extendedforecastsheet) {
                                    ZStack {
                                        Color("bg").edgesIgnoringSafeArea(.all)
                                        //RadarMap(touchMap: false)
                                        ExtendedDetailView()
                                    }
                                    .preferredColorScheme(.dark)
                                    
                                }
                                
                                
                                
                                Spacer()
                                Spacer()
                                Spacer()
                                // end of content
                            }
                        }
                    }
                }
                .foregroundColor(.white)
                .coordinateSpace(name: "pullToRefresh")
                .onChange(of: scenePhase) {
                    if scenePhase == .background {
                        lm.startTrackingSignificantLocation()
                        let secondsStamp = Int(Date().timeIntervalSince1970)
                        UserDefaults.standard.set(secondsStamp, forKey: "backgrounded")
                    } else if scenePhase == .active {
                        lm.startTrackingLocation()
                        viewModel.fetchWeather(filter: 5, location: "current", completion: { x in
                            xx = x.location.localtime
                            isDay = x.current.is_day
                            if isDay == 0 {
                                dayNight = "night"
                            } else {
                                dayNight = "day"
                            }
                            updateCenter.reloadAllTimelines()
                            lm.startTrackingLocation()
                        })
                        viewModel.getAlerts(completion: { x in
                            if (x.alerts.count > 0) {
                                isAlert = true
                                height = 0
                                alerts = x
                            } else {
                                height = 50
                                isAlert = false
                            }
                        })
                    }
                    else {
                        LocationManager().manager.stopUpdatingLocation()
                        LocationManager().manager.startMonitoringSignificantLocationChanges()
                    }
                    
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("OpenSpecificView"))) { notification in
                    if let view = notification.object as? String {
                        viewToPresent = view
                        isSheetPresented = true
                    }
                }
                .sheet(isPresented: $isSheetPresented) {
                    if viewToPresent == "specificSheet" {
                        AlertsView()
                    }
                }
                .navigationBarBackButtonHidden()
                .onAppear {
                    updateCenter.reloadAllTimelines()
                    viewModel.fetchWeather(filter: 5, location: "current", completion: { _ in })
                    //print(RadarViewModel().getOverlayUrls())
                    let _: [CachingTileOverlay] = RadarViewModel.shared.loadTileOverlaysFromUserDefaults() ?? []
                    let _: Int = RadarViewModel.shared.loadTileOverlaysFromUserDefaults()?.count ?? 1
                    // RadarMapView(mapStyle: ContentView.mapStyles[selectedMapStyle], overlay: overlays[index - 1], coordinate: $coordinate, center: $center, zoom: $zoom, latest: $latest, previous: $previous, color: $color).createMapThumbnail()
                }
                
                ZStack(alignment: .bottom)  {
                                               // Background with blur and semi-transparent effect
                                               Color.clear
                                                   .background(.clear) // Use system material blur
                                                   .ignoresSafeArea(edges: .bottom) // Extend to the bottom
                                               VStack {
                                                   Text(" ")
                                                   HStack {
                                                       Button(action: {
                                                           print("First button tapped")
                                                           radarSheet = true
                                                       }) {
                                                           Image(systemName: "map")
                                                               .font(.system(size: 18))
                                                               .foregroundColor(.white)
                                                       }
                                                       .padding(.horizontal)
                                                       Spacer()
                                                       Button(action: {
                                                           // Perform your action here
                                                          // dismiss() // Dismiss the view

                                                           // Trigger navigation after action
                                                           navigateToMainView = true
                                                           dismiss()
                                                       }) {
                                                           Image(systemName: "gear")
                                                               .font(.system(size: 18))
                                                               .foregroundColor(.white)
                                                       }
                                                       .padding()
                                                       .sheet(isPresented: $navigateToMainView) {
                                                           ZStack {
                                                               Color("bg").edgesIgnoringSafeArea(.all)
                                                               SetupView()
                                                           }
                                                       }
                                                       
                                                       .padding(.horizontal)
                                                   }
                                                   .padding(.horizontal)
                                                   Text(" ")
                                               }
                                               .frame(maxWidth: .infinity, maxHeight: 60) // Up to 300 points height

                                               .background(Color("darkblue").opacity(tbop()))
                                           }
                                       }
                                   
                           
                       }
            }
    func tbop() -> Double {
        if (isDay == 1) {
            return 0.60
        } else {
            return 0.86
        }
    }
        }
    
    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(wvm: WeatherViewModel(), isDay: "day_sky")
    }
}


    
// Define the function
func convertToTimeFormat(from dateString: String) -> String? {
    // Create a DateFormatter for the input format
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    
    // Convert the string to a Date object
    if let date = inputFormatter.date(from: dateString) {
        // Create another DateFormatter for the output format
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
        let time24 = outputFormatter.string(from: date)
        
        if let time12 = convertTo12HourFormat(time24: time24) {
            //print("12-hour format: \(time12)") // Output: 12-hour format: 2:30 PM
            return time12
        } else {
            //print("Invalid time format")
            return nil
        }
        // Convert the Date object back to a string
        
    } else {
        return nil // Return nil if the date format is invalid
    }
}

func convertTo12HourFormat(time24: String) -> String? {
    // Create a DateFormatter to parse the 24-hour time string
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm" // Input format: 24-hour time (e.g., 14:30)
    
    // Convert the 24-hour time string to a Date object
    if let date = dateFormatter.date(from: time24) {
        // Create another DateFormatter for the 12-hour time format
        dateFormatter.dateFormat = "h:mm a" // Output format: 12-hour time (e.g., 2:30 PM)
        let time12 = dateFormatter.string(from: date)
        return time12
    }
    
    // Return nil if the conversion fails
    return nil
}
    


