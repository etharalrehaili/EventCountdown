import SwiftUI

struct EventRow: View {
    let event: Event
    
    // Private timer to refresh the relative date string in real time
    @State private var now = Date()
    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 12) {
            photos
            
            VStack(alignment: .leading) {
                
                Text(event.title)
                    .font(.title3)
                    .bold()
                    .foregroundColor(event.textColor)
                    .strikethrough(
                        event.date < now,
                        pattern: .solid,
                        color: event.textColor.opacity(0.7)
                    )
                
                // date
                Text(relativeDateString(for: event.date, now: now))
                    .foregroundStyle(event.date < now ? .tertiary : .secondary)
                    .onReceive(timer) { tick in
                        now = tick
                    }
            }
        }
    }
    
    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .full // yields strings like "15 hours ago", "in 2 days", "yesterday"
        return f
    }()

    private func relativeDateString(for date: Date, now: Date) -> String {
        let seconds = date.timeIntervalSince(now)
        if abs(seconds) < 60 {
            let adjusted = seconds >= 0 ? 60.0 : -60.0
            return EventRow.relativeFormatter
                .localizedString(fromTimeInterval: adjusted)
        }
        return EventRow.relativeFormatter
            .localizedString(fromTimeInterval: seconds)
    }

    private var photos: some View {
        HStack(spacing: -12) {
            ForEach(
                Array(event.images.prefix(3).enumerated()),
                id: \.offset
            ) { _, img in
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.background, lineWidth: 2))
                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
            }
        }
    }
}
