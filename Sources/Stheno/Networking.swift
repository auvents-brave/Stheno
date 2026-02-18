/// Networking utilities for simple HTTP GET requests.
/// Provides a helper to download the contents of a URL as a UTF-8 string.

#if canImport(Darwin) || canImport(FoundationNetworking) // not for os(WASI)
    import Foundation
    import Logging

    #if canImport(FoundationNetworking)
        import FoundationNetworking
    #endif

    /// Returns a `URLSession` appropriate for the current platform.
    /// - Note: Uses `URLSession.shared` on Darwin platforms and an ephemeral session elsewhere.
    fileprivate func session() -> URLSession {
        #if canImport(Darwin)
            return URLSession.shared
        #elseif canImport(FoundationNetworking)
            return URLSession(configuration: URLSessionConfiguration.ephemeral)
        #endif
    }

    /// Downloads the contents of the given URL and decodes it as a UTF-8 `String`.
    ///
    /// This method performs a GET request using `URLSession` and calls the completion handler on a background thread.
    /// If you need to update UI, dispatch back to the main queue in the caller.
    ///
    /// - Parameter from: The URL to fetch.
    /// - Parameter completion: A closure invoked with a `Result` containing the UTF-8 string on success,
    ///   or an `Error` on failure. Common failures include network errors (`URLError`), non-2xx responses (`URLError(.badServerResponse)`),
    ///   and decoding issues (`URLError(.cannotDecodeRawData)`).
    /// - Important: The response body is assumed to be UTF-8 encoded. If the server returns a different encoding,
    ///   decoding may fail.
    func downloadURLasString(from url: URL, completion: @escaping @Sendable (Result<String, Error>) -> Void) {
        let requestSession = session()
        let task = requestSession.dataTask(with: url) { data, response, error in
            #if canImport(FoundationNetworking) && !canImport(Darwin)
                defer { requestSession.finishTasksAndInvalidate() }
            #endif

            if let error = error {
                Logger(label: "Networking").error("Request failed with transport error.", metadata: ["error": "\(error)"])
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200 ... 299).contains(httpResponse.statusCode) else {
                let httpResponse = response as? HTTPURLResponse
                Logger(label: "Networking").error("Unexpected HTTP status code.", metadata: ["statusCode": "\(httpResponse?.statusCode ?? -1)"])
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            guard let data = data,
                  let string = String(data: data, encoding: .utf8) else {
                Logger(label: "Networking").error("Failed to decode response body as UTF-8 string.", metadata: ["mimeType": "\(String(describing: httpResponse.mimeType))"])
                completion(.failure(URLError(.cannotDecodeRawData)))
                return
            }
            completion(.success(string))
        }
        task.resume()
    }
#endif
