//
//  SevenDay.swift
//  Weather
//
//  Created by Steven Spencer on 7/23/24.
//

import SwiftUI

struct SevenDay: View {
    
    @ObservedObject private var viewModel = WeatherViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var city: String = ""
    @FocusState private var focused: Bool // 1. create a @FocusState here

    var body: some View {
        ScrollView {
            PullToRefresh(coordinateSpaceName: "pullToRefresh") {
                print("refresh")
                viewModel.showFirstView = true
                viewModel.showSecondView = false
                let location = viewModel.getLoc()
                Task {
                    viewModel.fetchWeather()
                    if (location != "42.1673839, -92.0156213") {
                        viewModel.showFirstView = false
                        viewModel.showSecondView = true
                    }
                }
                viewModel.onMySubmit()
            }
            if let weather = viewModel.weather {
                
                    
                    VStack {
                        HStack {
                            if viewModel.count >= 5 {

                            Spacer()
                            VStack {
                                Text("\(weather.forecast.forecastday[0].date.toMMDDFormat())")
                                    .font(.system(size: 15))
                                if let url = URL(string: "https:\(weather.forecast.forecastday[0].day.condition.icon)") {
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
                                Text("\(weather.forecast.forecastday[1].date.toMMDDFormat())")
                                    .font(.system(size: 15))
                                if let url = URL(string: "https:\(weather.forecast.forecastday[1].day.condition.icon)") {
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
                                Text("\(weather.forecast.forecastday[2].date.toMMDDFormat())")
                                    .font(.system(size: 15))
                                if let url = URL(string: "https:\(weather.forecast.forecastday[2].day.condition.icon)") {
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
                                Text("\(weather.forecast.forecastday[3].date.toMMDDFormat())")
                                    .font(.system(size: 15))
                                if let url = URL(string: "https:\(weather.forecast.forecastday[3].day.condition.icon)") {
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
                                Text("\(weather.forecast.forecastday[4].date.toMMDDFormat())")
                                    .font(.system(size: 15))
                                if let url = URL(string: "https:\(weather.forecast.forecastday[4].day.condition.icon)") {
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
                }
            
        }.padding(.top, 150)
        .coordinateSpace(name: "pullToRefresh")
        .onAppear {
            let location = viewModel.getLoc()
            print("Location: \(location)")
            Task {
                viewModel.fetchWeather()
                if (location != "42.1673839, -92.0156213") {
                    viewModel.showFirstView = false
                    viewModel.showSecondView = true
                }
            }
            viewModel.onMySubmit()
        }
    }
}

struct SevenDay_Previews: PreviewProvider {
    static var previews: some View {
        SevenDay()
    }
}

