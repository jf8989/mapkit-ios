// App/Model/AppError.swift

import Foundation

/// Lightweight app error → user-message mapping.
/// Keep framework-specific errors out of Views.
public enum AppError: Error, Equatable {
    case geocodingFailed
    case notAuthorized
}

extension AppError {
    public var userMessage: String {
        switch self {
        case .geocodingFailed:
            return "Couldn’t fetch location info. Please try again."
        case .notAuthorized:
            return "Location permission is required to track your position."
        }
    }
}
