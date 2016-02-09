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
    
    @IBOutlet weak var _messageLabel  : UILabel!
    @IBOutlet weak var _latitudeLabel : UILabel!
    @IBOutlet weak var _longitudeLabel: UILabel!
    @IBOutlet weak var _addressLabel  : UILabel!
    @IBOutlet weak var _tagButton     : UIButton!
    @IBOutlet weak var _getButton     : UIButton!
    
    //MARK: *************** PROPERTIES *****************
    
    let _locationManager = CLLocationManager()
    
    //MARK: **************** ACTIONS *******************
    
    @IBAction func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        
        switch authStatus
        {
        case .NotDetermined       : _locationManager.requestWhenInUseAuthorization()
        case .Denied, .Restricted : showLocationServicesDeniedAlert()
        default                   : break
        }
        
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        _locationManager.startUpdatingLocation()
    }

    //MARK: ********** OVERRIDED FUNCTIONS **********
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError \(error)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
    }
    
}

