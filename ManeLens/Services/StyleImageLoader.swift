import UIKit

// Resolves a `sampleImages` entry to a UIImage.
// Catalog styles use asset-catalog names (e.g. "sample_buzz_cut_1").
// Custom styles use absolute file paths in Documents/custom_styles_images/.
enum StyleImageLoader {
    static func load(_ nameOrPath: String) -> UIImage? {
        if nameOrPath.hasPrefix("/") {
            return UIImage(contentsOfFile: nameOrPath)
        }
        return UIImage(named: nameOrPath)
    }
}
