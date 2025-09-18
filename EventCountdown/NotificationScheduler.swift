import Foundation
import UserNotifications

enum NotificationScheduler {
    static func requestAuthorization() {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(
                options: [.alert, .sound, .badge]
            ) { granted, error in
                if let error = error {
                    print("Notification authorization error: \(error)")
                } else {
                    print("Notification authorization granted: \(granted)")
                }
            }
    }

    static func scheduleEventReminder(
        for event: Event,
        minutesBefore: TimeInterval = 5
    ) {
        let center = UNUserNotificationCenter.current()
        let fireDate = event.date.addingTimeInterval(-minutesBefore * 60)
        let triggerDate = (fireDate > Date()) ? fireDate : Date().addingTimeInterval(
            1
        )

        print(
            "[NotificationScheduler] Scheduling for:",
            triggerDate,
            "event:",
            event.title
        )

        let comps = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: comps,
            repeats: false
        )

        let content = UNMutableNotificationContent()
        content.title = "Event starting soon"
        content.body = "\(event.title) starts in \(Int(minutesBefore)) minutes."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: event.id.uuidString,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("[NotificationScheduler] Failed to add request:", error)
            } else {
                print(
                    "[NotificationScheduler] Scheduled request:",
                    request.identifier,
                    "for",
                    triggerDate
                )
                UNUserNotificationCenter
                    .current()
                    .getPendingNotificationRequests { reqs in
                        let ids = reqs.map { $0.identifier }
                        print("[NotificationScheduler] Pending IDs:", ids)
                    }
            }
        }
    }

    static func cancelReminder(for event: Event) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [event.id.uuidString]
            )
    }
}
