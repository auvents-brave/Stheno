import Foundation
import Logging
import FoundationNetworking

#if os(Darwin)
func downloadURLAsString(from url: URL, completion: @escaping @Sendable (Result<String, Error>) -> Void) {
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        if let error = error {
            Logger(label: "").error("Something went wrong", metadata: ["downloadURLAsString": "\(error)"])
            completion(.failure(error))
            return
        }
        guard let data = data, let string = String(data: data, encoding: .utf8) else {
            completion(.failure(NSError(domain: "Unable to decode data", code: -2, userInfo: nil)))
            return
        }
        completion(.success(string))
    }
    task.resume()
}
#else
func downloadURLAsString(from url: URL, completion: @escaping @Sendable (Result<String, Error>) -> Void) {
guard let url = URL(string: "https://example.com") else { return }

let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: url) { data, response, error in
    if let data = data {
        print("Data received: \(data)")
    } else if let error = error {
        print("Error: \(error)")
    }
}
task.resume()
  }
#endif

public var isRunningInPreviews: Bool {
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}
