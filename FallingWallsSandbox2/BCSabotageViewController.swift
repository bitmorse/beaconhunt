//
//  BCSabotageViewController.swift
//  FallingWallsSandbox2
//
//  Created by Sam Sulaimanov on 26/08/15.
//  Copyright (c) 2015 ethz. All rights reserved.
//

import Foundation
import UIKit

class BCSabotageViewController: UIViewController {
    
    
    @IBAction func stopSabotageButtonAction(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil);
        
    }

}