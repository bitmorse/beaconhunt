//
//  BCBeaconData.swift
//  FallingWallsSandbox2
//
//  Created by Sam Sulaimanov on 27/09/15.
//  Copyright © 2015 ethz. All rights reserved.
//



import Foundation
import UIKit
import CoreLocation


class BCBeaconData {
    
    //===== KALMAN FILTER =====
    let scalar_kalman = ScalarKalman();
    var F:Double = 1.0;
    var H:Double = 1.0;
    var p:Double = 1000;
    var x:Double = 100;
    var r:Double = 0.1;
    var q:Double = 1.0;
    var K:Double = 1.0;
    
    //moving avg
    let distance = MovingAverage(period: 10);
    
    //last seen
    var timestamp = NSDate().timeIntervalSince1970;
    
    //beacon metadata
    var minor:Int = 0;
    var major:Int = 0;
    
    
    //beacon graphics layer
    var beacon_layer = CALayer();
    var screen_center:CGPoint;
    var orbit_number:CGFloat = CGFloat(arc4random_uniform(UInt32(100)));
    var orbit_radius:CGFloat = 0;
    
    init (rssi: Double, minor: Int, major: Int, screen_center: CGPoint){
        self.minor = minor;
        self.major = major;
        self.screen_center = screen_center;
        add_rssi_sample(rssi);
        beacon_layer = new_beacon_layer();
    }
    
    
    //drawing
    
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
    
    
    func new_beacon_layer() -> CALayer{
        
        let init_rad = 13;
        
        let beacon_init = CALayer();
        
        //onion shells
        for i in 2...4{
            let beacon = beacon_raw(init_rad*i, position: screen_center, color: random_color());
            beacon_init.addSublayer(beacon);
        }
        
        
        
        beacon_init.position = CGPointMake(0, 0);
        
        
        //draw beacon orbit box which will be animated to look like an orbit
        let screenSize: CGRect = UIScreen.mainScreen().bounds;
        let rad = orbit_radius * (screenSize.height) / (30);
        let ob = CALayer();
        ob.bounds = CGRectMake(0, 0, CGFloat(rad), CGFloat(rad));
        ob.cornerRadius = rad/2;
        ob.position = screen_center;
        ob.borderWidth = 0;
        ob.addSublayer(beacon_init);
        
        
        //setup rotation animation here
        let beacon_orbit_anim = CABasicAnimation(keyPath: "transform.rotation");
        beacon_orbit_anim.timingFunction = CAMediaTimingFunction(name: "linear");
        beacon_orbit_anim.fromValue = NSNumber(double: 0);
        beacon_orbit_anim.toValue = NSNumber(double: ((360*M_PI)/180));
        beacon_orbit_anim.repeatCount = Float.infinity;
        beacon_orbit_anim.duration = 7;
        beacon_orbit_anim.beginTime = Double(arc4random_uniform(15)) + CACurrentMediaTime();
        
        ob.addAnimation(beacon_orbit_anim, forKey: "transform");
        
        return ob;
    }
    
    
    
    
    func set_beacon_layer_size(size: CGFloat) -> Void {
        beacon_layer.bounds = CGRectMake(0, 0, size, size);
        beacon_layer.cornerRadius  = size/2;
    }
    
    func set_beacon_layer_orbit(orbit: CGFloat) -> Void {
        
        if(!orbit.isNaN){
            orbit_radius = orbit;
            
            
            let screenSize: CGRect = UIScreen.mainScreen().bounds;
            let rad = orbit_radius * (screenSize.height) / (30);
            beacon_layer.bounds = CGRectMake(0, 0, CGFloat(rad), CGFloat(rad));
            beacon_layer.cornerRadius = rad/2;
            
        }
 
    }
    

    
    func add_rssi_sample(rssi: Double) -> Void {
        
        //update timestamp
        timestamp = NSDate().timeIntervalSince1970;
        
        if(rssi != 0.0){
            
            let tx_power:Double = -59; //measured tx power at 1m
            
            //distance calc method 1
            let ratio:Double = Double(rssi / tx_power);
            let distanceInMeters:Double = Double(pow(ratio, 7.7095))*0.89976 + 0.111;
            //formula source: http://stackoverflow.com/questions/20416218/understanding-ibeacon-distancing
            
            
            //distance calc method 2
            let ratio_db:Double = tx_power - rssi;
            let ratio_linear:Double = pow(Double(10.0), ratio_db / 10.0);
            let radius_to_beacon = sqrt(ratio_linear);
            
            
            //KALMAN
            if(distanceInMeters > 0){
                x = scalar_kalman.predict_x(x,F: F);
                
                p = scalar_kalman.predict_p(p,F: F,q: q);
                K = scalar_kalman.update_K(p,H: H,r: r);
                x = scalar_kalman.update_x(x,K: K,H: H,y: radius_to_beacon);
                p = scalar_kalman.update_p(K,H: H,p: p);
                
                distance.addSample(x);
            }
            
        }
        
        
        //update position of beacon layer
        set_beacon_layer_orbit(CGFloat(distance.average));
    }
    
    
    
    
}