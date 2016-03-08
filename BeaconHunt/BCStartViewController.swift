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
    
    
    @IBOutlet weak var StatusBarLabel: UILabel!
    private var foregroundNotification: NSObjectProtocol!
    var you_main_layer = CALayer();
    
    
    
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
        UIView.animateWithDuration(0.3, delay: 0.3, options: [], animations: {
        self.titleLabel1.frame.origin.x += 500;
        }, completion: nil)
    
        UIView.animateWithDuration(0.3, delay: 0.4, options: [], animations: {
        self.titleLabel2.frame.origin.x += 500;
        }, completion: nil)
    
        UIView.animateWithDuration(0.3, delay: 0.5, options: [], animations: {
        self.titleLabel3.frame.origin.x += 500;
        }, completion: nil)
    
        UIView.animateWithDuration(0.3, delay: 0.6, options: [], animations: {
        self.titleLabel4.frame.origin.x += 500;
        }, completion: nil)
    }
    
    
    
    func hide_titles() -> Void {
        UIView.animateWithDuration(0.3, delay: 0.3, options: [], animations: {
            self.titleLabel1.frame.origin.x -= self.view.center.x*2;            }, completion: nil)
        
        UIView.animateWithDuration(0.3, delay: 0.4, options: [], animations: {
            self.titleLabel2.frame.origin.x -= self.view.center.x*2;            }, completion: nil)
        
        UIView.animateWithDuration(0.3, delay: 0.5, options: [], animations: {
            self.titleLabel3.frame.origin.x -= self.view.center.x*2;
            }, completion: nil)
        
        UIView.animateWithDuration(0.3, delay: 0.6, options: [], animations: {
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
        you.position = CGPointMake(self.view.center.x, self.view.center.y*1.5);
        you.cornerRadius  = CGFloat(circleSize/2);
        you.backgroundColor = UIColor(hue: h, saturation: s, brightness: v, alpha: 0.2).CGColor;
        
        //animate you main layer
        let you_anim = CABasicAnimation(keyPath: "transform.scale");
        you_anim.timingFunction = CAMediaTimingFunction(name: "linear");
        you_anim.fromValue = NSNumber(double: 1);
        you_anim.toValue = NSNumber(double: 1.2);
        you_anim.duration = 5;
        you_anim.autoreverses = true;
        you_anim.repeatCount = Float.infinity;

        you.addAnimation(you_anim, forKey: "transform")
        
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
        you_layer(you_main_layer);
        self.view.layer.addSublayer(you_main_layer);
        
        
        //orbit for anim
        orbit_layer.bounds = CGRectMake(0, 0, 10, 10);
        orbit_layer.position = CGPointMake(self.view.center.x, self.view.center.y*1.5);
        orbit_layer.cornerRadius  = 0;
        
        orbit_layer.borderWidth = 0;
        orbit_layer.borderColor = UIColor.redColor().CGColor;
        
    }
    
    func deinit_hunt_gui() -> Void {
        for layer in self.you_main_layer.sublayers! {
            layer.removeFromSuperlayer();
        }
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
    var app_just_opened = 1;
    var venue_text = "Did the hunt start yet?";

    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        //hide status bar
        self.StatusBarLabel.hidden = true;
        self.StatusBarLabel.layer.zPosition = 100;
        
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
        let beaconRegion : CLBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID!,
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
             
        //add the orbital space to the phone "screen"
        self.view.layer.addSublayer(orbit_layer)
        
        
        //initialise the beacon drawing object
        beacon_canvas = BCBeacon(drawing_layer: orbit_layer, screen_center: orbit_layer.position);
        
        NSLog("orbitlayer %f %f", orbit_layer.bounds.height, orbit_layer.bounds.width);
        
        
        //view controller to be notified when the app is brought back to the foreground
        foregroundNotification = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
            [unowned self] notification in
            
            NSLog("app entered foreground");
            
            //restore all animations (you & beacon orbiting)
            self.deinit_hunt_gui();
            self.init_hunt_gui();
            
            self.beacon_canvas.animate_beacons();
        }
        
        

    }
    
    
    //touch event processing for CALayer
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
     
        for touch: AnyObject in touches {
            let location = touch.locationInView(self.view)
            self.StatusBarLabel.hidden = false;

        
            NSLog("touch! %f %f", location.x, location.y);
            
            //get beacon count
            let beacon_count = beacon_canvas.count();
            let beacon_closest = beacon_canvas.closest();
            
            
            
            if(beacon_count == 1 && beacon_closest > 0){
                self.StatusBarLabel.text = "1st treasure ~\(beacon_closest)m away"
            }else if(beacon_count >= 1 && beacon_closest >= 0 && beacon_closest < 3){
                self.StatusBarLabel.text = "You're really close!"
            }else if(beacon_count > 1 && beacon_closest > 0){
                self.StatusBarLabel.text = "Next treasure ~\(beacon_closest)m away"
            }else{
                
                if(app_just_opened == 1){
                    app_just_opened = 0;
                }else{
                    venue_text = "";
                }
                
                self.StatusBarLabel.text = "No treasures here :( \(venue_text)"
            }
            
            
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {

                self.StatusBarLabel.center = CGPointMake(self.view.center.x, self.view.layer.bounds.height-25);
                
            }, completion: nil);

            
            
            //remove old beacons
            beacon_canvas.remove_stale_beacons();
        }
        
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInView(self.view)
            
            
            NSLog("touch ended! %f %f", location.x, location.y);
            
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                
                self.StatusBarLabel.center = CGPointMake(self.view.center.x, self.view.layer.bounds.height+25);
                
            }, completion: nil);
            
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
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        
        for (_, b) in beacons.enumerate() {
            beacon_canvas.update(b);
        }
    }

 
    
    
    
    override func viewDidAppear(animated: Bool) {
        
        NSLog("View Did Appear!");
        
        
        //show the intro ONCE ONLY
        if let once: AnyObject = defaults.valueForKey("introOnceOnly") {
           //run once intro skipped
            lm.requestWhenInUseAuthorization();
            
        }else{
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("introOnceOnly") 
            
            self.presentViewController(viewController, animated: false, completion: nil)
            defaults.setInteger(1, forKey: "introOnceOnly");
        }
        
        
        //position you label correctly
        youLabel.layer.position = CGPointMake(self.view.center.x, self.view.center.y*1.5);
        
        
        //animate beacons again
        beacon_canvas.animate_beacons();
        
    }
    
    override func viewWillDisappear(animated: Bool) {

    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    deinit {
        // make sure to remove the observer when this view controller is dismissed/deallocated
        
        NSNotificationCenter.defaultCenter().removeObserver(foregroundNotification)
    }

}

