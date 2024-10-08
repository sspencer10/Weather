import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(configuration.isOn ? .blue : .gray)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
        }
    }
}

struct AlertView: View {
    @StateObject var viewModel = WeatherViewModel()
    @State private var showFirstView: Bool = true
    @State var weatherJson: WeatherResponse?
    @State var isChecked = false
    @ObservedObject var updateCenter: MyWidgetCenter
    
    @AppStorage("warningAck", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var warningAck: Bool = false
    
    var body: some View {
        ZStack {
            if showFirstView {
                ProgressView()
                    .onAppear {
                        viewModel.fetchWeather(filter: 5, location: "current", completion: { weather in
                            weatherJson = weather
                            showFirstView = false
                        })
                    }
            } else {
                VStack {
                    // Safely unwrap optional alert data
                    if let alert = weatherJson?.alerts?.alert?.first {
                        Text(alert.event)
                            .font(.system(size: 28))
                            .foregroundColor(.red)
                        
                        Text(" ")
                        Text(alert.desc)
                    } else {
                        Text("No Alerts Available")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    }
                    
                    Toggle(isOn: $isChecked) {
                        Text("Check this box to acknowledge the warning")
                    }
                    .toggleStyle(CheckboxToggleStyle())
                    .padding()
                }
                .padding()
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onChange(of: isChecked) {
            handleWarningAcknowledgement()
        }
        .onAppear {
            loadWarningAcknowledgementStatus()
        }
    }
    
    // Handle warning acknowledgement toggle
    private func handleWarningAcknowledgement() {
        if isChecked {
            UserDefaults.standard.set(true, forKey: "warningAcknowledged")
            warningAck = true
            if UserDefaults.standard.object(forKey: "warningAcknowledgedDate") == nil {
                UserDefaults.standard.set(Date(), forKey: "warningAcknowledgedDate")
            }
        } else {
            UserDefaults.standard.set(false, forKey: "warningAcknowledged")
            warningAck = false
            UserDefaults.standard.removeObject(forKey: "warningAcknowledgedDate")
        }
    }
    
    // Load the initial state of the warning acknowledgement
    private func loadWarningAcknowledgementStatus() {
        if UserDefaults.standard.bool(forKey: "warningAcknowledged") {
            if let date = UserDefaults.standard.object(forKey: "warningAcknowledgedDate") as? Date {
                let expirationDate = date.addingTimeInterval(24 * 60 * 60)
                if Date() > expirationDate {
                    isChecked = false
                    UserDefaults.standard.removeObject(forKey: "warningAcknowledgedDate")
                } else {
                    isChecked = true
                }
            }
        }
    }
}

// Helper function for formatting date strings
func formatDateString(_ isoDateString: String) -> String? {
    let isoDateFormatter = ISO8601DateFormatter()

    if let date = isoDateFormatter.date(from: isoDateString) {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MM/dd/yyyy @ hh:mm a"
        return outputFormatter.string(from: date)
    } else {
        return nil
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView(updateCenter: MyWidgetCenter())
    }
}
