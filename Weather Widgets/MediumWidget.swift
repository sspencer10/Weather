import SwiftUI
import WidgetKit

struct MediumEntryView: View {
    @AppStorage("warningAck", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var warningAck: Bool = false
    @State var alertSheet: Bool = false
    let gradient = Gradient(colors: [.green, .yellow, .red])
    var entry: Provider.Entry

    var body: some View {
        VStack {
            HStack {
                VStack {
                    HStack {
                        // Use entry data instead of wvm
                        Text("\(entry.temp, specifier: "%.0f")°")
                            .font(.title)
                    }
                    Text("Feels Like \(entry.feelsLike, specifier: "%.0f")°")
                        .font(.system(size: 10))
                }
                .foregroundColor(.white)

                Spacer()
                
                VStack {
                    // Handle alert logic here (simplified for now)
                    if warningAck {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .renderingMode(.template)
                            .font(.title)
                            .foregroundColor(Color.red)
                            .frame(width: 40, height: 40)
                            .padding()
                            .padding(.trailing, 10)
                            .onTapGesture(count: 1, perform: {
                                alertSheet = true
                            })
                            .sheet(isPresented: $alertSheet) {
                                ZStack {
                                    Color("bg").edgesIgnoringSafeArea(.all)
                                    //AlertView(updateCenter: MyWidgetCenter())
                                }
                            }
                    } else {
                        if let image = UIImage(data: entry.image) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 72, height: 72, alignment: .trailing)
                        }
                    }
                }
            }
            .padding(.bottom, 10)
            .padding(.top, 10)

            HStack {
                Gauge(value: entry.max, in: entry.min...entry.max) {
                    // No label needed
                } currentValueLabel: {
                    // No current value label needed
                } minimumValueLabel: {
                    Text("\(entry.min, specifier: "%.0f")°")
                        .foregroundColor(.white)
                } maximumValueLabel: {
                    Text("\(entry.max, specifier: "%.0f")°")
                        .foregroundColor(.white)
                }
            }
            .tint(gradient)
            .gaugeStyle(.linearCapacity)
            .padding(.leading, 20)
            .padding(.trailing, 20)

            HStack {
                // Use entry date for the updated time
                Text("\(entry.location) updated at \(entry.date, style: .time)")
                    .font(.system(size: 10))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 15)
            .padding(.top, 5)

        }.padding(.top, 3)
        .padding(.bottom, 10)
        .containerBackground(for: .widget) {  // Use containerBackground
            ZStack {
                if entry.date.hour() >= 6 && entry.date.hour() < 18 {
                    Image("day_sky_widget")
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("night_sky_widget")
                        .resizable()
                        .scaledToFill()
                }
            }
        }

    }
}

struct Medium_Widget_Previews: PreviewProvider {
    static var previews: some View {
        MediumEntryView(entry: SimpleEntry(date: Date(), location: "Test", feelsLike: 62.0, temp: 60.0, condition: "Sunny", min: 50.0, max: 65.0, image: Data()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
