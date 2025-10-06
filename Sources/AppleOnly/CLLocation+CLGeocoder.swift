import Foundation
import Logging
import MapKit

extension CLLocation {
    func reverseLocation() async -> String {
        guard let mark = await reverseLocation() else {
            return ""
        }
        return mark.name ?? ""
    }

    nonisolated
    func reverseLocation() async -> CLPlacemark? {
        return await withCheckedContinuation { continuation in
            CLGeocoder().reverseGeocodeLocation(self) { placemarks, error in
                guard error == nil else {
                    Logger(label: "").error("Something went wrong", metadata: ["error": "\(error!.localizedDescription)"])
                    continuation.resume(returning: nil)
                    return
                }
                let placemark = placemarks?.first
                continuation.resume(returning: placemark)
            }
        }
    }
}
