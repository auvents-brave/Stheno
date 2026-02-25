#if canImport(Darwin)
    import Testing

    @testable import Stheno

    @available(macOS 10.15, *)
    @Test func `Intercepting StdOut`() async throws {
        var output: any TextOutputStream = ""
        await interceptingStdOut(to: &output) {
            print("Hello World!")
        }
        #expect((output as! String).contains("World"))
    }
#endif
