import MapKit

#if !os(watchOS)
    final class CachedTileOverlay: MKTileOverlay {
        let session: URLSession?
        let cacheFolder: String
        let maximumCacheAge: TimeInterval = 30.0 * 24.0 * 60.0 * 60.0

        init(directory: String = "tilescache", urlTemplate: String?) {
            cacheFolder = directory
            let sessionConfiguration = URLSessionConfiguration.default
            sessionConfiguration.urlCache = nil
            sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
            session = URLSession(configuration: sessionConfiguration)
            super.init(urlTemplate: urlTemplate)
            minimumZ = 9 // maximumZ = 18 // def 21
            canReplaceMapContent = false
        }

        override func loadTile(at path: MKTileOverlayPath, result: @Sendable @escaping (Data?, Error?) -> Void) {
            let parentXFolderURL = CacheUrl().appendingPathComponent(OverlayPathFolder(path))
            let tilePath = parentXFolderURL.appendingPathComponent(Filename(path)).path

            var useCachedVersion = false
            if FileManager.default.fileExists(atPath: tilePath) {
                if let fileAttributes = try? FileManager.default.attributesOfItem(atPath: tilePath),
                   let fileModificationDate = fileAttributes[FileAttributeKey.modificationDate] as? Date {
                    if fileModificationDate.timeIntervalSinceNow > -1.0 * maximumCacheAge {
                        useCachedVersion = true
                    }
                }
            }
            if useCachedVersion {
                let cachedData = try? Data(contentsOf: URL(fileURLWithPath: tilePath))
                result(cachedData, nil)
            } else {
                let request = URLRequest(url: url(forTilePath: path))
                let task = session!.dataTask(with: request, completionHandler: { data, response, error in
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
                        try data.write(to: URL(fileURLWithPath: tilePath), options: [.atomic])
                    } catch {
                        // Ignore write errors in this context
                    }
                    result(data, error)
                })
                task.resume()
            }
        }

        fileprivate func Filename(_ path: MKTileOverlayPath) -> String {
            return "\(path.y).png"
        }

        fileprivate func OverlayPathFolder(_ path: MKTileOverlayPath) -> String {
            return "\(path.contentScaleFactor)/\(path.z)/\(path.x)"
        }

        fileprivate func CacheUrl() -> URL {
            let url: URL
            do {
                url = try FileManager.default.url(
                    for: .cachesDirectory,
                    in: .localDomainMask,
                    appropriateFor: nil,
                    create: true
                )
            } catch {
                // Gacefully fall back to a temp directory to avoid crashing.
                url = FileManager.default.temporaryDirectory
            }
            return url.appendingPathComponent(cacheFolder, isDirectory: true)
        }
    }
#endif
