import SwiftUI

struct MapViewWithButton: View {

    
    var body: some View {
        ZStack {
            RadarMap(touchMap: false)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        print("Location")
                        // Handle button tap
                    }) {
                        Image(systemName: "location")
                            .padding()
                            .foregroundColor(.white).opacity(1.0)
                            .background(Color.black).opacity(0.75)
                            .clipShape(Circle())
                            
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        print("Maps")
                        // Handle button tap
                    }) {
                        Image(systemName: "map")
                            .padding()
                            .foregroundColor(.white).opacity(1.0)
                            .background(Color.black).opacity(0.75)
                            .clipShape(Circle())
                    }
                    
                    
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        print("Layers")
                        RadarMap(touchMap: false).showPicker = true
                        // Handle button tap
                    }) {
                        Image(systemName: "square.3.layers.3d")
                            .padding()
                            .foregroundColor(.white).opacity(1.0)
                            .background(Color.black).opacity(0.75)
                            .clipShape(Circle())
                            
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
                Spacer()
            }
        }

    }
    
}
struct MapViewWithButton_Previews: PreviewProvider {
    static var previews: some View {
        MapViewWithButton()
    }
}
