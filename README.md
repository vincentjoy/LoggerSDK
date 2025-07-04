# LoggerSDK

A lightweight, thread-safe logging utility for iOS applications that provides flexible logging with different severity levels, in-memory storage, and comprehensive filtering capabilities.

## Features

- ✅ **Multiple Log Levels**: Support for `.info`, `.warning`, and `.error` levels
- ✅ **Minimum Level Filtering**: Configure minimum log level to ignore less important messages
- ✅ **Thread-Safe**: Concurrent read/write operations using GCD
- ✅ **In-Memory Storage**: Fast, lightweight log storage in memory
- ✅ **Timestamping**: Automatic timestamp generation for each log entry
- ✅ **Flexible Retrieval**: Get logs with optional count and level filtering
- ✅ **Formatted Output**: Built-in formatted string representation
- ✅ **Convenience Methods**: Easy-to-use info(), warning(), error() methods
- ✅ **Swift Package Manager**: Easy integration as a Swift package
- ✅ **Comprehensive Tests**: Full unit test coverage

## Installation

### Swift Package Manager

Add this to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourorg/LoggerSDK.git", from: "1.0.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select version and add to your target

### Manual Installation

1. Download the `Logger.swift` file
2. Add it to your Xcode project
3. Import and use

## Quick Start

```swift
import LoggerSDK

// Create a logger instance
let logger = Logger(minimumLevel: .warning)

// Log messages
logger.log("Something happened", level: .info)     // Ignored (below minimum level)
logger.log("Something went wrong", level: .error)  // Logged

// Retrieve logs
let logs = logger.getRecentLogs()
print("Total logs: \(logs.count)")
```

## Usage

### Basic Logging

```swift
let logger = Logger()

// Using the main logging method
logger.log("User logged in", level: .info)
logger.log("API rate limit approaching", level: .warning)
logger.log("Database connection failed", level: .error)

// Using convenience methods
logger.info("Application started")
logger.warning("Memory usage high")
logger.error("Critical system failure")
```

### Minimum Level Filtering

```swift
// Only log warnings and errors
let logger = Logger(minimumLevel: .warning)

logger.info("Debug information")      // Ignored
logger.warning("Potential issue")     // Logged
logger.error("Critical error")        // Logged
```

### Retrieving Logs

```swift
// Get all logs
let allLogs = logger.getRecentLogs()

// Get last 10 logs
let recentLogs = logger.getRecentLogs(count: 10)

// Get only error logs
let errorLogs = logger.getRecentLogs(level: .error)

// Get last 5 warning+ logs
let criticalLogs = logger.getRecentLogs(count: 5, level: .warning)
```

### Working with Log Entries

```swift
let logs = logger.getRecentLogs()

for log in logs {
    print("Timestamp: \(log.timestamp)")
    print("Level: \(log.level)")
    print("Message: \(log.message)")
    print("Formatted: \(log.formattedString)")
    print("---")
}
```

### Thread Safety

The logger is fully thread-safe and can be used from multiple threads simultaneously:

```swift
let logger = Logger()

DispatchQueue.concurrentPerform(iterations: 100) { index in
    logger.log("Concurrent message \(index)", level: .info)
}

// Safe to retrieve logs from any thread
DispatchQueue.main.async {
    let logs = logger.getRecentLogs()
    print("Logged \(logs.count) messages")
}
```

### Utility Methods

```swift
// Check log count
print("Current logs: \(logger.logCount())")

// Clear all logs
logger.clearLogs()
```

## API Reference

### Logger Class

#### Initializers

```swift
/// Creates a new Logger instance with the specified minimum logging level
init(minimumLevel: LogLevel = .info)
```

#### Logging Methods

```swift
/// Logs a message with the specified level
func log(_ message: String, level: LogLevel)

/// Convenience methods for each level
func info(_ message: String)
func warning(_ message: String) 
func error(_ message: String)
```

#### Retrieval Methods

```swift
/// Retrieves all recent log entries
func getRecentLogs() -> [LogEntry]

/// Retrieves recent log entries with optional filtering
func getRecentLogs(count: Int? = nil, level: LogLevel? = nil) -> [LogEntry]
```

#### Utility Methods

```swift
/// Clears all stored log entries
func clearLogs()

/// Returns the current number of stored log entries
func logCount() -> Int
```

### LogLevel Enum

```swift
public enum LogLevel: Int, CaseIterable, Comparable {
    case info = 0
    case warning = 1
    case error = 2
}
```

### LogEntry Struct

```swift
public struct LogEntry {
    public let timestamp: Date
    public let level: LogLevel
    public let message: String
    public var formattedString: String { get }
}
```

## Advanced Usage

### Custom Log Analysis

```swift
extension Logger {
    func getLogStatistics() -> (info: Int, warning: Int, error: Int) {
        let logs = getRecentLogs()
        let infoCount = logs.filter { $0.level == .info }.count
        let warningCount = logs.filter { $0.level == .warning }.count
        let errorCount = logs.filter { $0.level == .error }.count
        
        return (info: infoCount, warning: warningCount, error: errorCount)
    }
    
    func exportLogs() -> String {
        let logs = getRecentLogs()
        return logs.map { $0.formattedString }.joined(separator: "\n")
    }
}
```

### Integration with Analytics

```swift
class AnalyticsLogger {
    private let logger = Logger(minimumLevel: .warning)
    
    func logUserAction(_ action: String) {
        logger.info("User action: \(action)")
    }
    
    func logError(_ error: Error) {
        logger.error("Error occurred: \(error.localizedDescription)")
        
        // Send critical errors to analytics service
        if logger.getRecentLogs(level: .error).count > 10 {
            sendErrorsToAnalytics()
        }
    }
    
    private func sendErrorsToAnalytics() {
        let errorLogs = logger.getRecentLogs(level: .error)
        // Send to analytics service
    }
}
```

## Performance Considerations

- **Memory Usage**: Logs are stored in memory and will accumulate over time. Consider calling `clearLogs()` periodically in long-running applications.
- **Thread Safety**: The logger uses a concurrent queue with barriers for thread safety, providing good performance for read-heavy workloads.
- **Filtering**: Minimum level filtering is performed at log time, so filtered messages have minimal performance impact.

## Testing

The SDK includes comprehensive unit tests covering:

- Basic logging functionality
- Minimum level filtering
- Thread safety
- Timestamp ordering
- Advanced retrieval options
- Performance characteristics

Run tests using Xcode or Swift Package Manager:

```bash
swift test
```

## Requirements

- iOS 12.0+
- macOS 10.14+
- tvOS 12.0+
- watchOS 5.0+
- Swift 5.7+

## License

MIT License - see LICENSE file for details.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Changelog

### 1.0.0
- Initial release
- Basic logging functionality
- Thread-safe operations
- Minimum level filtering
- Timestamping support
- Comprehensive test suite
