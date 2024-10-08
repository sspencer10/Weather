//
//  WeatherlyWiseApp.swift
//  Weather
//
//  Created by Steven Spencer on 8/19/24.
//

import SwiftUI
import BackgroundTasks
import WidgetKit

@main
struct WeatherlyWiseApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var notificationManager = NotificationManager()


    @StateObject var wvm = WeatherViewModel()
    @State var bgTime: Int = 0
    @State var activeTime: Int = 0
    @StateObject var day = DayClass()
    init() {
        registerBackgroundTasks()
    }

    var body: some Scene {
        WindowGroup {
            if UserDefaults.standard.bool(forKey: "weatherlySettings") {
                MainView(wvm: WeatherViewModel(), isDay: "day_sky")
                    .onAppear {
                        //notificationManager.requestNotificationAuthorization()
                    }
            } else {
                SetupView()
            }

        }
        .onChange(of: scenePhase) {oldPhase, newPhase in
            if newPhase == .background {
                let secondsStamp = Int(Date().timeIntervalSince1970)
                UserDefaults.standard.set(secondsStamp, forKey: "backgrounded")
                scheduleAppRefresh()
                //print("background ")
                bgTime = Int(Date().timeIntervalSince1970)
                print("App in background")
                if UserDefaults.standard.bool(forKey: "whenInUse") {
                    LocationManager().manager.requestAlwaysAuthorization()
                }
                LocationManager().manager.stopUpdatingLocation()
                LocationManager().manager.startMonitoringSignificantLocationChanges()
            } else if newPhase == .active {
                print("App Active")
                WidgetCenter.shared.reloadAllTimelines()
                activeTime = Int(Date().timeIntervalSince1970)
                //print(activeTime)
                print(activeTime - bgTime)
                let timeInBackground: Int = activeTime - bgTime
                if (timeInBackground > (5  * 1)) {
                    wvm.fetchWeather(filter: 5, location: "current", completion: { x in
                        
                            print("fetched data ")

                        
                    })
                }
                LocationManager().manager.startUpdatingLocation()
                LocationManager.shared.stopMonitoringSignificantLocationChanges()
            } else {
                LocationManager().manager.stopUpdatingLocation()
                LocationManager().manager.startMonitoringSignificantLocationChanges()
            }
            
        }

    }
    


    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.rightdevllc.weather.refresh", using: nil) { task in
            print("BGAppRefreshTask started with identifier: \(task.identifier)")
            handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }

    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.rightdevllc.weather.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes from now

        do {
            try BGTaskScheduler.shared.submit(request)
            print("Successfully scheduled BGAppRefreshTask with identifier: \(request.identifier)")
        } catch {
            print("Could not schedule app refresh: \(error.localizedDescription)")
        }
    }

    private func handleAppRefresh(task: BGAppRefreshTask) {
        print("Handling BGAppRefreshTask...")
        
        // Reschedule the next refresh task
        scheduleAppRefresh()
        print("Scheduled the next BGAppRefreshTask.")

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        let operation = BlockOperation {
            print("Performing the background refresh operation.")

            WeatherViewModel().fetchWeather(filter: 5, location: "current", completion: { data in
                print("Background refresh operation completed.")
            })
        }

        task.expirationHandler = {
            print("BGAppRefreshTask is expiring. Cancelling operations...")
            queue.cancelAllOperations()
        }

        operation.completionBlock = {
            if operation.isCancelled {
                print("BGAppRefreshTask was cancelled.")
            } else {
                print("BGAppRefreshTask completed successfully.")
            }
            task.setTaskCompleted(success: !operation.isCancelled)
        }

        queue.addOperation(operation)
        print("Operation added to the queue.")
    }
}
