import SwiftUI

class NotificationViewModel: ObservableObject {
    @Published var message: String = "Waiting for notification..."
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: Notification.Name("CustomNotification"), object: nil)
    }
    
    @objc private func handleNotification() {
        message = "Notification received!"
    }
}

