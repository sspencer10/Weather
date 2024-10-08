import SwiftUI



struct TouchedAlertView: View {
    @StateObject var viewModel = WeatherViewModel()
    @StateObject var lm = LocationManager()
    @State private var showSheet: Bool = false
    @State private var radarSheet: Bool = false
    @State private var hourlySheet: Bool = false
    @State private var hourlyLineSheet: Bool = false
    @State public var alertSheet: Bool = false
    @State public var locationPer: Bool = false
    @State var showFirstView:Bool = true
    @State public var showLine: Bool = false
    @State var weatherJson: WeatherResponse?
    @State var isChecked = false
    @ObservedObject var updateCenter: MyWidgetCenter
    
    @AppStorage("warningAck", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var warningAck: Bool = false
    
    
    var body: some View {
        ZStack {
            if showFirstView {
                ProgressView()
                    .onAppear {
                    viewModel.fetchWeather(filter: 5, location: "touched", completion: { weather in
                        weatherJson = weather
                        //print(weatherJson)
                        showFirstView = false

                    })
                }
            } else {
                VStack {
                    Text("\(weatherJson?.alerts?.alert?[0].event ?? "")")
                        .font(.system(size: 28))
                        .foregroundColor(.red)

                    Text(" ")
                    Text(weatherJson?.alerts?.alert?[0].desc ?? "")
                   // Text(formatDateString(weatherJson?.alerts.alert[0].effective ?? "") ?? "")
                   // Text(formatDateString(weatherJson?.alerts.alert[0].expires ?? "") ?? "")
                    Toggle(isOn: $isChecked) {
                        Text("Check this box to acknowlege the warning")
                    }
                    .toggleStyle(CheckboxToggleStyle())
                    .padding()
                    //Text("HELLO")
                }
                .padding()
            }
        }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .onChange(of: isChecked) {
                if isChecked {
                    UserDefaults.standard.set(true, forKey: "warningAcknowledged")
                    warningAck = true
                    if UserDefaults.standard.object(forKey: "warningAcknowledgedDate") == nil {
                        UserDefaults.standard.set(Date(), forKey: "warningAcknowledgedDate")
                    }
                } else {
                    UserDefaults.standard.set(false, forKey: "warningAcknowledged")
                    warningAck = false
                    UserDefaults.standard.set(nil, forKey: "warningAcknowledgedDate")

                }
            }
            .onAppear {
                if UserDefaults.standard.bool(forKey: "warningAcknowledged") {
                    if UserDefaults.standard.object(forKey: "warningAcknowledgedDate") != nil {
                        let date = UserDefaults.standard.object(forKey: "warningAcknowledgedDate") as! Date
                        let date2 = date.addingTimeInterval(1 * 60 * 60 * 24)
                        if date > date2 {
                            isChecked = false
                            UserDefaults.standard.set(nil, forKey: "warningAcknowledgedDate")
                        } else {
                            isChecked = true
                            print(date)
                            print(date2)
                        }
                    }
                }
            }
    }
}



struct TouchedAlertView_Previews: PreviewProvider {
    static var previews: some View {
        TouchedAlertView(updateCenter: MyWidgetCenter())
    }
}

