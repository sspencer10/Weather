import UIKit
import UserNotifications
import Firebase
import WidgetKit

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        print("didFinishLaunchingWithOptions")
        return true
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Log the receipt of the notification
        print("Silent notification received: \(userInfo)")
        
        // Optionally log to a remote server for tracking
        logSilentNotification(userInfo: userInfo)
        
        // Handle your background task
        fetchDataInBackground { result in
            switch result {
            case .newData:
                completionHandler(.newData)
            case .noData:
                completionHandler(.noData)
            case .failed:
                completionHandler(.failed)
            @unknown default:
                print("result unknown")
            }
        }
    }
    
    func fetchDataInBackground(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        // Perform your background data fetch here
        WeatherViewModel().fetchWeather(filter: 5, location: "current", completion: { data in
            self.logBackgroundTask(userInfo: data.current.temp_f)
            // After fetching, log the success or failure
            WidgetCenter.shared.reloadAllTimelines()
            completion(.newData)
        })
    }
    
    func logSilentNotification(userInfo: [AnyHashable: Any]) {
        // Send log data to your backend or analytics service
        let url = URL(string: "https://rightdevllc.com/weatherLog.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convert userInfo to JSON data for logging
        if let data = try? JSONSerialization.data(withJSONObject: userInfo, options: []) {
            URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
                if let error = error {
                    print("Failed to log notification: \(error)")
                    return
                }
                print("Silent notification logged successfully")
            }.resume()
        }
    }
    
    func logBackgroundTask(userInfo: Double) {
        // Send log data to your backend or analytics service
        let url = URL(string: "https://rightdevllc.com/weatherLog.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Encode the WeatherResponse into JSON Data
        let encoder = JSONEncoder()
        // Directly use the encoded data, no need for JSONSerialization
        if let jsonData = try? encoder.encode(userInfo) {
            URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
                print("Task logged successfully \(data?.debugDescription ?? "No data")")
            }.resume()
        } else {
            print("Failed to encode WeatherResponse")
        }
    }

    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("APNs device token received: \(deviceToken)")
        Messaging.messaging().subscribe(toTopic: "allDevices") { error in
            if let error = error {
                print("Error subscribing to topic: \(error)")
            } else {
                print("Subscribed to topic: allDevices")
            }
        }
        
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let viewToOpen = userInfo["view"] as? String {
            // Notify SwiftUI view to present specific sheet
            NotificationCenter.default.post(name: Notification.Name("OpenSpecificView"), object: viewToOpen)
        }
        // Call the completion handler
        completionHandler()
    }
}
