#if canImport(Darwin)
    import Foundation

    /// Additionally writes any data written to standard output into the given
    /// output stream.
    ///
    /// - Parameters:j
    ///   - output: An output stream to receive the standard output text
    ///   - encoding: The encoding to use when converting standard output into text.
    ///   - body: A closure that is executed immediately.
    /// - Returns: The return value, if any, of the `body` closure.
    ///
    /// Example usage:
    /// ```swift
    /// var output: any TextOutputStream = ""
    /// await InterceptingStdOut(to: &output) {
    ///       FunctionUsingPrintToTraceThings()
    /// }
    /// #expect((output as! String).contains("wWhatever you expect to read in stdoutput"))
    /// ```
    public func InterceptingStdOut<T>(to output: inout TextOutputStream,
                                      encoding: String.Encoding = .utf8,
                                      body: () -> T) async -> T {
        var result: T?

        let consumer = Pipe() // reads from stdout
        let producer = Pipe() // writes to stdout

        let stream = AsyncStream<Data> { continuation in
            let clonedStandardOutput = dup(STDOUT_FILENO)
            defer {
                dup2(clonedStandardOutput, STDOUT_FILENO)
                close(clonedStandardOutput)
            }
            dup2(STDOUT_FILENO, producer.fileHandleForWriting.fileDescriptor)
            dup2(consumer.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)

            consumer.fileHandleForReading.readabilityHandler = { fileHandle in
                let data = fileHandle.availableData
                if data.isEmpty {
                    continuation.finish()
                } else {
                    continuation.yield(data)
                    producer.fileHandleForWriting.write(data)
                }
            }

            result = body()
            try! consumer.fileHandleForWriting.close()
        }

        for await chunk in stream {
            output.write(String(data: chunk, encoding: encoding)!)
        }

        return result!
    }
#endif
