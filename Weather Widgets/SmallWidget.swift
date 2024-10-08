import SwiftUI
import WidgetKit

struct SmallEntryView: View {
    var entry: Provider.Entry  // Use the entry from the provider
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("\(entry.temp, specifier: "%.0f")°")
                        .font(.system(size: 20, weight: .bold))
                    if entry.condition == "Alert" {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.red)
                            .frame(width: 32, height: 32)
                    } else {
                        if let image = UIImage(data: entry.image) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 48, height: 48)
                        }
                    }
                }
                Text("Feels Like \(entry.feelsLike, specifier: "%.0f")°")
                    .font(.system(size: 10))
            }
            .foregroundColor(.white)
        }
        .padding()
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

#Preview {
    SmallEntryView(entry: SimpleEntry(date: Date(), location: "Test", feelsLike: 62.0, temp: 60.0, condition: "Sunny", min: 50.0, max: 65.0, image: Data()))
}
