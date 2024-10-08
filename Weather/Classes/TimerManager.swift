import Foundation
import Combine

class TimerManager: ObservableObject {
    
    @Published var timeRemaining: Int
    @Published var ready: Bool?
    
    var timer: Timer? = nil
    var repeats: Bool
    var value: Bool
    
    init(initialTime: Int, repeats: Bool, value: Bool) {
        self.timeRemaining = initialTime
        self.repeats = repeats
        self.value = value
    }
    
    func startTimer() {
        //print("timer - started: \(self.ready ?? false)")
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: repeats) { timer in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.ready = self.value
                //print("timer - finished: \(self.ready ?? false)")
                timer.invalidate()
                
                UserDefaults.standard.setValue(self.value, forKey: "timeIndex")
                UserDefaults.standard.setValue(false, forKey: "updateOK")
                UserDefaults.standard.setValue(true, forKey: "a")
            }
        }
    }
    
    func stopTimer() {
        self.timer?.invalidate()
    }
    
}
