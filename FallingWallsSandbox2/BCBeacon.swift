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
    var beacons = [Int: CALayer]();
    
    //===== KALMAN FILTER =====
    let scalar_kalman = ScalarKalman();
    var F = Double(1.0);
    var H = Double(1.0);
    var p = Double(1000);
    var x = Double(0);
    var r = Double(0.1);
    var q = Double(1.0);
    var K = Double(0.0);
    
    
    init(drawing_layer: CALayer) {
        self.drawing_layer  = drawing_layer
    }
    
    
    //private functions
    func beacon_raw(circleSize: Int, position: CGPoint, color: UIColor) -> CALayer {
        //draw beacon circles
        let b = CALayer();
        b.bounds = CGRectMake(0, 0, CGFloat(circleSize), CGFloat(circleSize));
        b.position = position;
        b.cornerRadius  = CGFloat(circleSize/2);
        b.backgroundColor = color.CGColor;
        b.borderWidth = 0;

        return b;
    }
    
    func random_color() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 0.5)
    }
    
    
    func rssi_to_radius(rssi: Int) -> CGFloat {
        
        let tx_power = 59;
        let ratio_db = tx_power - rssi;
        let ratio_lin = pow(10, Double(Double(ratio_db)/10.0))
        
        let radius = sqrt(ratio_lin);
        
        
        //KALMAN
        x = scalar_kalman.predict_x(x,F: F);
        
    
        p = scalar_kalman.predict_p(p,F: F,q: q);
        K = scalar_kalman.update_K(p,H: H,r: r);
        x = scalar_kalman.update_x(x,K: K,H: H,y: Double(rssi));
        p = scalar_kalman.update_p(K,H: H,p: p);

        NSLog("kalman %d", x);
        
        
/* let avg_rssi = MovingAverage(period: 30);

avg_rssi.addSample(Double(b.rssi * (-1)))

let current = avg_rssi.average;

let current2 = map_rssi(current, in_min: 70, in_max: 0, out_min: 100, out_max: 500);

NSLog("%f", current2);
*/


        return CGFloat(radius/1000);
    }


    
    
    func new_beacon_layer() -> CALayer{
        
        let init_rad = 13;
        
        let beacon_init = CALayer();
        
        //onion shells
        for i in 2...4{
            let beacon = beacon_raw(init_rad*i, position: CGPointMake(CGFloat(init_rad), CGFloat(init_rad)), color: random_color());
            beacon_init.addSublayer(beacon);
        }
        
        
        //animate beacons
        let anim = CABasicAnimation(keyPath: "opacity");
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
        anim.fromValue = NSNumber(double: 0);
        anim.toValue = NSNumber(double: 1);
        anim.repeatCount = Float.infinity;
        anim.duration = 3;
        anim.autoreverses = true;
        anim.beginTime = CFTimeInterval(arc4random() % 2);
        
        beacon_init.addAnimation(anim, forKey: "transform");

        return beacon_init;

    }
    
    
    
    func set_beacon_layer_size(beacon_layer: CALayer, size: CGFloat) -> Void {
        beacon_layer.bounds = CGRectMake(0, 0, size, size);
        beacon_layer.cornerRadius  = size/2;
    }
    
    func set_beacon_layer_position(beacon_layer: CALayer, position: CGPoint) -> Void {
        beacon_layer.position = position;
    }
    
    
    //public functions
    func update(beacon: CLBeacon) -> Void {
        let minor:Int = Int(beacon.minor);
        let radius = rssi_to_radius(beacon.rssi);
        
        
        //check if layer was previously created
        if let beacon_sub_existing = beacons[minor] {
            // now val is not nil and the Optional has been unwrapped, so use it
            
            //update beacon and orbit layer
            // orbit_sub = layer.sublayers.first as! CALayer; //the orbit
            // beacon_sub = layer.sublayers.last as! CALayer; //the beacon
            
            
            //RSSI changes beacon size
            NSLog("TEST2 %f", radius);

            //
            set_beacon_layer_position(beacon_sub_existing, position: CGPointMake(0, 200));
            set_beacon_layer_size(beacon_sub_existing, size: 100);
            
            //DISTANCE changes beacon orbit
            
        }else{
            
            
            let beacon_sub = new_beacon_layer();
            //RSSI changes beacon size
            set_beacon_layer_size(beacon_sub, size: 100);
            //DISTANCE changes beacon orbit
            set_beacon_layer_position(beacon_sub, position: CGPointMake(0, 100));
            
            
            //add NEW beacon and orbit to layer
            drawing_layer.addSublayer(beacon_sub);
            
            //add animation to beacon layer
            

            //if not existing, add the beacon
            beacons.updateValue(beacon_sub, forKey: minor);
            
            NSLog("TEST");
        
        }
        
        
        
        
        
        
    }
    

}