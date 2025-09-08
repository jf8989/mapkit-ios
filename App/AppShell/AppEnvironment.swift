// App/AppShell/AppEnvironment.swift

import Foundation

/// AppEnvironment wires protocols to live implementations.
public struct AppEnvironment {
    public let locationAPI: LocationServiceType
    public let geocodingAPI: GeocodingServiceType
    public let permissionAPI: PermissionManagerType

    public init(
        locationAPI: LocationServiceType,
        geocodingAPI: GeocodingServiceType,
        permissionAPI: PermissionManagerType
    ) {
        self.locationAPI = locationAPI
        self.geocodingAPI = geocodingAPI
        self.permissionAPI = permissionAPI
    }

    public static let live = {
        let location = LocationService()
        let geocoding = GeocodingService()
        let permissions = PermissionManager(locationService: location)
        return AppEnvironment(
            locationAPI: location,
            geocodingAPI: geocoding,
            permissionAPI: permissions
        )
    }()
}
