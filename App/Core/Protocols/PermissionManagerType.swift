// App/Core/Protocols/PermissionManagerType.swift

import Combine

/// Location-only gate for now; each permission gets its own type.
public enum LocationPermissionGate: Equatable {
    case authorized
    case needsRequest  // first prompt (notDetermined)
    case needsSettings  // previously denied/restricted
}

/// Manager API: explicit, permission-specific (no global enums/generics).
public protocol PermissionManagerType {
    var locationGate: AnyPublisher<LocationPermissionGate, Never> { get }
    func requestLocationPermission()
}
