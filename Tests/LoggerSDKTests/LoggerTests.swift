//
//  LoggerTests.swift
//  LoggerSDK
//
//  Created by Vincent Joy on 04/07/25.
//

import XCTest
@testable import LoggerSDK

final class LoggerTests: XCTestCase {
    
    var logger: Logger!
    
    override func setUp() {
        super.setUp()
        logger = Logger()
    }
    
    override func tearDown() {
        logger = nil
        super.tearDown()
    }
    
    // MARK: - Basic Functionality Tests
    
    func testLoggerInitialization() {
        let logger = Logger(minimumLevel: .warning)
        XCTAssertEqual(logger.logCount(), 0)
    }
    
    func testBasicLogging() {
        logger.log("Test message", level: .info)
        
        let logs = logger.getRecentLogs()
        XCTAssertEqual(logs.count, 1)
        XCTAssertEqual(logs[0].message, "Test message")
        XCTAssertEqual(logs[0].level, .info)
    }
    
    // MARK: - Minimum Level Filtering Tests
    
    func testMinimumLevelFiltering() {
        let logger = Logger(minimumLevel: .warning)
        
        logger.log("Info message", level: .info)      // Should be ignored
        logger.log("Warning message", level: .warning) // Should be logged
        logger.log("Error message", level: .error)    // Should be logged
        
        let logs = logger.getRecentLogs()
        XCTAssertEqual(logs.count, 2)
        XCTAssertEqual(logs[0].message, "Warning message")
        XCTAssertEqual(logs[1].message, "Error message")
    }
    
    func testInfoLevelLogsAll() {
        let logger = Logger(minimumLevel: .info)
        
        logger.log("Info message", level: .info)
        logger.log("Warning message", level: .warning)
        logger.log("Error message", level: .error)
        
        let logs = logger.getRecentLogs()
        XCTAssertEqual(logs.count, 3)
    }
    
    func testErrorLevelLogsOnlyErrors() {
        let logger = Logger(minimumLevel: .error)
        
        logger.log("Info message", level: .info)
        logger.log("Warning message", level: .warning)
        logger.log("Error message", level: .error)
        
        let logs = logger.getRecentLogs()
        XCTAssertEqual(logs.count, 1)
        XCTAssertEqual(logs[0].level, .error)
    }
    
    // MARK: - Thread Safety Tests
    
