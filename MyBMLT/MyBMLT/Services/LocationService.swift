import Foundation
import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentLocation: CLLocation?
    @Published var authStatus: CLAuthorizationStatus = .notDetermined

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authStatus = manager.authorizationStatus
    }

    /// Call this when the Near Me tab appears. Requests permission if needed,
    /// then fetches location. Safe to call multiple times.
    func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            fetchLocation()
        default:
            break
        }
    }

    private func fetchLocation() {
        #if os(iOS)
        manager.startUpdatingLocation()
        #else
        manager.requestLocation()
        #endif
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        #if os(macOS)
        // One-shot on macOS — stop after first fix
        manager.stopUpdatingLocation()
        #endif
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // currentLocation stays nil — view handles the no-location state
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .denied, .restricted, .notDetermined:
            break
        default:
            fetchLocation()
        }
    }
}
