import SwiftUI
import BackgroundTasks

class BackgroundTaskManager {
    
    public static var shared = BackgroundTaskManager()
    
    init() {
        
    }
    
    func scheduleAppRefresh() {
        print("scheduled app refresh")
        let request = BGAppRefreshTaskRequest(identifier: "com.rightdevllc.weather.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Fetch no earlier than 15 minutes from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
            
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
        
    func handleAppRefresh(task: BGAppRefreshTask) {
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
