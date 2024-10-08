//
//  MyView.swift
//  Weather
//
//  Created by Steven Spencer on 8/2/24.
//

import Foundation
import SwiftUI

struct MyView: View {
    @State var locStr: String
    @ObservedObject var viewModel = RadarViewModel2()

    
    var body: some View {
        VStack {
            Text("Test")
            if let weather2 = viewModel.weather2 {
                Text("\(weather2.location.name)")
                Text(viewModel.location_name2)
            }
            
        }
        .onAppear {
            viewModel.fetchLocationWeather2(location: "95628")
        }
    }
}
