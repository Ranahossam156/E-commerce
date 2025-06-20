//
//  MapViewModel.swift
//  E-commerce
//
//  Created by Kerolos on 09/06/2025.
//

import Foundation
import MapKit
import SwiftUI


class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30.0444, longitude: 31.2357), // Cairo, Egypt
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5) // City-wide view
    )
    @Published var selectedLocation: IdentifiableLocation?
    @Published var selectedAddress: String?
    @Published var mapType: MKMapType = .standard
    private let locationManager = CLLocationManager()

    struct IdentifiableLocation: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func centerOnUserLocation() {
        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
              locationManager.authorizationStatus == .authorizedAlways else {
            print("Location permission not granted")
            return
        }
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            print("Map centered on: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            centerOnUserLocation()
        case .denied, .restricted:
            print("Location access denied or restricted")
        case .notDetermined:
            print("Location permission not yet determined")
        @unknown default:
            print("Unknown authorization status")
        }
    }

    func handleMapTap(at point: CGPoint, in region: MKCoordinateRegion, mapSize: CGSize) {
        let normalizedX = point.x / mapSize.width
        let normalizedY = point.y / mapSize.height
        let regionRadiusLat = region.span.latitudeDelta / 2
        let regionRadiusLon = region.span.longitudeDelta / 2
        let minLat = region.center.latitude - regionRadiusLat
        let maxLat = region.center.latitude + regionRadiusLat
        let minLon = region.center.longitude - regionRadiusLon
        let maxLon = region.center.longitude + regionRadiusLon
        let latitude = maxLat - (normalizedY * (maxLat - minLat))
        let longitude = minLon + (normalizedX * (maxLon - minLon))
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        selectedLocation = IdentifiableLocation(coordinate: coordinate)
        reverseGeocode(coordinate: coordinate)
    }

    func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding failed: \(error.localizedDescription)")
                self.selectedAddress = nil
                return
            }
            if let placemark = placemarks?.first {
                let addressComponents = [
                    placemark.subThoroughfare,
                    placemark.thoroughfare,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.postalCode,
                    placemark.country
                ].compactMap { $0 }.joined(separator: ", ")
                self.selectedAddress = addressComponents.isEmpty ? nil : addressComponents
            } else {
                self.selectedAddress = nil
            }
        }
    }

    func resetSelectedLocation() {
        selectedLocation = nil
        selectedAddress = nil
    }
}
