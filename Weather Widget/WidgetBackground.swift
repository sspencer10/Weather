import SwiftUI

struct WidgetBackgroundView: View {
    @StateObject var wvm: WeatherViewModel
    var body: some View {
        GeometryReader { geometry in
            Image("day")
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
        }
    }
}
