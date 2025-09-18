import SwiftUI
import UIKit

// Model representing an event
struct Event: Identifiable, Comparable, Hashable {
    var id = UUID()
    var title: String
    var date: Date
    var textColor: Color
    var images: [UIImage] = []

    static func < (lhs: Event, rhs: Event) -> Bool {
        if lhs.date != rhs.date {
            return lhs.date < rhs.date
        }
        if lhs.title != rhs.title {
            return lhs.title < rhs.title
        }
        return lhs.id.uuidString < rhs.id.uuidString
    }
}
