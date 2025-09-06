// App/Core/Protocols/PermissionServiceType.swift

import Combine
import CoreLocation

public protocol PermissionServiceType {
    var locationStatus: AnyPublisher<CLAuthorizationStatus, Never> { get }
    func requestLocationWhenInUse()
    func openSettings()
}
