import Logging

#if canImport(Darwin)
   import Foundation
#else
   import FoundationNetworking
#endif


fileprivate func session() -> URLSession {
    #if canImport(Darwin)
        return URLSession.shared
    #else
        return URLSession(configuration: URLSessionConfiguration.default)
    #endif
}

#if false

func downloadURLasString(from url: URL, completion: @escaping @Sendable (Result<String, Error>) -> Void) {
    let task = session().dataTask(with: url) { data, response, error in
        if let error = error {
            Logger(label: "downloadURLAsString").error("Something went wrong", metadata: ["error": "\(error)"])
            completion(.failure(error))
            return
        }
        guard let httpResponse = response as? HTTPURLResponse,
              (200 ... 299).contains(httpResponse.statusCode) else {
            Logger(label: "downloadURLAsString").error("Something went wrong", metadata: ["httpResponse": "\(error!)"])
            completion(.failure(URLError(.badServerResponse)))
            return
        }
        guard let data = data,
              let string = String(data: data, encoding: .utf8) else {
            Logger(label: "downloadURLAsString")
                .error(
                    "Something went wrong",
                    metadata: ["mimeType": "\(String(describing: httpResponse.mimeType))"]
                )
            completion(.failure(URLError(.cannotDecodeRawData)))
            return
        }
        completion(.success(string))
    }
    task.resume()
}

#endif
