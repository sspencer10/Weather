import Firebase
import FirebaseMessaging
import UserNotifications
import UIKit

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate, MessagingDelegate {

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
    }

    // Request notification authorization
    func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error)")
            } else if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    // Handle FCM token refresh and print the new token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Received FCM registration token: \(fcmToken ?? "No token")")
        // Optionally send this token to your server
    }

    // Handle incoming FCM data messages and print to console
    func messaging(_ messaging: Messaging, didReceive remoteMessage: [AnyHashable: Any]) {
        print("Received FCM data message: \(remoteMessage)")
        if let message = remoteMessage["message"] as? String {
            print("Message content: \(message)")
        }
    }

    // Handle notification when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Foreground notification received with data: \(userInfo)")

        // Show the notification as a banner and play sound
        completionHandler([.banner, .sound, .badge])
    }

    // Handle notification interaction (e.g., when the user taps on the notification)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("User interacted with notification: \(userInfo)")
        
        // Handle the notification data as needed
        completionHandler()
    }
}
