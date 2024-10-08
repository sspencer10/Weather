import SwiftUI
import BackgroundTasks
import MapKit

struct PermissionView: View {
        @Environment(\.scenePhase) var scenePhase
        @State var lm = LocationManager()
        var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Radar")
                        .padding(.leading, 0)
                        .foregroundColor(Color.white.opacity(0.3))
                    
                    Spacer()
                }
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(Color.black.opacity(0.1))
                    .padding(-5)
                
                VStack {
                    Text("Hello World")
                        .padding(.bottom, 15)
                }
                
            }
            .cardBackground()
            .padding(.top, 0)
            .padding(.bottom, 2)
            .padding(.leading)
            .padding(.trailing)
            onAppear {
                lm.manager.requestWhenInUseAuthorization()
            }
        }
    }
}


struct PermissionView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionView()
    }
}
            
