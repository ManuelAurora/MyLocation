//
//  FirstViewController.swift
//  MyLocation
//
//  Created by Мануэль on 09.02.16.
//  Copyright © 2016 AuroraInterplay. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate
{
    //MARK: **************** OUTLETS *******************
    
    @IBOutlet weak var _messageLabel   : UILabel!
    @IBOutlet weak var _latitudeLabel  : UILabel!
    @IBOutlet weak var _longitudeLabel : UILabel!
    @IBOutlet weak var _addressLabel   : UILabel!
    @IBOutlet weak var _tagButton      : UIButton!
    @IBOutlet weak var _getButton      : UIButton!
    
    //MARK: ********** INSTANCE VARIABLES ************
    
    let _locationManager  =  CLLocationManager()
    var _updatingLocation = false
    
    var _location          : CLLocation?
    var _lastLocationError : NSError?
    
    let _geocoder  = CLGeocoder()
    var _placemarks : CLPlacemark?
    var _lastGeocodingError : NSError?
    var _performingReverseGeocoding = false
    
    //MARK: **************** ACTIONS *******************
    
    @IBAction func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        
        switch authStatus
        {
        case .NotDetermined       : _locationManager.requestWhenInUseAuthorization()
        case .Denied, .Restricted : showLocationServicesDeniedAlert()
        default                   : break
        }
        
        if _updatingLocation {
            stopLocationManager()
        } else {
            _location = nil
            _lastLocationError = nil
            startLocationManager()
        }
        
        updateLabels()
        configureGetButton()
    }

    //MARK: ********** OVERRIDED FUNCTIONS **********
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        configureGetButton()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: *************** FUNCTIONS *****************
    
    func configureGetButton() {
        if _updatingLocation {
            _getButton.setTitle("Stop", forState: .Normal)
        } else {
            _getButton.setTitle("Get My Location", forState: .Normal)
        }
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alert.addAction(okAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateLabels() {
        if let location = _location {
            _latitudeLabel.text  = String(format: "%.8f", location.coordinate.latitude)
            _longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            _tagButton.hidden    = false
            _messageLabel.text   = ""
        } else {
            _latitudeLabel.text  = ""
            _longitudeLabel.text = ""
            _addressLabel.text   = ""
            _tagButton.hidden    = true
            
            let statusMessage : String
            
            if let error = _lastLocationError {
                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if _updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            
            _messageLabel.text   = statusMessage
        }
    }
    
    func stopLocationManager() {
        if _updatingLocation {
            _locationManager.stopUpdatingLocation()
            _locationManager.delegate = nil
            _updatingLocation = false
        }
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            _locationManager.delegate = self
            _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            _locationManager.startUpdatingLocation()
            _updatingLocation = true
        }
    }
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError \(error)")
        
        if error.code == CLError.LocationUnknown.rawValue { return }
        
        _lastLocationError = error
        
        stopLocationManager()
        updateLabels()
        configureGetButton()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 { return }
        if newLocation.horizontalAccuracy < 0 { return }
        if _location == nil || _location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            _lastLocationError = nil
            _location = newLocation
            updateLabels()
            
            if newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy { print("*** We're done!")
                stopLocationManager()
                configureGetButton()
            }
            
            if !_performingReverseGeocoding {
                print("*** Going to geocode")
                _performingReverseGeocoding = true
                
                _geocoder.reverseGeocodeLocation(newLocation, completionHandler: {_placemarks, error in
                    print("*** Found placemarks: \(_placemarks), error: \(error)")
                })
            }
        }
    }
}

