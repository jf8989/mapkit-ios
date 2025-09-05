// App/Main/AppEnvironment.swift

import Foundation

/// AppEnvironment wires protocols to live implementations.
/// Extend with `.preview` fakes during UI work or tests.
public struct AppEnvironment {
    public let locationService: LocationServiceType
    public let geocodingService: GeocodingServiceType

    public init(
        locationService: LocationServiceType,
        geocodingService: GeocodingServiceType
    ) {
        self.locationService = locationService
        self.geocodingService = geocodingService
    }

    public static var live: AppEnvironment {
        .init(
            locationService: LocationService(),
            geocodingService: GeocodingService()
        )
    }
}
