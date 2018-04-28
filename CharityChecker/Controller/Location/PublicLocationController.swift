//
//  PublicLocationController.swift
//  CharityChecker
//
//  Created by Philip Tam on 2018-04-21.
//  Copyright © 2018 CharityDonate. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import web3swift
import BigInt

class PublicLocationController: UIViewController {

    @IBOutlet weak var dismissButton: CheckButton!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var donateView: UIView!
    @IBOutlet weak var codeView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var charityLabel: UILabel!
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    let defaultLocation = CLLocation(latitude: 45.504166666667, longitude: -73.577222222222)
    var likelyPlaces: [GMSPlace] = []
    
    var charityName : String?
    var dropboxLocation : CLLocationCoordinate2D?
    var qrCode : String?
    
    
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
        // Do any additional setup after loading the view.
        
        textField.placeholder = qrCode!
        textField.adjustsFontSizeToFitWidth = true
        textField.delegate = self
        view.bringSubview(toFront: dismissButton)
        view.bringSubview(toFront: donateView)
        view.bringSubview(toFront: codeView)
        
        let marker = GMSMarker(position: dropboxLocation!)
        marker.title = "DropBox Locatiom"
        marker.icon = GMSMarker.markerImage(with: UIColor.blue)
        if charityName == "Charity has not been set!"{
            marker.snippet = "Charity has not been set!"
        }else{
            marker.snippet = "\(charityName!) Donation Box"
        }
      
        marker.map = mapView
        
        charityLabel.text = ("Charity: \(charityName!)")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    @IBAction func dismissButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func reportField(_ sender: UIButton) {
        //TO DO: Public Report Problem
        
    }
}
    
extension PublicLocationController: CLLocationManagerDelegate {
        
        // Handle incoming location events.
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let location: CLLocation = locations.last!
            print("Location: \(location)")
            
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                                  longitude: location.coordinate.longitude,
                                                  zoom: zoomLevel)
            
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

extension PublicLocationController : UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = qrCode!
        return false
    }
}
