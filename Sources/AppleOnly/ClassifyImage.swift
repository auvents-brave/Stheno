import CoreGraphics
import Foundation
import ImageIO
import Vision

public func classifyImage(url: URL) async throws -> [String: Double] {
    if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        // Use the modern Vision concurrency API when available.
        let request = ClassifyImageRequest()
        let results = try await request.perform(on: url)
            // Use `hasMinimumPrecision` for a high-recall filter.
            .filter { $0.hasMinimumPrecision(0.1, forRecall: 0.8) }
        // Alternatively, for high-precision filter:
        // .filter { $0.hasMinimumRecall(0.01, forPrecision: 0.9) }

        var observations: [String: Double] = [:]
        for classification in results {
            observations[classification.identifier] = Double(classification.confidence)
        }
        return observations
    } else {
        // Fallback using VNClassifyImageRequest and a CGImage loaded from the URL.
        let cgImage = try await loadCGImage(from: url)
        let request = VNClassifyImageRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])

        guard let results = request.results else {
            return [:]
        }

        var observations: [String: Double] = [:]
        for classification in results {
            observations[classification.identifier] = Double(classification.confidence)
        }
        return observations
    }
}

/// Errors that can occur while loading an image from a URL.
public enum ImageLoadingError: Error {
    case cannotCreateImageSource
    case cannotCreateCGImage
}

/// Loads a CGImage from a URL. Supports both local file URLs and remote (e.g., https) URLs.
/// - Parameter url: The URL of the image. Can be a file URL or a remote URL.
/// - Returns: A `CGImage` created from the contents at the URL.
/// - Throws: `ImageLoadingError` if the image cannot be decoded, or network errors for remote URLs.
public func loadCGImage(from url: URL) async throws -> CGImage {
    if url.isFileURL {
        // Load from disk using ImageIO for efficient decoding.
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw ImageLoadingError.cannotCreateImageSource
        }
        guard let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw ImageLoadingError.cannotCreateCGImage
        }
        return image
    } else {
        // Load from network using URLSession, then decode with ImageIO.
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw ImageLoadingError.cannotCreateImageSource
        }
        guard let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw ImageLoadingError.cannotCreateCGImage
        }
        return image
    }
}

/*
 func classifyImage(url: URL) async throws -> ImageFile {
     var image = ImageFile(url: url)

     // Vision request to classify an image.
     let request = ClassifyImageRequest()

     // Perform the request on the image, and return an array of `ClassificationObservation` objects.
     let results = try await request.perform(on: url)
         // Use `hasMinimumPrecision` for a high-recall filter.
         .filter { $0.hasMinimumPrecision(0.1, forRecall: 0.8) }
         // Use `hasMinimumRecall` for a high-precision filter.
         // .filter { $0.hasMinimumRecall(0.01, forPrecision: 0.9) }

     // Add each classification identifier and its respective confidence level into the observations dictionary.
     for classification in results {
         image.observations[classification.identifier] = classification.confidence
     }

     return image
 }
 */
