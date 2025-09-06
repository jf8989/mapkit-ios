// App/Core/Protocols/PermissionHandlerType.swift

import Combine

/// Permission-specific handler contract — here for Location.  Scalable.
public protocol LocationPermissionHandlerType {
    var gate: AnyPublisher<LocationPermissionGate, Never> { get }
    func request()
}
