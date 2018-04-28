//
//  MapController.swift
//  CharityChecker
//
//  Created by Philip Tam on 2018-04-19.
//  Copyright © 2018 CharityDonate. All rights reserved.
//
//"AIzaSyCENWUkCSyHOsEosu7ta6hpfIEpmYLo7Qo"
import UIKit
import GoogleMaps
import GooglePlaces

class MapController: UIViewController {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    // An array to hold the list of likely places.
    var likelyPlaces: [GMSPlace] = []
    
    // The currently selected place.
    var selectedPlace: GMSPlace?
    var selected : Bool = false
    
    var new : Bool = true
    var address : CLLocationCoordinate2D!
    var addressMarker : GMSMarker!
    var addressSet : Bool = false
    
     let defaultLocation = CLLocation(latitude: 45.504166666667, longitude: -73.577222222222)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude, longitude: defaultLocation.coordinate.longitude, zoom: zoomLevel)
        
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true
        
    }
    @IBAction func goPlacePressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToPlaces", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPlaces"{
            if let destinationVC = segue.destination as? PlacesViewController {
                destinationVC.likelyPlaces = likelyPlaces
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if selected == true{
            mapView.clear()
            
            let marker = GMSMarker(position: (self.selectedPlace?.coordinate)!)
            marker.title = "Set the Dropbox address here?"
            marker.icon = GMSMarker.markerImage(with: UIColor.blue)
            marker.snippet = selectedPlace?.formattedAddress
            marker.map = mapView
            
        }
        
        listLikelyPlaces()
    }
    
    // Populate the array with the list of likely places.
    func listLikelyPlaces() {
        // Clean up from previous sessions.
        likelyPlaces.removeAll()
        
        
        placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            if let error = error {
                // TODO: Handle the error.
                print("Current Place error: \(error.localizedDescription)")
                return
            }
            
            // Get likely places and add to the list.
            if let likelihoodList = placeLikelihoods {
                for likelihood in likelihoodList.likelihoods {
                    let place = likelihood.place
                    self.likelyPlaces.append(place)
                }
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if new == true{
            let nav = parent as! UINavigationController
            let vc = nav.childViewControllers[1] as! RegisterController
            if selectedPlace != nil{
                vc.address = selectedPlace?.formattedAddress
                vc.longitude = selectedPlace?.coordinate.longitude
                vc.latitude = selectedPlace?.coordinate.latitude
            }
            else if address != nil{
                vc.longitude = address.longitude
                vc.latitude = address.latitude
            }
            if address != nil{
                self.addressMarker.map = nil
                
            }
        }else{
            let vc = parent as! ChangeParameterController
            vc.dropboxLocation? = address
           
        }
        
    }
    
    
}

extension MapController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        address = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        if addressSet == false{
            addressMarker = GMSMarker(position: (self.address)!)
            addressMarker.title = "Set the Dropbox address here?"
            addressMarker.icon = GMSMarker.markerImage(with: UIColor.blue)
            addressMarker.map = mapView
        }
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        listLikelyPlaces()
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
}
