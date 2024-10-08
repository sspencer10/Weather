

import SwiftUI

struct TimerView: View {
    @StateObject private var timerManager = TimerManager(initialTime: 300, repeats: true)
    
    var body: some View {
        VStack {
            Text(timeString(time: timerManager.timeRemaining))
                .font(.largeTitle)
                .padding()
            
            Button(action: {
                timerManager.startTimer()
            }) {
                Text("Start Timer")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
