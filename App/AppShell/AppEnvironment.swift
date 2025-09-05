// App/AppShell/AppEnvironment.swift

import Foundation

/// AppEnvironment wires protocols to live implementations.
/// Extend with `.preview` fakes during UI work or tests.
public struct AppEnvironment {
    public let locationService: LocationServiceType
    public let geocodingService: GeocodingServiceType
    public let permissionService: PermissionServiceType

    public init(
        locationService: LocationServiceType,
        geocodingService: GeocodingServiceType,
        permissionService: PermissionServiceType
    ) {
        self.locationService = locationService
        self.geocodingService = geocodingService
        self.permissionService = permissionService
    }

    public static let live = {
        let location = LocationService()
        let geocoding = GeocodingService()
        let permission = PermissionService(locationService: location)
        return AppEnvironment(
            locationService: location,
            geocodingService: geocoding,
            permissionService: permission
        )
    }()
}
