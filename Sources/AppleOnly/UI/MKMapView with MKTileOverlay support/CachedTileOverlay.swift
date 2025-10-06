import MapKit

#if !os(watchOS)
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

assert(myPath(path) == tileFilePath)

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
                    if response != nil {
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200 {
                                do {
                                    try FileManager.default.createDirectory(at: parentXFolderURL,
                                                                            withIntermediateDirectories: true, attributes: nil)
                                } catch {
                                }
                                if !((try? data!.write(to: URL(fileURLWithPath: tileFilePath), options: [.atomic])) != nil) {
                                }
                                result(data, error)
                            }
                        }
                    }
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
            // app specific: ▿ file:///Users/me/Library/Developer/CoreSimulator/Devices/14EAD5A2-F46B-41B1-BB3A-645BD93F0DA0/data/Containers/Data/Application/434E4E80-AD43-42CB-A111-E683938B0C40/Library/Caches/
            let usr = try! FileManager.default.url(
                for: FileManager.SearchPathDirectory.cachesDirectory,
                in: FileManager.SearchPathDomainMask.userDomainMask,
                appropriateFor: nil,
                create: true
            )

            // app neutral: file:///Library/Caches/
            let _ = try! FileManager.default
                .url(
                    for: FileManager.SearchPathDirectory.cachesDirectory,
                    in: FileManager.SearchPathDomainMask.localDomainMask,
                    appropriateFor: nil,
                    create: true
                )

            return usr.appendingPathComponent(parentDirectory, isDirectory: true)
        }
/*
        fileprivate func URLForXFolder(_ path: MKTileOverlayPath) -> URL {
            return URLForTilecacheFolder().appendingPathComponent(cacheXFolderNameForPath(path), isDirectory: true)
        }*/
    }
#endif
