import SwiftUI

@main
struct EventCountdownApp: App {
    
    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            EventsView()
        }
    }
}
