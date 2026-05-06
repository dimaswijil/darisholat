//
//  LocationManager.swift
//  DariSholat
//
//  CLLocationManager wrapper with reverse geocoding for city name.
//

import Foundation
import CoreLocation
import Combine

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
        // macOS uses requestWhenInUseAuthorization (macOS 11+)
        // or requestAlwaysAuthorization
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }

    func requestLocation() {
        locationManager.requestLocation()
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
        print("Location error: \(error.localizedDescription)")
        // Fallback to Jakarta if location fails
        let fallback = CLLocation(latitude: -6.2088, longitude: 106.8456)
        DispatchQueue.main.async {
            self.currentLocation = fallback
            self.cityName = "Jakarta (default)"
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
            // Fallback to Jakarta
            let fallback = CLLocation(latitude: -6.2088, longitude: 106.8456)
            DispatchQueue.main.async {
                self.currentLocation = fallback
                self.cityName = "Jakarta (default)"
            }
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
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
