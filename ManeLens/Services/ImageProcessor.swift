import UIKit

struct ImageProcessor {
    static func prepare(_ image: UIImage) -> String? {
        let maxDimension: CGFloat = 1024
        let size = image.size
        let longEdge = max(size.width, size.height)

        let newSize: CGSize
        if longEdge > maxDimension {
            let scale = maxDimension / longEdge
            newSize = CGSize(width: size.width * scale, height: size.height * scale)
        } else {
            newSize = size
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let resized = UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }

        guard let jpeg = resized.jpegData(compressionQuality: 0.8) else { return nil }
        return jpeg.base64EncodedString()
    }
}
