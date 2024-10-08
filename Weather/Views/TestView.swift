//
//  TestView.swift
//  Weather
//
//  Created by Steven Spencer on 8/26/24.
//

import Foundation
import SwiftUI

struct AlertsView: View {
    @State var code: Int = 1003
    @StateObject var wvm = WeatherViewModel()
    @State var dayNight: String = "night"
    @State var alert: AlertsResponse?
    @State var show = true
    var body: some View {
        ScrollView {
            
            VStack {
                if show {
                    ProgressView()
                } else {
                    ForEach(alert?.alerts ?? []) { alert in
                        AlertRowView(viewModel: WeatherViewModel(), alert: alert)
                            .listRowBackground(Color.black.opacity(0.7)) // Set the row background color
                    }            }
            }
            .onAppear {
                wvm.getAlerts(completion: { x in
                    show = false
                    alert = x
                    print(x)
                })
            }
        }.presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .padding()
        
    }
}

struct TouchedAlertsView: View {
    @State var code: Int = 1003
    @StateObject var wvm = WeatherViewModel()
    @State var dayNight: String = "night"
    @State var alert: AlertsResponse?
    @State var show = true
    var body: some View {
        ScrollView {
            
            VStack {
                if show {
                    ProgressView()
                } else {
                    ForEach(alert?.alerts ?? []) { alert in
                        AlertRowView(viewModel: WeatherViewModel(), alert: alert)
                            .listRowBackground(Color.black.opacity(0.7)) // Set the row background color
                    }            }
            }
            .onAppear {
                wvm.getTouchedAlerts(completion: { x in
                    show = false
                    alert = x
                    print(x)
                })
            }
        }.presentationDetents([.large])
            .presentationDragIndicator(.visible)
        
    }
}

struct AlertRowView: View {
    @Environment(\.scenePhase) var scenePhase

    @ObservedObject var viewModel: WeatherViewModel



    let alert: WeatherAlert
    
    var body: some View {
            HStack {
                Text(alert.description)
                    .font(.headline)
                    .foregroundColor(Color.white)
                
            }
            .padding()
            .background(Color.gray.opacity(0.2)) // Background color for each row
            .cornerRadius(10)
            .onChange(of: scenePhase) {oldPhase, newPhase in
                
                
            }
        
    }
}

struct AlertsView_Previews: PreviewProvider {
    static var previews: some View {
        AlertsView()
    }
}

struct TouchedAlertsView_Previews: PreviewProvider {
    static var previews: some View {
        TouchedAlertsView()
    }
}
