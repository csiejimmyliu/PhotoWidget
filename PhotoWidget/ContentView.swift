import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var images: [UIImage] = []
    @State private var showingImagePicker = false

    var body: some View {
        VStack {
            Text("Upload Photos for Widget")
                .font(.largeTitle)
                .padding()

            ScrollView(.horizontal) {
                HStack {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .padding()
                    }
                }
            }

            Button("Add Photo") {
                showingImagePicker = true
            }
            .padding()
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(images: $images)
            }

            Button("Save to Widget") {
                PhotoStore.shared.savePhotos(images)
                
                // Force widget to reload
                WidgetCenter.shared.reloadAllTimelines()
                
                let savedImages = PhotoStore.shared.loadPhotos()
                print("Images saved for widget count: \(savedImages.count)")
            }
            .padding()
        }
    }
}
