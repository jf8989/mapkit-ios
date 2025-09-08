// App/Core/Engine/Services/PermissionManager.swift

import Combine

/// Router that forwards to specific permission handlers. Location-only for now.
public final class PermissionManager: PermissionManagerType {
    private let locationPermissionHandler: LocationPermissionHandlerType
 
    public init(locationService: LocationServiceType) {
        self.locationPermissionHandler = LocationPermissionHandler(
            locationService: locationService
        )
    }

    public var locationGate: AnyPublisher<LocationPermissionGate, Never> {
        locationPermissionHandler.gate
    }

    public func requestLocationPermission() {
        locationPermissionHandler.request()
    }
}
