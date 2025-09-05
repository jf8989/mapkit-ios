// App/Core/Engine/Services/PermissionService.swift

import Combine
import CoreLocation
import UIKit

/// App-level permission facade. Keeps prompting and Settings deep-link out of VMs.
public final class PermissionService: PermissionServiceType {
    private let locationService: LocationServiceType

    public init(locationService: LocationServiceType) {
        self.locationService = locationService
    }

    public var locationStatus: AnyPublisher<CLAuthorizationStatus, Never> {
        locationService.authorizationStatus
    }

    public func requestLocationWhenInUse() {
        locationService.requestWhenInUseAuthorization()
    }

    public func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
