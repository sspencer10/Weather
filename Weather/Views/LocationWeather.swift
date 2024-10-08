//
//  SevenDay.swift
//  Weather
//    let gradient = Gradient(colors: [.green, .yellow, .red])

//  Created by Steven Spencer on 7/23/24.
//

import SwiftUI
import BackgroundTasks
import MapKit

struct LocationWeather: View {
    @Environment(\.scenePhase) var scenePhase

    @StateObject var viewModel = WeatherViewModel()
    @StateObject var lm = LocationManager()
    @State private var showSheet: Bool = false
    @State private var radarSheet: Bool = false
    @State private var hourlySheet: Bool = false
    @State var showFirstView:Bool = true
    @State var dayNight: String?
    @State var isDay: Int = 1
    @State var isAlert: Bool = false
    @State var isAlert2: Bool = false


    @State public var alertSheet: Bool = false
    @State public var locationPer: Bool = false
    @ObservedObject var updateCenter: MyWidgetCenter
    @ObservedObject var nums: nums
    let gradient = Gradient(colors: [.green, .yellow, .red])
    

    var body: some View {
        
        ZStack {
            
            if (viewModel.isDay_s == "day_sky") {
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
            ScrollView {
 
                    
                    
                    
                    if showFirstView {
                        VStack {
                            ProgressView()
                            Text("Getting location...")
                        }
                        .padding(.top, 250)
                        .onAppear {
                            viewModel.fetchWeather(filter: 5, location: "touched", completion: { x in
                                showFirstView = false
                            })

                        }
                    } else {
                        if let weather = viewModel.weather {
                            PullToRefresh(coordinateSpaceName: "pullToRefresh") {
                                print("refresh")
                                MyWidgetCenter().reloadAllTimelines()
                                WeatherViewModel().fetchWeather(filter: 5, location: "touched", completion: { _ in })
                            }
                            ZStack {
                                if isAlert {
                                    VStack {
                                        HStack {
                                            VStack {
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
                                                TouchedAlertsView()
                                            }
                                        }
                                }
                            }
                            
                            
                            VStack {
                                Text(weather.location.name)
                                VStack {
                                    HStack {
                                        VStack {
                                            
                                            HStack {
                                                Text("\(weather.current.temp_f, specifier: "%.0f")°")
                                                    .font(.system(size: 60))
                                                Text("F").font(.system(size: 40))
                                            }
                                            
                                            Text("Feels Like \(weather.current.feelslike_f, specifier: "%.0f")°")
                                                .font(.system(size: 20))
                                        }
                                        Spacer()
                                        VStack {
                                            if isAlert2 {
                                                if !UserDefaults.standard.bool(forKey: "warningAcknowledged") {
                                                //if AlertView(updateCenter: MyWidgetCenter()).isChecked {
                                                    TouchedAlertsView()
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
                                                                TouchedAlertsView()
                                                                //TouchedAlertView(updateCenter: MyWidgetCenter())
                                                            }
                                                        }
                                                } else {
                                                    Image("\(dayNight ?? "day")/\(viewModel.imageName(forCode: weather.current.condition.code) ?? "")")

                                                                .resizable()
                                                                .aspectRatio(contentMode: .fill)
                                                                .frame(width: 122, height: 32)
                                                                .onTapGesture(count: 1, perform: {
                                                                    alertSheet = true
                                                                })
                                                                .sheet(isPresented: $alertSheet) {
                                                                    ZStack {
                                                                        Color("bg").edgesIgnoringSafeArea(.all)
                                                                        TouchedAlertsView()
                                                                        //TouchedAlertView(updateCenter: MyWidgetCenter())
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
                                .padding(.top, 70)
                                .padding(.bottom, 2)
                                .padding(.leading)
                                .padding(.trailing)
                            
                            VStack {
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
                                    TouchedHourlyForecastFiveView()
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
                                    TouchedHourlyForecastViewSheet()
                                }
                                
                            }
                            
                            
                            VStack {
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
                                    TouchedLocationMapThumb()
                                        .padding(.bottom, 15)
                                }
                                .onTapGesture(count: 1, perform: {
                                    radarSheet = true
                                })
                                .sheet(isPresented: $radarSheet) {
                                    ZStack {
                                        Color("bg").edgesIgnoringSafeArea(.all)
                                        RadarMap(touchMap: true)
                                    }
                                    
                                }
                            }
                            .cardBackground()
                            .padding(.top, 0)
                            .padding(.bottom, 2)
                            .padding(.leading)
                            .padding(.trailing)
                            
                            
                            VStack {
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
                                
                                HStack {
                                    if viewModel.count >= 5 {
                                        
                                        Spacer()
                                        VStack {
                                            Text("\(weather.forecast.forecastday[0].date.toDayOfWeek())")
                                                .font(.system(size: 15))
                                            if let url = URL(string: "http:\(weather.forecast.forecastday[0].day.condition.icon)") {
                                                AsyncImage(url: url) { image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 40, height: 40)
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                            } else {
                                                Text(weather.current.condition.text)
                                                    .font(.title2)
                                            }
                                            Text("\(weather.forecast.forecastday[0].day.mintemp_f, specifier: "%.0f")/\(weather.forecast.forecastday[0].day.maxtemp_f, specifier: "%.0f")")
                                                .font(.system(size: 15))
                                        }
                                        Spacer()
                                        VStack {
                                            Text("\(weather.forecast.forecastday[1].date.toDayOfWeek())")
                                                .font(.system(size: 15))
                                            if let url = URL(string: "http:\(weather.forecast.forecastday[1].day.condition.icon)") {
                                                AsyncImage(url: url) { image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 40, height: 40)
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                            } else {
                                                Text(weather.current.condition.text)
                                                    .font(.title2)
                                            }
                                            Text("\(weather.forecast.forecastday[1].day.mintemp_f, specifier: "%.0f")/\(weather.forecast.forecastday[1].day.maxtemp_f, specifier: "%.0f")")
                                                .font(.system(size: 15))
                                        }
                                        Spacer()
                                        VStack {
                                            Text("\(weather.forecast.forecastday[2].date.toDayOfWeek())")
                                                .font(.system(size: 15))
                                            if let url = URL(string: "http:\(weather.forecast.forecastday[2].day.condition.icon)") {
                                                AsyncImage(url: url) { image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 40, height: 40)
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                            } else {
                                                Text(weather.current.condition.text)
                                                    .font(.title2)
                                            }
                                            Text("\(weather.forecast.forecastday[2].day.mintemp_f, specifier: "%.0f")/\(weather.forecast.forecastday[2].day.maxtemp_f, specifier: "%.0f")")
                                                .font(.system(size: 15))
                                        }
                                        Spacer()
                                        VStack {
                                            Text("\(weather.forecast.forecastday[3].date.toDayOfWeek())")
                                                .font(.system(size: 15))
                                            if let url = URL(string: "http:\(weather.forecast.forecastday[3].day.condition.icon)") {
                                                AsyncImage(url: url) { image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 40, height: 40)
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                            } else {
                                                Text(weather.current.condition.text)
                                                    .font(.title2)
                                            }
                                            Text("\(weather.forecast.forecastday[3].day.mintemp_f, specifier: "%.0f")/\(weather.forecast.forecastday[3].day.maxtemp_f, specifier: "%.0f")")
                                                .font(.system(size: 15))
                                        }
                                        Spacer()
                                        VStack {
                                            Text("\(weather.forecast.forecastday[4].date.toDayOfWeek())")
                                                .font(.system(size: 15))
                                            if let url = URL(string: "http:\(weather.forecast.forecastday[4].day.condition.icon)") {
                                                AsyncImage(url: url) { image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 40, height: 40)
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                            } else {
                                                Text(weather.current.condition.text)
                                                    .font(.title2)
                                            }
                                            Text("\(weather.forecast.forecastday[4].day.mintemp_f, specifier: "%.0f")/\(weather.forecast.forecastday[4].day.maxtemp_f, specifier: "%.0f")")
                                                .font(.system(size: 15))
                                        }
                                        Spacer()
                                    }
                                }
  
 
                            }
                            .cardBackground()
                            .padding(.top, 0)
                            .padding(.bottom, 50)
                            .padding(.leading)
                            .padding(.trailing)
                        }
                    }
                    
                }
                    
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .foregroundColor(.white)
            .coordinateSpace(name: "pullToRefresh")
            .onChange(of: scenePhase) {oldPhase, newPhase in
                if newPhase == .background {
                    let secondsStamp = Int(Date().timeIntervalSince1970)
                    UserDefaults.standard.set(secondsStamp, forKey: "backgrounded")
                } else if newPhase == .active {
                    viewModel.fetchWeather(filter: 5, location: "current", completion: { x in
                        isDay = x.current.is_day
                        if isDay == 0 {
                            dayNight = "night"
                        } else {
                            dayNight = "day"
                        }
                        
                    })
                }
                else {
                    LocationManager().manager.stopUpdatingLocation()
                    LocationManager().manager.startMonitoringSignificantLocationChanges()
                }
                
            }
            .onAppear {
                WeatherViewModel().fetchWeather(filter: 5, location: "touched", completion: { _ in })
                print(RadarViewModel().getOverlayUrls())
                nums.setInt()
                let _: [CachingTileOverlay] = RadarViewModel.shared.loadTileOverlaysFromUserDefaults() ?? []
                let _: Int = RadarViewModel.shared.loadTileOverlaysFromUserDefaults()?.count ?? 1
                // RadarMapView(mapStyle: ContentView.mapStyles[selectedMapStyle], overlay: overlays[index - 1], coordinate: $coordinate, center: $center, zoom: $zoom, latest: $latest, previous: $previous, color: $color).createMapThumbnail()
            }
            
        }

    }

        
        
    






