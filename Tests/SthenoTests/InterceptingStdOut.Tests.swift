#if canImport(Darwin)
    import Testing

    @testable import Stheno

    @available(macOS 10.15, *)
    @Test("Intercepting StdOut") func Log() async throws {
        var output: any TextOutputStream = ""
        await InterceptingStdOut(to: &output) {
            print("Hello World!")
        }
        #expect((output as! String).contains("World"))
    }
#endif
