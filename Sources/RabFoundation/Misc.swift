import Foundation
import Logging

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
