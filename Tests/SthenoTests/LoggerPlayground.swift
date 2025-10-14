import Foundation
import Logging
import SwiftLogTesting
import Testing

@Suite struct LoggerPlayground {
    @Test("Playing with swift-log-testing") func Log1() async throws {
        TestLogMessages.bootstrap()
        let container = TestLogMessages.container(forLabel: "Log1")
        let logger = Logger(label: "Log1")

        logger.info("message")
        #expect(container.messages.count == 1)
        #expect(container.messages[0].toString() == "info message|LoggerPlayground.swift|Log1()")

        container.reset()
        #expect(container.messages.isEmpty)
    }

    @Test("Playing with levels") func Log2() async throws {
        TestLogMessages.bootstrap()
        let container = TestLogMessages.container(forLabel: "Log2")
        let logger = Logger(label: "Log2")

        // logLevel is .info by default
        logger.trace("trace")
        logger.debug("debug")
        logger.info("info")
        logger.notice("notice")
        logger.warning("warning")
        logger.error("error")
        logger.critical("critical")

        // The first two messages have been stripped.
        #expect(container.messages.count == 5)
    }

    @Test("Playing with metadatas") func Log3() async throws {
        var logger = Logger(label: "Log3")
        logger.logLevel = .trace

        logger.trace("Test started")
        logger.warning("This is a warning")
        logger.error("Something went wrong", metadata: ["error": "-99"])

        // Add metadata for context
        var requestLogger = logger
        requestLogger[metadataKey: "request-id"] = "\(UUID())"
        requestLogger.info("With default metadata")
        requestLogger.info("Overriding default metadata", metadata: ["request-id": "\(UUID())"])
        requestLogger.info("With default metadata", metadata: ["user-id": "123"])

        logger.trace("Test ended")
    }
}
