//
//  ClassifyImageTests.swift
//
//  This test expects a resource named `TestImage.jpg` to be added to the test target's resources.
//  For SwiftPM, place it under `Tests/<TargetName>Tests/Resources`.
//  For Xcode, add it to the test target and set it to be copied in the build phase.
//

import Testing
@testable import RabFoundation
import Foundation

private class ResourceLocator {}

private func testImageURL(named name: String, ext: String) -> URL? {
    // Try the test bundle (Xcode) via a class token.
    if let url = Bundle(for: ResourceLocator.self).url(forResource: name, withExtension: ext) {
        return url
    } 
    // Try any loaded bundle (Xcode/SwiftPM)
    for bundle in Bundle.allBundles {
        if let url = bundle.url(forResource: name, withExtension: ext) {
            return url
        }
    }
    // Fallback: derive path relative to this test file (useful for SwiftPM Resources folder)
    let fileURL = URL(fileURLWithPath: #filePath)
    let testDir = fileURL.deletingLastPathComponent()
    let candidates = [
        testDir.appendingPathComponent("Resources/\(name).\(ext)"),
        testDir.deletingLastPathComponent().appendingPathComponent("Resources/\(name).\(ext)")
    ]
    for candidate in candidates {
        if FileManager.default.fileExists(atPath: candidate.path) {
            return candidate
        }
    }
    return nil
}

@Suite("ClassifyImage")
struct ClassifyImageTests {
    
    @Test("Classifies a local test asset image")
    func testClassifyLocalTestAsset() async throws {
        let url = try #require(testImageURL(named: "TestImage", ext: "jpg"))
        let results = try await classifyImage(url: url)
        #expect(!results.isEmpty, "Expected at least one classification for the test image.")
    }
    
    @Test("Loads CGImage from local test asset")
    func testLoadCGImageLocalTestAsset() async throws {
        let url = try #require(testImageURL(named: "TestImage", ext: "jpg"))
        let cgImage = try await loadCGImage(from: url)
        #expect(cgImage.width > 0 && cgImage.height > 0)
    }
}
