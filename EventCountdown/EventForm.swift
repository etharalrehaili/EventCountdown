import SwiftUI
import PhotosUI
import UIKit

enum Mode {
    case add
    case edit(Event)
}

struct EventForm: View {
    let mode: Mode
    var onSave: (Event) -> Void

    // Local draft state (won’t affect parent unless Save is tapped)
    @State private var title: String
    @State private var date: Date
    @State private var textColor: Color
    @State private var images: [UIImage]
    @State private var pickerItems: [PhotosPickerItem] = []

    @Environment(\.dismiss) private var dismiss

    // Keep original id when editing
    private let editingID: UUID?

    init(mode: Mode, onSave: @escaping (Event) -> Void) {
        self.mode = mode
        self.onSave = onSave

        switch mode {
        case .add:
            _title = State(initialValue: "")
            _date = State(initialValue: .now)
            _textColor = State(initialValue: .primary)
            _images = State(initialValue: [])
            editingID = nil
        case .edit(let event):
            _title = State(initialValue: event.title)
            _date = State(initialValue: event.date)
            _textColor = State(initialValue: event.textColor)
            _images = State(initialValue: event.images)
            editingID = event.id
        }
    }

    // if we're on Add mode -> navigation title will be Add Event
    // if we're on Edit mode -> navigation title will be Edit
    private var navTitle: String {
        switch mode {
        case .add:  return "Add Event"
        case .edit(let event): return "Edit \(event.title)"
        }
    }

    var body: some View {
        
        Form {
            
            Section("Events Details") {
                TextField("Title", text: $title, prompt: Text("Title"))
                    .foregroundColor(textColor)
                
                DatePicker("Date", selection: $date)
                
                ColorPicker("Text Color", selection: $textColor)
            }
            
            Section("Photos") {
                PhotosPicker(
                    "Select Photos",
                    selection: $pickerItems,
                    maxSelectionCount: 5,
                    selectionBehavior: .ordered
                )

                if images.isEmpty {
                    Text("No photos selected")
                        .foregroundStyle(.secondary)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(images.indices, id: \.self) { i in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: images[i])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 90, height: 90)
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 10)
                                        )

                                    Button {
                                        images.remove(at: i)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .imageScale(.large)
                                            .foregroundStyle(
                                                .white,
                                                .black.opacity(0.55)
                                            )
                                    }
                                    .offset(x: 6, y: -6)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        
        // navigation title will be based on the navTitle
        .navigationTitle(navTitle)
        
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    let newEvent = Event(
                        id: editingID ?? UUID(),
                        title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                        date: date,
                        textColor: textColor,
                        images: images
                    )
                    onSave(newEvent)
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        
        .onChange(of: pickerItems) { _, newItems in
            Task {
                var newlyLoaded: [UIImage] = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(
                        type: Data.self
                    ),
                       let uiImage = UIImage(data: data) {
                        newlyLoaded.append(uiImage)
                    }
                }
                images.append(contentsOf: newlyLoaded)
                images = Array(images.prefix(5))
                pickerItems.removeAll()
            }
        }
    }
}
