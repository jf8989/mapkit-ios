// App/Model/AppError.swift

import Foundation

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
