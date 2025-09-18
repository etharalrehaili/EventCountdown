import SwiftUI

struct EventsView: View {
    @State private var events: [Event] = []
    @State private var adding = false
    @State private var editing: Event? = nil
    
    var body: some View {
        NavigationStack {
            Group {
                if events.isEmpty {
                    ContentUnavailableView(
                        "No events yet",
                        systemImage: "calendar.badge.exclamationmark"
                    )
                } else {
                    List {
                        ForEach(
                            events.sorted(by: sortByProximityToNow)
                        ) { event in
                            Button {
                                editing = event
                            } label: {
                                EventRow(event: event)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("Events")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { adding = true } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Event")
                }
            }
            .navigationDestination(isPresented: $adding) {
                EventForm(mode: .add) { newEvent in
                    events.append(newEvent)
                    NotificationScheduler
                        .scheduleEventReminder(for: newEvent) // schedule here
                    adding = false
                }
            }
            .navigationDestination(item: $editing) { event in
                EventForm(mode: .edit(event)) { updated in
                    if let i = events.firstIndex(
                        where: { $0.id == updated.id
                        }) {
                        events[i] = updated
                        NotificationScheduler.cancelReminder(for: updated)
                        NotificationScheduler
                            .scheduleEventReminder(for: updated)
                    }
                    editing = nil
                }
            }
        }
        .onAppear {
            NotificationScheduler.requestAuthorization()
        }
    }
    
    private func delete(at offsets: IndexSet) {
        let sorted = events.sorted(by: sortByProximityToNow)
        let idsToDelete = offsets.map { sorted[$0].id }
        events.removeAll { idsToDelete.contains($0.id) }
    }
    
    private func sortByProximityToNow(_ lhs: Event, _ rhs: Event) -> Bool {
        let now = Date()
        let lhsIsUpcoming = lhs.date >= now
        let rhsIsUpcoming = rhs.date >= now

        switch (lhsIsUpcoming, rhsIsUpcoming) {
        case (true, true):
            // Both upcoming: sooner first
            return lhs.date < rhs.date
        case (false, false):
            // Both past: most recently finished first
            return lhs.date > rhs.date
        case (true, false):
            // Upcoming before past
            return true
        case (false, true):
            return false
        }
    }
    
}
