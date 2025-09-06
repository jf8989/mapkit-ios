// App/AppShell/AppEnvironment.swift

import Foundation

/// AppEnvironment wires protocols to live implementations.
public struct AppEnvironment {
    public let locationService: LocationServiceType
    public let geocodingService: GeocodingServiceType
    public let permissionManager: PermissionManagerType

    public init(
        locationService: LocationServiceType,
        geocodingService: GeocodingServiceType,
        permissionManager: PermissionManagerType
    ) {
        self.locationService = locationService
        self.geocodingService = geocodingService
        self.permissionManager = permissionManager
    }

    public static let live = {
        let location = LocationService()
        let geocoding = GeocodingService()
        let permissions = PermissionManager(locationService: location)
        return AppEnvironment(
            locationService: location,
            geocodingService: geocoding,
            permissionManager: permissions
        )
    }()
}
