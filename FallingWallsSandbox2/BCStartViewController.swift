//
//  ViewController.swift
//  FallingWallsSandbox2
//
//  Created by Sam Sulaimanov on 25/08/15.
//  Copyright (c) 2015 ethz. All rights reserved.
//

import UIKit
import CoreLocation

class BCStartViewController: UIViewController, CLLocationManagerDelegate {
    
    func map_rssi(x: Double, in_min: Double, in_max:Double, out_min:Double, out_max:Double) -> Double{
        
        let mapnum = (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
        
        return mapnum;
    }
    
    
    func random_pos(view: UIView) -> CGPoint {
        
        let height = view.frame.height
        let width = view.frame.width
        
        let randomPosition = CGPointMake(CGFloat(arc4random()) % height, CGFloat(arc4random()) % width)
        
        return randomPosition;
    }
    
    
    

    func show_titles() -> Void {
        UIView.animateWithDuration(0.3, delay: 0.3, options: nil, animations: {
        self.titleLabel1.frame.origin.x += 500;
        }, completion: nil)
    
        UIView.animateWithDuration(0.3, delay: 0.4, options: nil, animations: {
        self.titleLabel2.frame.origin.x += 500;
        }, completion: nil)
    
        UIView.animateWithDuration(0.3, delay: 0.5, options: nil, animations: {
        self.titleLabel3.frame.origin.x += 500;
        }, completion: nil)
    
        UIView.animateWithDuration(0.3, delay: 0.6, options: nil, animations: {
        self.titleLabel4.frame.origin.x += 500;
        }, completion: nil)
    }
    
    
    
    func hide_titles() -> Void {
        UIView.animateWithDuration(0.3, delay: 0.3, options: nil, animations: {
            self.titleLabel1.frame.origin.x -= self.view.center.x*2;            }, completion: nil)
        
        UIView.animateWithDuration(0.3, delay: 0.4, options: nil, animations: {
            self.titleLabel2.frame.origin.x -= self.view.center.x*2;            }, completion: nil)
        
        UIView.animateWithDuration(0.3, delay: 0.5, options: nil, animations: {
            self.titleLabel3.frame.origin.x -= self.view.center.x*2;
            }, completion: nil)
        
        UIView.animateWithDuration(0.3, delay: 0.6, options: nil, animations: {
            self.titleLabel4.frame.origin.x  -= self.view.center.x*2;            },
            completion: { (value: Bool) in
               self.sabotageButton.hidden = false;
                
                
                //stay hidden
                self.titleLabel1.hidden = true;
                self.titleLabel2.hidden = true;
                self.titleLabel3.hidden = true;
                self.titleLabel4.hidden = true;
        });
        
        
        
    }
    
    
    
    func you_circle(circleSize: Int, h: CGFloat, s: CGFloat, v: CGFloat) -> CALayer {
        
        //draw "You" circles
        let you = CALayer();
        you.bounds = CGRectMake(0, 0, CGFloat(circleSize), CGFloat(circleSize));
        you.position = CGPointMake(self.view.center.x, self.view.center.y*2);
        you.cornerRadius  = CGFloat(circleSize/2);
        you.backgroundColor = UIColor(hue: h, saturation: s, brightness: v, alpha: 0.2).CGColor;
        
        
        //animate you
        let anim = CABasicAnimation(keyPath: "transform.scale");
        anim.timingFunction = CAMediaTimingFunction(name: "linear");
        anim.fromValue = NSNumber(double: 1);
        anim.toValue = NSNumber(double: 1.2);
        anim.repeatCount = 1;
        anim.duration = 0.7;
        anim.autoreverses = true;
        
        you.addAnimation(anim, forKey: "transform");
 
        
        return you;
    }
    
    
    
    func you_layer(layer: CALayer) -> Void {
        for i in 2...6{
            let you = you_circle(i*70, h: CGFloat(23), s: CGFloat(0.02), v: CGFloat(0.89));
            layer.addSublayer(you);
        }
        
        youLabel.hidden = false;

    }
    
    
    func init_hunt_gui() -> Void {
        
        
        //draw you layer
        you_layer(self.view.layer);
        
        
        
        //orbit for anim
        orbit_layer.bounds = CGRectMake(0, 0, 200, 200);
        orbit_layer.position = CGPointMake(self.view.center.x, self.view.center.y*2);
        orbit_layer.cornerRadius  = 400;
        orbit_layer.borderColor = UIColor.redColor().CGColor;
        orbit_layer.borderWidth = 0;
        
        
    }
    
    //outlets
    @IBOutlet weak var titleLabel1: UITextField!
    @IBOutlet weak var titleLabel2: UITextField!
    @IBOutlet weak var titleLabel3: UITextField!
    @IBOutlet weak var titleLabel4: UITextField!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var youLabel: UITextField!
    @IBOutlet weak var sabotageButton: UIButton!
    
    //actions
    @IBAction func sabotageButtonAction(sender: AnyObject) {
        
    }
    
    
    @IBAction func startButtonAction(sender: AnyObject) {
        hide_titles();
        init_hunt_gui();
        
        //hide the start button (it will never come back)
        startButton.hidden = true;
    }
    
    
    
    //and global vars here
    var lm:CLLocationManager!
    var beacon_canvas:BCBeacon!;
    let orbit_layer = CALayer();
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        //location manager setup
        lm = CLLocationManager();
        lm.delegate = self;
        lm.startUpdatingHeading();
    
        
        // =============== BEACON SETUP ===============
        //setup beacon region
        let beaconUUIDString = "3C77C2A5-5D39-420F-97FD-E7735CC7F317"
        let beaconIdentifier = "ch.ethz.nervousnet"
        let beaconUUID:NSUUID? = NSUUID(UUIDString: beaconUUIDString)
        
        //NSLog("Cooking bacon...")
        let beaconRegion : CLBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID,
            identifier: beaconIdentifier)
        
