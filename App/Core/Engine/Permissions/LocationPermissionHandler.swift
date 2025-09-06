// App/Core/Engine/Permissions/LocationPermissionHandler.swift

import Combine
import CoreLocation

/// Knows *only* about Location permission. Owns its own state and request mechanics.
public final class LocationPermissionHandler: LocationPermissionHandlerType {
    private let locationService: LocationServiceType

    public init(locationService: LocationServiceType) {
        self.locationService = locationService
    }

    // Map CoreLocation status → location gate
    public var gate: AnyPublisher<LocationPermissionGate, Never> {
        locationService.authorizationStatus
            .map { status in
                switch status {
                case .authorizedAlways, .authorizedWhenInUse: return .authorized
                case .notDetermined: return .needsRequest
                case .denied, .restricted: return .needsSettings
                @unknown default: return .needsSettings
                }
            }
            .eraseToAnyPublisher()
    }

    public func request() {
        // iOS shows the system prompt if status == .notDetermined; otherwise it's a no-op.
        locationService.requestWhenInUseAuthorization()
    }
}
