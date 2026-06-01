#if canImport(Darwin)
    import Testing

    @testable import Stheno

    @Test func `Intercepting StdOut`() async throws {
        var output: any TextOutputStream = ""
        await interceptingStdOut(to: &output) {
            print("Hello World!")
        }
        #expect((output as! String).contains("World"))
    }
#endif