    func testThreadSafety() {
        let expectation = XCTestExpectation(description: "Concurrent logging")
        let iterationCount = 100
        let threadCount = 10
        let testLogger = self.logger! // Capture logger locally
        
        let group = DispatchGroup()
        
        for threadIndex in 0..<threadCount {
            group.enter()
            DispatchQueue.global(qos: .default).async {
                for i in 0..<iterationCount {
                    testLogger.log("Thread \(threadIndex) - Message \(i)", level: .info)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            // Wait a bit more for all async operations to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let logs = testLogger.getRecentLogs()
                XCTAssertEqual(logs.count, threadCount * iterationCount)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Timestamp Tests
    
    func testTimestampOrdering() {
        let startTime = Date()
        
        logger.log("First message", level: .info)
        Thread.sleep(forTimeInterval: 0.01) // Small delay
        logger.log("Second message", level: .info)
        
        let logs = logger.getRecentLogs()
        XCTAssertEqual(logs.count, 2)
        XCTAssertTrue(logs[0].timestamp <= logs[1].timestamp)
        XCTAssertTrue(logs[0].timestamp >= startTime)
        XCTAssertTrue(logs[1].timestamp >= startTime)
    }
    
    // MARK: - Advanced Retrieval Tests
    
    func testGetRecentLogsWithCount() {
        logger.log("Message 1", level: .info)
        logger.log("Message 2", level: .warning)
        logger.log("Message 3", level: .error)
        logger.log("Message 4", level: .info)
        
        let recentTwoLogs = logger.getRecentLogs(count: 2)
        XCTAssertEqual(recentTwoLogs.count, 2)
        XCTAssertEqual(recentTwoLogs[0].message, "Message 3")
        XCTAssertEqual(recentTwoLogs[1].message, "Message 4")
    }
    
    func testGetRecentLogsWithLevelFilter() {
        logger.log("Info message", level: .info)
        logger.log("Warning message", level: .warning)
        logger.log("Error message", level: .error)
        
        let warningAndAboveLogs = logger.getRecentLogs(level: .warning)
        XCTAssertEqual(warningAndAboveLogs.count, 2)
        XCTAssertEqual(warningAndAboveLogs[0].level, .warning)
        XCTAssertEqual(warningAndAboveLogs[1].level, .error)
    }
    
    func testGetRecentLogsWithCountAndLevel() {
        logger.log("Info 1", level: .info)
        logger.log("Warning 1", level: .warning)
        logger.log("Error 1", level: .error)
        logger.log("Warning 2", level: .warning)
        logger.log("Error 2", level: .error)
        
        let filteredLogs = logger.getRecentLogs(count: 2, level: .warning)
        XCTAssertEqual(filteredLogs.count, 2)
        XCTAssertEqual(filteredLogs[0].message, "Warning 2")
        XCTAssertEqual(filteredLogs[1].message, "Error 2")
    }
    
    // MARK: - Utility Methods Tests
    
    func testConvenienceMethods() {
        logger.info("Info message")
        logger.warning("Warning message")
        logger.error("Error message")
        
        let logs = logger.getRecentLogs()
        XCTAssertEqual(logs.count, 3)
        XCTAssertEqual(logs[0].level, .info)
        XCTAssertEqual(logs[1].level, .warning)
        XCTAssertEqual(logs[2].level, .error)
    }
    
    func testClearLogs() {
        logger.log("Message 1", level: .info)
        logger.log("Message 2", level: .warning)
        
        XCTAssertEqual(logger.logCount(), 2)
        
        logger.clearLogs()
        
        XCTAssertEqual(logger.logCount(), 0)
        XCTAssertEqual(logger.getRecentLogs().count, 0)
    }
    
    func testLogCount() {
        XCTAssertEqual(logger.logCount(), 0)
        
        logger.log("Message 1", level: .info)
        XCTAssertEqual(logger.logCount(), 1)
        
        logger.log("Message 2", level: .warning)
        XCTAssertEqual(logger.logCount(), 2)
    }
    
    // MARK: - LogEntry Tests
    
    func testLogEntryFormatting() {
        logger.log("Test message", level: .warning)
        
        let logs = logger.getRecentLogs()
        let logEntry = logs[0]
        
        let formattedString = logEntry.formattedString
        XCTAssertTrue(formattedString.contains("WARNING"))
        XCTAssertTrue(formattedString.contains("Test message"))
        XCTAssertTrue(formattedString.contains("-"))
        XCTAssertTrue(formattedString.contains(":"))
    }
    
    // MARK: - LogLevel Tests
    
    func testLogLevelComparison() {
        XCTAssertTrue(Logger.LogLevel.info < Logger.LogLevel.warning)
        XCTAssertTrue(Logger.LogLevel.warning < Logger.LogLevel.error)
        XCTAssertTrue(Logger.LogLevel.info < Logger.LogLevel.error)
        
        XCTAssertTrue(Logger.LogLevel.error > Logger.LogLevel.warning)
        XCTAssertTrue(Logger.LogLevel.warning > Logger.LogLevel.info)
        
        XCTAssertTrue(Logger.LogLevel.info == Logger.LogLevel.info)
    }
    
    func testLogLevelDescription() {
        XCTAssertEqual(Logger.LogLevel.info.description, "INFO")
        XCTAssertEqual(Logger.LogLevel.warning.description, "WARNING")
        XCTAssertEqual(Logger.LogLevel.error.description, "ERROR")
    }
    
    // MARK: - Performance Tests
    
    func testLoggingPerformance() {
        measure {
            for i in 0..<1000 {
                logger.log("Performance test message \(i)", level: .info)
            }
        }
    }
    
    func testConcurrentLogger() {
        let logger = Logger()
        let expectation = XCTestExpectation(description: "Concurrent logging completed")
        
        let group = DispatchGroup()
        
        for index in 0..<100 {
            group.enter()
            DispatchQueue.global(qos: .default).async {
                logger.log("Concurrent message \(index)", level: .info)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            // Wait a bit for all async operations to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let logs = logger.getRecentLogs()
                XCTAssertEqual(logs.count, 100)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
