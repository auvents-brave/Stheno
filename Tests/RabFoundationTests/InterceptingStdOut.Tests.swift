#if !(os(Windows) || os(Linux) || os(Android) || os(WASI))
    import Testing

    @testable import RabFoundation

    @Test("Intercepting StdOut") func Log() async throws {
        var output: any TextOutputStream = ""
        await InterceptingStdOut(to: &output) {
            print("Hello World!")
        }
        #expect((output as! String).contains("World"))
    }
#endif