        //do scan when display comes on
        beaconRegion.notifyEntryStateOnDisplay = true
        
        //update on beacons
        lm!.startMonitoringForRegion(beaconRegion)
        lm!.startRangingBeaconsInRegion(beaconRegion)
        
        lm!.startUpdatingLocation()
        // =============== BEACON SETUP ===============

        
        
        
        NSLog("startup");
        
        //animate titles
        show_titles();

        
        /*
        let anim = CABasicAnimation(keyPath: "transform.rotation");
        anim.timingFunction = CAMediaTimingFunction(name: "linear");
        anim.fromValue = NSNumber(double: 0);
        anim.toValue = NSNumber(double: ((360*M_PI)/180));
        anim.repeatCount = Float.infinity;
        anim.duration = 10;
        */
     //   layer.addAnimation(anim, forKey: "transform");
        
        
        
        //add the orbital space to the phone "screen"
        self.view.layer.addSublayer(orbit_layer)
        
        //initialise the beacon drawing object
        beacon_canvas = BCBeacon(drawing_layer: orbit_layer);
        
        beacon_canvas.rssi_to_radius(33);
        
        //beacon_canvas.
        
        
        
    }

    
    //touch event processing for CALayer
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent){
     
        for touch: AnyObject in touches {
            let location = touch.locationInView(self.view)

            
            NSLog("touch! %f", location.x);
            
            
        }
        
    }
    
    //compass event handler, currently not needed
    /*
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        
        //NSLog("mag %d", newHeading.trueHeading);
        
        
        let direction = CLLocationDirection(newHeading.trueHeading);
        let rad = CGFloat(-direction / 180.0 * M_PI);
        let rotation = CGAffineTransformMakeRotation(rad);
        
        orbit_layer.setAffineTransform(rotation);
    }
    */
    
    
    //beacon handler
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        println(beacons)
        
        for (bNum, b) in enumerate(beacons) {
            beacon_canvas.update(b as! CLBeacon);
        }
    }

 
    
    
    
    override func viewDidAppear(animated: Bool) {
       
        //show the intro ONCE ONLY
        if let once: AnyObject = defaults.valueForKey("introOnceOnly") {
           //run once intro skipped
            lm.requestWhenInUseAuthorization();
            
        }else{
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("introOnceOnly") as! UIViewController
            
            self.presentViewController(viewController, animated: false, completion: nil)
            defaults.setInteger(1, forKey: "introOnceOnly");
        }
       
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

