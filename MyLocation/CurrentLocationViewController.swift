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
    
    //MARK: **************** ACTIONS *******************
    
    @IBAction func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        
        switch authStatus
        {
        case .NotDetermined       : _locationManager.requestWhenInUseAuthorization()
        case .Denied, .Restricted : showLocationServicesDeniedAlert()
        default                   : break
        }
        
        startLocationManager()
        updateLabels()
    }

    //MARK: ********** OVERRIDED FUNCTIONS **********
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: *************** FUNCTIONS *****************
    
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
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        
        _lastLocationError = nil
        _location = newLocation
        updateLabels()
    }
    
}

