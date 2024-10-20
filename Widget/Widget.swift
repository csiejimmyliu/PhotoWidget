import WidgetKit
import SwiftUI

// Timeline entry structure, holding a single image and a date
struct PhotoWidgetEntry: TimelineEntry {
    let date: Date
    let image: UIImage?  // Each entry will hold one image
}

// The provider for the timeline, responsible for managing widget updates
struct PhotoWidgetProvider: TimelineProvider {

    // Placeholder entry for preview in the widget gallery
    func placeholder(in context: Context) -> PhotoWidgetEntry {
        return PhotoWidgetEntry(date: Date(), image: nil)
    }

    // Snapshot is used when the widget needs a quick, static preview
    func getSnapshot(in context: Context, completion: @escaping (PhotoWidgetEntry) -> ()) {
        let images = PhotoStore.shared.loadPhotos()
        let entry = PhotoWidgetEntry(date: Date(), image: images.first)
        completion(entry)
    }

    // The main timeline function that determines the content shown in the widget
    func getTimeline(in context: Context, completion: @escaping (Timeline<PhotoWidgetEntry>) -> ()) {
        let images = PhotoStore.shared.loadPhotos()
        var entries: [PhotoWidgetEntry] = []

        // Ensure we have images to display
        if !images.isEmpty {
            let startDate = Date()

            // Loop through the images repeatedly and create enough entries to cover a longer period of time
            var currentDate = startDate
            for cycle in 0..<50 { // Repeat for a long enough period (e.g., 50 cycles)
                for image in images {
                    let entry = PhotoWidgetEntry(date: currentDate, image: image)
                    entries.append(entry)

                    // Move the current date by 3 seconds for each image
                    currentDate = Calendar.current.date(byAdding: .second, value: 3, to: currentDate)!
                }
            }
        } else {
            // If there are no images, add a single entry showing the "No photos available" text
            let entry = PhotoWidgetEntry(date: Date(), image: nil)
            entries.append(entry)
        }

        // Create a timeline with the entries, and set the policy to reload at the end to repeat the sequence indefinitely
        let timeline = Timeline(entries: entries, policy: .atEnd)  // Reloads after the timeline ends
        completion(timeline)
    }
}

// The view for each timeline entry, showing either an image or placeholder text
struct PhotoWidgetEntryView: View {
    var entry: PhotoWidgetProvider.Entry

    var body: some View {
        ZStack {
            if let image = entry.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("No photos available")
                    .foregroundColor(.white)
            }
        }
        // Set a blue gradient as the background for the widget
        .containerBackground(.blue.gradient, for: .widget)
    }
}

// Main widget structure defining the widget and its configuration
@main
struct PhotoWidget: Widget {
    let kind: String = "PhotoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PhotoWidgetProvider()) { entry in
            PhotoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Photo Widget")
        .description("This widget displays uploaded photos in rotation every 3 seconds.")
    }
}
