import SwiftUI
import Combine

struct NotificationView: View {
    @StateObject private var viewModel = NotificationViewModel()
    @State private var isSheetPresented = false
    @State private var viewToPresent: String?
    var body: some View {
        VStack {
 /*
            Button("Send Local Notification") {
                scheduleLocalNotification2()
            }
            .buttonStyle(.borderedProminent)*/
            Text("Extended Forecast Detailed View Coming Soon")
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("OpenSpecificView"))) { notification in
            if let view = notification.object as? String {
                viewToPresent = view
                isSheetPresented = true
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            if viewToPresent == "specificSheet" {
                SpecificSheetView()
            }
        }
    }
}

struct SpecificSheetView: View {
    var body: some View {
        Text("This is a specific sheet.")
    }
}

import UserNotifications

func scheduleLocalNotification2() {
    print("scheduleLocalNotification2")
    let content = UNMutableNotificationContent()
    content.title = "Open Specific View"
    content.body = "Tap to open the details."
    content.sound = .default
    content.userInfo = ["view": "specificSheet"]  // Custom data to identify the view

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    
    let request = UNNotificationRequest(identifier: "TestNotification", content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error adding notification: \(error)")
        }
    }
}
