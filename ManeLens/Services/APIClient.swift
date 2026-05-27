import UIKit

enum APIError: Error {
    case noPhoto
    case faceValidation(reason: String)
    case network(Error)
    case styleBlocked
    case rateLimited
    case paymentRequired
    case generationFailed(String)
    case noImage

    var userFacingMessage: String {
        switch self {
        case .noPhoto:                   return "Please select a photo first."
        case .faceValidation(let r):     return r
        case .network:                   return "Network error. Check your connection and try again."
        case .styleBlocked:              return "This style was flagged. Please try a different style."
        case .rateLimited:               return "Daily limit reached. Try again tomorrow."
        case .paymentRequired:           return "No credits remaining. Please purchase more credits."
        case .generationFailed(let msg): return "Generation failed: \(msg)"
        case .noImage:                   return "No image returned. Please try again."
        }
    }
}

struct APIClient {
    static let workerURL    = "https://aurax-api.auraxai.workers.dev/hair/generate"
    static let analyseURL   = "https://aurax-api.auraxai.workers.dev/hair/analyse"

    static func generate(
        photo: UIImage,
        styleKey: String?,
        customPrompt: String?
    ) async throws -> UIImage {
        let validation = await FaceValidator.validate(photo)
        if case .invalid(let reason) = validation {
            throw APIError.faceValidation(reason: reason)
        }

        guard let imageBase64 = ImageProcessor.prepare(photo) else {
            throw APIError.noPhoto
        }

        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString

        var body: [String: String] = [
            "deviceId": deviceId,
            "imageBase64": imageBase64,
        ]
        if let styleKey, !styleKey.isEmpty { body["styleId"] = styleKey }
        if let customPrompt, !customPrompt.isEmpty { body["customPrompt"] = customPrompt }

        guard let url = URL(string: workerURL) else {
            throw APIError.generationFailed("Invalid Worker URL")
        }
        var urlRequest = URLRequest(url: url, timeoutInterval: 30)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let data: Data
        do {
            (data, _) = try await URLSession.shared.data(for: urlRequest)
        } catch {
            throw APIError.network(error)
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIError.generationFailed("Unreadable response")
        }

        if let errorCode = json["error"] as? String {
            switch errorCode {
            case "style_blocked":      throw APIError.styleBlocked
            case "rate_limited":       throw APIError.rateLimited
            case "payment_required":   throw APIError.paymentRequired
            default:
                let msg = json["message"] as? String ?? errorCode
                throw APIError.generationFailed(msg)
            }
        }

        guard
            let base64 = json["image"] as? String,
            let imageData = Data(base64Encoded: base64),
            let image = UIImage(data: imageData)
        else {
            throw APIError.noImage
        }

        return image
    }

    static func analyse(photo: UIImage) async throws -> FaceAnalysisResult {
        let validation = await FaceValidator.validate(photo)
        if case .invalid(let reason) = validation {
            throw APIError.faceValidation(reason: reason)
        }

        guard let imageBase64 = ImageProcessor.prepare(photo) else {
            throw APIError.noPhoto
        }

        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        let body: [String: String] = ["deviceId": deviceId, "imageBase64": imageBase64]

        guard let url = URL(string: analyseURL) else {
            throw APIError.generationFailed("Invalid analyse URL")
        }
        var urlRequest = URLRequest(url: url, timeoutInterval: 30)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let data: Data
        do {
            (data, _) = try await URLSession.shared.data(for: urlRequest)
        } catch {
            throw APIError.network(error)
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIError.generationFailed("Unreadable response")
        }

        if let errorCode = json["error"] as? String {
            let msg = json["message"] as? String ?? errorCode
            throw APIError.generationFailed(msg)
        }

        guard let result = try? JSONDecoder().decode(FaceAnalysisResult.self, from: data) else {
            throw APIError.generationFailed("Could not parse analysis result")
        }
        return result
    }
}
