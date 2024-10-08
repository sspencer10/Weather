//
//  LineChart.swift
//  Weather
//
//  Created by Steven Spencer on 8/12/24.
//
import SwiftUI
import Foundation

struct LineChart: View {
    var hour: [Hour]
    var maxTemp: Double
    var minTemp: Double

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            let stepX = width / CGFloat(hour.count - 1)
            let tempRange = maxTemp - minTemp
            
            let points = hour.enumerated().map { index, hour -> CGPoint in
                let xPosition = stepX * CGFloat(index)
                let yPosition = height - (CGFloat((hour.temp_f - minTemp) / tempRange) * height)
                return CGPoint(x: xPosition, y: yPosition)
            }

            ZStack {
                // Draw the line chart
                Path { path in
                    guard points.count > 1 else { return }
                    path.move(to: points.first!)
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                .stroke(Color.blue, lineWidth: 2)

                // Draw the x-axis
                Path { path in
                    let yAxisPosition = height
                    path.move(to: CGPoint(x: 0, y: yAxisPosition))
                    path.addLine(to: CGPoint(x: width, y: yAxisPosition))
                }
                .stroke(Color.gray, lineWidth: 1)

                // Draw the y-axis
                Path { path in
                    let xAxisPosition = 0
                    path.move(to: CGPoint(x: CGFloat(xAxisPosition), y: 0))
                    path.addLine(to: CGPoint(x: CGFloat(xAxisPosition), y: height))
                }
                .stroke(Color.gray, lineWidth: 1)

                // X-Axis labels
                ForEach(Array(hour.enumerated()), id: \.offset) { index, hour in
                    let xPosition = stepX * CGFloat(index)
                    Text(formattedHour(from: hour.time))
                        .font(.caption)
                        .rotationEffect(.degrees(-45))
                        .offset(x: xPosition - 140, y: height - 15)
                }
                
                // Y-Axis labels
                let yAxisStep = tempRange / 4
                ForEach(0..<5) { i in
                    let yPosition = height - (CGFloat(Double(i) * yAxisStep) / CGFloat(tempRange) * height)
                    Text("\(minTemp + Double(i) * yAxisStep, specifier: "%.0f")°F")
                        .font(.caption)
                        .offset(x: -170, y: yPosition - 100)
                }
            }
        }
    }
}
func formattedHourLine(from dateString: String) -> String {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "h a"
    
    guard let date = inputFormatter.date(from: dateString) else {
        return "Invalid"
    }
    
    return outputFormatter.string(from: date)
}
struct HourlyLineChart: View {
    @StateObject private var weatherService = WeatherViewModel()

    var body: some View {
        VStack {
            let hourVar = weatherService.forecast ?? []
            LineChart(
                hour: hourVar,
                maxTemp: (hourVar.map { $0.temp_f }.max() ?? 0.0) + 0.0,
                minTemp: (hourVar.map { $0.temp_f }.min() ?? 0.0) - 0.0)
            .frame(height: 200)
            .padding()
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            WeatherViewModel().fetchWeather(filter: 5, location: "current", completion: { print("done") })

        }
    }
}



