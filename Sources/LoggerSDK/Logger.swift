//
//  Logger.swift
//  LoggerSDK
//
//  Created by Vincent Joy on 04/07/25.
//

import Foundation

/// A lightweight logging utility that provides thread-safe logging with different severity levels
public class Logger {
    
    /// Represents the severity level of a log message
    public enum LogLevel: Int, CaseIterable, Comparable {
        case info = 0
        case warning = 1
        case error = 2
        
        public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
        
        /// String representation of the log level
        public var description: String {
            switch self {
            case .info:
                return "INFO"
            case .warning:
                return "WARNING"
            case .error:
                return "ERROR"
            }
        }
    }
    
    /// Represents a single log entry with timestamp, level, and message
    public struct LogEntry {
        public let timestamp: Date
        public let level: LogLevel
        public let message: String
        
        /// Formatted string representation of the log entry
        public var formattedString: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            return "[\(formatter.string(from: timestamp))] [\(level.description)] \(message)"
        }
    }
    
    // MARK: - Private Properties
    
    private let minimumLevel: LogLevel
    private var logs: [LogEntry] = []
    private let queue = DispatchQueue(label: "com.loggersdk.queue", attributes: .concurrent)
    
    // MARK: - Public Initializer
    
    /// Creates a new Logger instance with the specified minimum logging level
    /// - Parameter minimumLevel: The minimum level required for a log message to be recorded. Defaults to .info
    public init(minimumLevel: LogLevel = .info) {
        self.minimumLevel = minimumLevel
    }
    
    // MARK: - Public Methods
    
    /// Logs a message with the specified level
    /// - Parameters:
    ///   - message: The message to log
    ///   - level: The severity level of the message
    /// - Note: Messages below the minimum level will be ignored
    public func log(_ message: String, level: LogLevel) {
        guard level >= minimumLevel else { return }
        
        queue.async(flags: .barrier) {
            let entry = LogEntry(timestamp: Date(), level: level, message: message)
            self.logs.append(entry)
        }
    }
    
    /// Retrieves all recent log entries
    /// - Returns: An array of LogEntry objects in chronological order
    public func getRecentLogs() -> [LogEntry] {
        return queue.sync {
            return Array(logs)
        }
    }
    
    /// Retrieves recent log entries with optional filtering
    /// - Parameters:
    ///   - count: Maximum number of entries to return. If nil, returns all entries
    ///   - level: Optional level filter. If provided, only returns entries at or above this level
    /// - Returns: An array of LogEntry objects matching the criteria
    public func getRecentLogs(count: Int? = nil, level: LogLevel? = nil) -> [LogEntry] {
        return queue.sync {
            var filteredLogs = logs
            
            if let filterLevel = level {
                filteredLogs = filteredLogs.filter { $0.level >= filterLevel }
            }
            
            if let maxCount = count {
                filteredLogs = Array(filteredLogs.suffix(maxCount))
            }
            
            return filteredLogs
        }
    }
    
    /// Clears all stored log entries
    public func clearLogs() {
        queue.async(flags: .barrier) {
            self.logs.removeAll()
        }
    }
    
    /// Returns the current number of stored log entries
    /// - Returns: The count of log entries
    public func logCount() -> Int {
        return queue.sync {
            return logs.count
        }
    }
    
    // MARK: - Convenience Methods
    
    /// Logs an info-level message
    /// - Parameter message: The message to log
    public func info(_ message: String) {
        log(message, level: .info)
    }
    
    /// Logs a warning-level message
    /// - Parameter message: The message to log
    public func warning(_ message: String) {
        log(message, level: .warning)
    }
    
    /// Logs an error-level message
    /// - Parameter message: The message to log
    public func error(_ message: String) {
        log(message, level: .error)
    }
}
