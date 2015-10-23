//
//  BCSabotageViewController.swift
//  FallingWallsSandbox2
//
//  Created by Sam Sulaimanov on 26/08/15.
//  Copyright (c) 2015 ethz. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import CoreLocation

class BCSabotageViewController:  UIViewController, CBPeripheralManagerDelegate {
    
    
    var ownBeaconRegion :CLBeaconRegion!
    var ownBeaconPManager :CBPeripheralManager!
    var ownBeaconData :NSDictionary!
    
    

    
    @IBAction func stopSabotageButtonAction(sender: AnyObject) {
        
        ownBeaconPManager.stopAdvertising()
        ownBeaconPManager = nil
        
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup beacon region
        let beaconUUIDString = "3C77C2A5-5D39-420F-97FD-E7735CC7F317"
        let beaconIdentifier = "ch.ethz.nervous"
        let beaconUUID:NSUUID = NSUUID(UUIDString: beaconUUIDString)!
        
        
        //broadcast a beacon
        let beaconMinor:CLBeaconMinorValue =  UInt16((arc4random() % 1000) + 100);
        let beaconMajor:CLBeaconMajorValue = 33091
        
     
        self.ownBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID, major: beaconMajor, minor:beaconMinor, identifier: beaconIdentifier)
        self.ownBeaconData = self.ownBeaconRegion.peripheralDataWithMeasuredPower(nil)
        self.ownBeaconPManager = CBPeripheralManager    (delegate: self, queue: nil)
    }

    
    
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        
        if (peripheral.state == CBPeripheralManagerState.PoweredOn)
        {
            // Bluetooth is on
            NSLog("started beacon bcast")
            
            self.ownBeaconPManager.startAdvertising(self.ownBeaconData as! [String: AnyObject]!)
        }
        else if (peripheral.state == CBPeripheralManagerState.PoweredOff)
        {
            NSLog("BLUETOOTH OFF: stopped beacon bcast")
            
            self.ownBeaconPManager.stopAdvertising()
        }
        else if (peripheral.state == CBPeripheralManagerState.Unsupported)
        {
            NSLog("unsupported")
        }
    }
    

}