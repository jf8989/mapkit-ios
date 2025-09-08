// App/Utilities/Types/AlertState.swift

import Foundation

public struct AlertState: Identifiable, Equatable {
    public let id = UUID()
    public var title: String
    public var message: String

    public init(title: String, message: String) {
        self.title = title
        self.message = message
    }
}
