//
//  LocationManager.swift
//  DariSholat
//
//  CLLocationManager wrapper with reverse geocoding for city name.
//

import Foundation
import CoreLocation
import Combine
import AppKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var currentLocation: CLLocation?
    @Published var cityName: String = "Mendeteksi..."
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 500 // Update every 500m
        requestAuthorization()
    }

    // MARK: - Authorization

    func requestAuthorization() {
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedAlways, .authorized:
            // Already authorized — start immediately
            locationManager.startUpdatingLocation()
        case .notDetermined:
            // Request permission — will start in delegate callback
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // Permission denied — use fallback
            useFallbackLocation()
        @unknown default:
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func requestLocation() {
        if locationManager.authorizationStatus == .authorized ||
           locationManager.authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        } else {
            requestAuthorization()
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.currentLocation = location
        }
        reverseGeocode(location: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let clError = error as? CLError
        print("Location error: \(error.localizedDescription)")

        if clError?.code == .denied {
            // User denied permission — use fallback, don't keep retrying
            useFallbackLocation()
        } else if clError?.code == .locationUnknown {
            // Temporary failure — will retry automatically
            print("Location temporarily unavailable, will retry...")
        } else {
            useFallbackLocation()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }

        switch manager.authorizationStatus {
        case .authorizedAlways, .authorized:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            useFallbackLocation()
            // Optionally open System Settings for the user
            openLocationSettings()
        case .notDetermined:
            // Wait — don't call requestWhenInUseAuthorization again here
            // to avoid a loop; it was already called in requestAuthorization()
            break
        @unknown default:
            break
        }
    }

    // MARK: - Fallback

    private func useFallbackLocation() {
        let fallback = CLLocation(latitude: -6.2088, longitude: 106.8456)
        DispatchQueue.main.async {
            if self.currentLocation == nil {
                self.currentLocation = fallback
                self.cityName = "Jakarta (default)"
            }
        }
    }

    /// Opens System Settings → Privacy → Location Services on macOS
    private func openLocationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Reverse Geocoding

    private func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            if let placemark = placemarks?.first {
                let city = placemark.locality ?? placemark.administrativeArea ?? "Unknown"
                DispatchQueue.main.async {
                    self.cityName = city
                }
            }
        }
    }
}
