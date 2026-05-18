import Vision
import UIKit

enum FaceValidationResult {
    case valid
    case invalid(reason: String)
}

struct FaceValidator {
    static func validate(_ image: UIImage) async -> FaceValidationResult {
        guard let cgImage = image.cgImage else {
            return .invalid(reason: "Could not read the photo.")
        }

        return await withCheckedContinuation { continuation in
            let request = VNDetectFaceLandmarksRequest { req, err in
                if err != nil {
                    continuation.resume(returning: .invalid(reason: "Could not analyze the photo."))
                    return
                }

                let faces = req.results as? [VNFaceObservation] ?? []

                switch faces.count {
                case 0:
                    continuation.resume(returning: .invalid(reason: "No face detected. Please use a clear front-facing selfie."))
                case 2...:
                    continuation.resume(returning: .invalid(reason: "Multiple faces detected. Please use a solo selfie."))
                default:
                    let face = faces[0]
                    let area = face.boundingBox.width * face.boundingBox.height
                    if area < 0.08 {
                        continuation.resume(returning: .invalid(reason: "Move closer — your face is too small in the frame."))
                        return
                    }
                    if let lm = face.landmarks, lm.leftEye == nil || lm.rightEye == nil {
                        continuation.resume(returning: .invalid(reason: "Eyes not visible. Remove sunglasses and ensure good lighting."))
                        return
                    }
                    // ~25° in radians
                    let yaw = face.yaw?.doubleValue ?? 0
                    let pitch = face.pitch?.doubleValue ?? 0
                    if abs(yaw) > 0.44 || abs(pitch) > 0.44 {
                        continuation.resume(returning: .invalid(reason: "Please look directly at the camera."))
                        return
                    }
                    continuation.resume(returning: .valid)
                }
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }
}
