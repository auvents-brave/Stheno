#if !(os(Windows) || os(WASI))
    import Testing

    @testable import Stheno

    @Test("Intercepting StdOut") func Log() async throws {
        var output: any TextOutputStream = ""
        await InterceptingStdOut(to: &output) {
            print("Hello World!")
        }
        #expect((output as! String).contains("World"))
    }
#endif
