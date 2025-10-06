#if !(os(Windows) || os(Linux) || os(Android) || os(WASI))
    import Foundation
    import Testing

    @testable import AppleOnly

    @Suite("UserDefaults and iCloud Sync") struct UserDefaultsCloudSyncTests {
        @Test("Pushing Data to iCloud", arguments: [nil, "shared"])
        func SyncToCloud(_ value: String?) {
            let mockDefaults = UserDefaults(suiteName: "TestDefaults")!
            mockDefaults.set("me", forKey: "shared_username")
            mockDefaults.set("P@ssword", forKey: "password")
            mockDefaults.set(true, forKey: "shared_enabled")

            let mockStore = MockUbiquitousStore()

            let syncer = UserDefaultsCloudSync(
                prefix: value,
                defaults: mockDefaults,
                ubiquitousStore: mockStore
            )
            syncer.SyncToCloud()

            print("⚠️ The 'com.apple.developer.ubiquity-kvstore-identifier' entitlement can't be setup in a library, only in an app.")
            // #expect(mockStore.dictionaryRepresentation.count == (value == nil ? 3 : 2))
        }

        @Test("Handle iCloud Change Event")
        func iCloudDidChange() async throws {
            let mockStore = MockUbiquitousStore()
            mockStore.set("P@ssword", forKey: "password")

            let notification = Notification(
                name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                object: mockStore,
                userInfo: nil
            )

            let mockDefaults = UserDefaults(suiteName: "TestDefaults")!

            let syncer = UserDefaultsCloudSync(
                prefix: nil,
                defaults: mockDefaults,
                ubiquitousStore: mockStore
            )

            syncer.iCloudDidChange(notification)

            #expect(mockDefaults.string(forKey: "password") == "P@ssword")
        }
    }

    private class MockUbiquitousStore: NSUbiquitousKeyValueStore {
        var values = [String: Any]()

        override func set(_ value: Any?, forKey key: String) {
            values[key] = value
        }

        override func object(forKey key: String) -> Any? {
            return values[key]
        }

        override func synchronize() -> Bool {
            return true
        }
    }
#endif

