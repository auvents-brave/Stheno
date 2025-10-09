import MapKit

#if !os(watchOS)
    fileprivate var isRunningInPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    final class CachedTileOverlay: MKTileOverlay {
        let parentDirectory: String
        let maximumCacheAge: TimeInterval = 30.0 * 24.0 * 60.0 * 60.0
        let urlSession: URLSession?

        override convenience init(urlTemplate URLTemplate: String?) {
            self.init(directory: "tilescache", urlTemplate: URLTemplate)
        }

        init(directory: String, urlTemplate URLTemplate: String?) {
            parentDirectory = directory

            // The Open Sea Map tile server returns 404 for blank tiles, and also when it's
            // too heavily loaded to return a tile. We'll do our own cacheing and not use
            // NSURLSession's.
            let sessionConfiguration = URLSessionConfiguration.default
            sessionConfiguration.urlCache = nil
            sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
            urlSession = URLSession(configuration: sessionConfiguration)
            super.init(urlTemplate: URLTemplate)
            minimumZ = 9
            // maximumZ = 18 // def 21
            canReplaceMapContent = false
        }

        // override func loadTile(at path: MKTileOverlayPath) async throws -> Data
        override func loadTile(at path: MKTileOverlayPath, result: @Sendable @escaping (Data?, Error?) -> Void) {
            let parentXFolderURL = URLForTilecacheFolder().appendingPathComponent(cacheXFolderNameForPath(path))
            let tileFilePathURL = parentXFolderURL.appendingPathComponent(fileNameForTile(path))
            let tileFilePath = tileFilePathURL.path

            var useCachedVersion = false
            if FileManager.default.fileExists(atPath: tileFilePath) {
                if let fileAttributes = try? FileManager.default.attributesOfItem(atPath: tileFilePath),
                   let fileModificationDate = fileAttributes[FileAttributeKey.modificationDate] as? Date {
                    if fileModificationDate.timeIntervalSinceNow > -1.0 * maximumCacheAge {
                        useCachedVersion = true
                    }
                }
            }
            if useCachedVersion {
                let cachedData = try? Data(contentsOf: URL(fileURLWithPath: tileFilePath))
                result(cachedData, nil)
            } else {
                let request = URLRequest(url: url(forTilePath: path))
                let task = urlSession!.dataTask(with: request, completionHandler: { data, response, error in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        result(nil, error)
                        return
                    }
                    guard httpResponse.statusCode == 200 else {
                        result(nil, error)
                        return
                    }
                    guard let data = data else {
                        result(nil, error)
                        return
                    }
                    do {
                        try FileManager.default.createDirectory(
                            at: parentXFolderURL,
                            withIntermediateDirectories: true,
                            attributes: nil)
                        try data.write(to: URL(fileURLWithPath: tileFilePath), options: [.atomic])
                    } catch {
                        // Ignore write errors in this context
                    }
                    result(data, error)
                })
                task.resume()
            }
        }

        // path to X folder, starting from URLForTilecacheFolder
        fileprivate func myPath(_ path: MKTileOverlayPath) -> String {
            return "\(path.contentScaleFactor)/\(path.z)/\(path.x)/\(path.y).png"
        }

        // filename for y.png, used within the cacheXFolderNameForPath
        fileprivate func fileNameForTile(_ path: MKTileOverlayPath) -> String {
            return "\(path.y).png"
        }

        // path to X folder, starting from URLForTilecacheFolder
        fileprivate func cacheXFolderNameForPath(_ path: MKTileOverlayPath) -> String {
            return "\(path.contentScaleFactor)/\(path.z)/\(path.x)"
        }

        // folder within app's Library/Caches to use for this particular overlay
        fileprivate func URLForTilecacheFolder() -> URL {
            do {
                let usr = try FileManager.default.url(
                    for: .cachesDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true
                )
                return usr.appendingPathComponent(parentDirectory, isDirectory: true)
            } catch {
                print("catch URLForTilecacheFolder")

                // In previews, gracefully fall back to a temp directory to avoid crashing.
                let tmp = FileManager.default.temporaryDirectory
                return tmp.appendingPathComponent(parentDirectory, isDirectory: true)
            }
        }
        /*
         // app neutral: file:///Library/Caches/
         let _ = try! FileManager.default
             .url(
                 for: FileManager.SearchPathDirectory.cachesDirectory,
                 in: FileManager.SearchPathDomainMask.localDomainMask,
                 appropriateFor: nil,
                 create: true
             )
         */

        /*
         fileprivate func URLForXFolder(_ path: MKTileOverlayPath) -> URL {
             return URLForTilecacheFolder().appendingPathComponent(cacheXFolderNameForPath(path), isDirectory: true)
         }*/
    }
#endif
