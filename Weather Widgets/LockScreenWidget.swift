import SwiftUI
import WidgetKit

struct LockScreenEntryView: View {
    var entry: Provider.Entry  // Use the entry from the Provider instead of WeatherViewModel

    var body: some View {
        VStack {
            HStack {
                // Use data from the entry instead of wvm
                Text("\(entry.temp, specifier: "%.0f")°")
                    .font(.title)
                
                if entry.condition == "Alert" {  // You can conditionally display an alert icon
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .renderingMode(.template)
                        .font(.title)
                        .foregroundColor(Color.red)
                        .frame(width: 24, height: 24)
                        .padding()
                        .padding(.trailing, 5)

                } else {
                    // Use the weather image from the entry
                    if let image = UIImage(data: entry.image) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 48, height: 48, alignment: .trailing)
                    }
                }
            }
            Text("Feels Like \(entry.feelsLike, specifier: "%.0f")°")
                .font(.system(size: 10))
        }
        .containerBackground(for: .widget) { }
    }
}
