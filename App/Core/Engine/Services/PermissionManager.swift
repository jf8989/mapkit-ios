// App/Core/Engine/Services/PermissionManager.swift

import Combine

/// Router that forwards to specific permission handlers. Location-only for now.
public final class PermissionManager: PermissionManagerType {
    private let locationHandler: LocationPermissionHandlerType

    public init(locationService: LocationServiceType) {
        self.locationHandler = LocationPermissionHandler(
            locationService: locationService
        )
    }

    public var locationGate: AnyPublisher<LocationPermissionGate, Never> {
        locationHandler.gate
    }

    public func requestLocationPermission() {
        locationHandler.request()
    }
}
