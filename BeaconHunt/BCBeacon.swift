//
//  BCBeacon.swift
//  FallingWallsSandbox2
//
//  Created by Sam Sulaimanov on 27/08/15.
//  Copyright (c) 2015 ethz. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

/*
beacon spotted

beacons.update(beacon)
if beacon exists
update beacon data
change beacon/orbit CALayer
else
beacons.add(beacon)


beacons.draw(CALayer)  //add all beacons to a CALayer of choice



*/



class BCBeacon {
    var drawing_layer :CALayer;
    var beacons = [Int: BCBeaconData]();
    var screen_center :CGPoint;
    
    
    init(drawing_layer: CALayer, screen_center: CGPoint) {
        self.drawing_layer  = drawing_layer;
        self.screen_center =  screen_center;
        
    }
    

    func count() -> Int {
        return beacons.count;
    }
    
    
    func closest() -> Int {
        
        var dists = [Int]();
        
        for beacon in beacons {
            if(beacon.1.distance.average.isFinite && beacon.1.distance.average.isNaN == false){
                dists.append(Int(beacon.1.distance.average));
            }
        }
        
        
        dists.sortInPlace();
        
        if(dists.count == 0){
            return 0;
        }else{
            return dists[dists.count - 1];
        }
        
    }
    
    
    //public functions
    func update(beacon: CLBeacon) -> Void {
        
        NSLog("updating a beacon");
        
        let minor:Int = Int(beacon.minor);
        let major:Int = Int(beacon.major);
        let rssi:Double = Double(beacon.rssi);

        //check if layer was previously created
        if let beacon_data_existing = beacons[minor] {
            // now val is not nil and the Optional has been unwrapped, so use it
            
            beacon_data_existing.add_rssi_sample(rssi);
            
            NSLog("minor %d", beacon_data_existing.minor);
            NSLog("dist %f", beacon_data_existing.distance.average);
            
            if(beacon_data_existing.distance.average.isNaN){
                beacon_data_existing.beacon_layer.hidden = true;
            }else{
                beacon_data_existing.beacon_layer.hidden = false;
            }
            
        }else{
            
            //never seen the beacon minor before?  -> instantiate new beacondata object
            let beacon_data = BCBeaconData(rssi: rssi, minor: minor, major: major, screen_center: screen_center);
            
            
            //add NEW beacon to drawing layer
            drawing_layer.addSublayer(beacon_data.beacon_layer);
            

            //if not existing, add the beacon
            beacons.updateValue(beacon_data, forKey: minor);
            
            NSLog("TEST");
        
        }

        
    }
    
    
    func remove_stale_beacons() -> Void {
        
        //remove beacons we haven't seen in a while
        
        for b in beacons {
            
            if ((NSDate().timeIntervalSince1970 - b.1.timestamp) > 10){
                
                b.1.beacon_layer.hidden = true;
                beacons.removeValueForKey(b.0);
            }
            
        }
        
    }
    
    
    
    func animate_beacons() -> Void{
        
        
        for beacon_to_animate in beacons {
            
                //setup rotation animation here
                let beacon_orbit_anim = CABasicAnimation(keyPath: "transform.rotation");
                beacon_orbit_anim.timingFunction = CAMediaTimingFunction(name: "linear");
                beacon_orbit_anim.fromValue = NSNumber(double: 0);
                beacon_orbit_anim.toValue = NSNumber(double: ((360*M_PI)/180));
                beacon_orbit_anim.repeatCount = Float.infinity;
                beacon_orbit_anim.duration = 7;
                beacon_orbit_anim.beginTime = Double(arc4random_uniform(15)) + CACurrentMediaTime();
                
                beacon_to_animate.1.beacon_layer.addAnimation(beacon_orbit_anim, forKey: "transform");
            
        }
            
        
    }


}