import UIKit
import SwiftUI

// Add the UIImage extension here to test if it's recognized
extension UIImage {
    func resize(to targetSize: CGSize) -> UIImage? {
        let size = self.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        let scaleFactor = min(widthRatio, heightRatio)
        let scaledSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)

        UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: scaledSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }
}

class PhotoStore {
    static let shared = PhotoStore()

    private let userDefaults = UserDefaults(suiteName: "group.com.yourcompany.PhotoWidget") // App Group
    private let userDefaultsKey = "savedPhotos"
    
    let targetSize = CGSize(width: 300, height: 300)
    
    func savePhotos(_ images: [UIImage]) {
        // Resize images before saving
        let resizedImages = images.compactMap { $0.resize(to: targetSize)?.pngData() }
        userDefaults?.set(resizedImages, forKey: userDefaultsKey)
        
        print("Saved \(resizedImages.count) images to UserDefaults")
    }
    
    func loadPhotos() -> [UIImage] {
        guard let savedData = userDefaults?.array(forKey: userDefaultsKey) as? [Data] else {
            print("No saved photos found")
            return []
        }
        
        print("Loaded \(savedData.count) images from UserDefaults")
        
        return savedData.compactMap { UIImage(data: $0) }
    }
}
