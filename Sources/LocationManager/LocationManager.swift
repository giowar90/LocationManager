//
//  ManagerLocation.swift
//  DemoIronbit
//
//  Created by Gio Guerra on 08/08/23.
//

import UIKit
import Foundation
import CoreLocation

public protocol ManagerLocationDelegate {
    func getLocation(location: CLLocation)
}

public class ManagerLocation: NSObject {

    // create strong intance "Singleton"
    public static var share = ManagerLocation()
    public var delegate: ManagerLocationDelegate?
    public lazy var locationManager: CLLocationManager = { [unowned self] in
        var location = CLLocationManager()
        
        location.allowsBackgroundLocationUpdates = true
        location.distanceFilter = kCLDistanceFilterNone
        location.showsBackgroundLocationIndicator = true
        location.desiredAccuracy = kCLLocationAccuracyHundredMeters
        location.startMonitoringSignificantLocationChanges()
        return location
    }()

    public override init() {
        super.init()
        locationManager.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            let authorizationStatus: CLAuthorizationStatus

            if #available(iOS 14, *) {
                authorizationStatus = locationManager.authorizationStatus
            } else {
                authorizationStatus = CLLocationManager.authorizationStatus()
            }

            if CLLocationManager.locationServicesEnabled() {
                if (authorizationStatus == .authorizedAlways ||
                    authorizationStatus == .authorizedWhenInUse) {
                    print("")
                } else {
                    locationManager.requestWhenInUseAuthorization()
                }
            }
        }
    }

    func checkLocation() {
        print("")
    }

    public func startupdateLocation() {
        self.enableLocation()
    }

    func configLocationManager() {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.showsBackgroundLocationIndicator=true
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startMonitoringSignificantLocationChanges()
    }

    // get type AuthorizationStatus
    public func checkAuthorization() -> CLAuthorizationStatus {
        //self.configLocationManager()
        if CLLocationManager.locationServicesEnabled() {
            let authorizationStatus: CLAuthorizationStatus
            let manager = CLLocationManager()

            if #available(iOS 14, *) {
                authorizationStatus = manager.authorizationStatus
            } else {
                authorizationStatus = CLLocationManager.authorizationStatus()
            }
            return authorizationStatus
        }
        return .notDetermined
    }

    // get type AuthorizationStatus
    public func getAuthorization() -> CLAuthorizationStatus {
        if CLLocationManager.locationServicesEnabled() {
            let authorizationStatus: CLAuthorizationStatus
            let manager = CLLocationManager()

            if #available(iOS 14, *) {
                authorizationStatus = manager.authorizationStatus
            } else {
                authorizationStatus = CLLocationManager.authorizationStatus()
            }
            return authorizationStatus
        }
        return .notDetermined
    }

    func retriveCurrentLocation() {

        let status = CLLocationManager.authorizationStatus()

        if(status == .denied || status == .restricted || !CLLocationManager.locationServicesEnabled()){
            return
        }

        // if haven't show location permission dialog before, show it to user
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            // if you want the app to retrieve location data even in background, use requestAlwaysAuthorization
            // locationManager.requestAlwaysAuthorization()
            return
        }

        // request location data for one-off usage
        locationManager.requestLocation()

        // keep requesting location data until stopUpdatingLocation() is called
        // locationManager.startUpdatingLocation()
    }


    // for background
    func requestForBackGround() {
        self.locationManager.requestAlwaysAuthorization()
        self.enableLocation()
    }

    // Stop all Location
    public func stopLocation() {
        self.locationManager.stopUpdatingLocation()
        self.locationManager.stopUpdatingHeading()
        self.locationManager.stopMonitoringSignificantLocationChanges()
    }

    // Star all Location
    func enableLocation() {
        DispatchQueue.global().async {
            self.locationManager.startUpdatingLocation()
            self.locationManager.startUpdatingHeading()
        }
    }
    
    public func getlocation() -> CLLocationCoordinate2D {
        guard let location = self.locationManager.location?.coordinate else { return CLLocationCoordinate2D() }
        return location
    }
    
    public static func handleEnterForeground() {
        ManagerLocation.share = ManagerLocation()
        ManagerLocation.share.locationManager.allowsBackgroundLocationUpdates = true
        ManagerLocation.share.locationManager.distanceFilter = kCLDistanceFilterNone
        ManagerLocation.share.locationManager.showsBackgroundLocationIndicator=true
        ManagerLocation.share.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        ManagerLocation.share.locationManager.startMonitoringSignificantLocationChanges()
    }

    public static func handleEnterBackground() {
        ManagerLocation.share = ManagerLocation()
        ManagerLocation.share.locationManager.allowsBackgroundLocationUpdates = true
        ManagerLocation.share.locationManager.distanceFilter = kCLDistanceFilterNone
        ManagerLocation.share.locationManager.showsBackgroundLocationIndicator=true
        ManagerLocation.share.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        ManagerLocation.share.locationManager.startMonitoringSignificantLocationChanges()
    }

    public static func handleAppKilled() {
        ManagerLocation.share = ManagerLocation()
        ManagerLocation.share.locationManager.allowsBackgroundLocationUpdates = true
        ManagerLocation.share.locationManager.distanceFilter = kCLDistanceFilterNone
        ManagerLocation.share.locationManager.showsBackgroundLocationIndicator=true
        ManagerLocation.share.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        ManagerLocation.share.locationManager.startMonitoringSignificantLocationChanges()
    }
    
}

// MARK: - CLLocationManagerDelegate
extension ManagerLocation: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("didStartMonitoringFor")
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            manager.requestAlwaysAuthorization()
            self.enableLocation()
        case .authorizedAlways:
            self.enableLocation()
        case .denied, .notDetermined:
            UserDefaults.standard.set(false, forKey: "Tracking")
            // When app is background show notificacion
            if UIApplication.shared.applicationState == .background {
            }
            // when user is active show view

        default:
            print("")
        }
        NotificationCenter.default.post(name:
                                            NSNotification.Name(rawValue: "DidChangeAuthorization"),
                                        object: manager)
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.getLocation(location: locations.last!)
    }

    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    }

    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    }

    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print("--\(newHeading)")
    }
}

