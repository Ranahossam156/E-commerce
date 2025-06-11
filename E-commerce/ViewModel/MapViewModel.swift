//
//  MapViewModel.swift
//  E-commerce
//
//  Created by Kerolos on 09/06/2025.
//

import Foundation
import MapKit
import SwiftUI


class MapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default: San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.09, longitudeDelta: 0.09)
    )
    @Published var selectedLocation: IdentifiableLocation?
    @Published var selectedAddress: String?
    @Published var mapType: MKMapType = .standard
    private let locationManager = CLLocationManager()

    struct IdentifiableLocation: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }

    func requestLocationPermission() {
//        locationManager.requestWhenInUseAuthorization()
//        if CLLocationManager.locationServicesEnabled() {
//            if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
//                if let userLocation = locationManager.location?.coordinate {
//                    region = MKCoordinateRegion(
//                        center: userLocation,
//                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//                    )
//                }
//            }
//        }
        locationManager.requestWhenInUseAuthorization()
    }

    func handleMapTap(at point: CGPoint, in region: MKCoordinateRegion, mapSize: CGSize) {
        // Convert tap point to map coordinates
        let normalizedX = point.x / mapSize.width // 0 to 1
        let normalizedY = point.y / mapSize.height // 0 to 1

        // Calculate longitude and latitude based on region
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
    
    func centerOnUserLocation() {
           guard let userLocation = locationManager.location?.coordinate else {
               print("Location unavailable")
               return
           }
           region = MKCoordinateRegion(
               center: userLocation,
               span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // Smaller span for precision
           )
       }

    func resetSelectedLocation() {
        selectedLocation = nil
        selectedAddress = nil
    }
}
