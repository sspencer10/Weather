import SwiftUI

struct HourlyContainer: View {
    @ObservedObject var viewModel: WeatherViewModel
    //
    var body: some View {
        ZStack {

                if (viewModel.isDay == "day_sky") {
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
              
              
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
        }
        .ignoresSafeArea()
    }
}

