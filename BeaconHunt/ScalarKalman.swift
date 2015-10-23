//
//  ScalarKalman.swift
//  FallingWallsSandbox2
//
//  Created by Sam Sulaimanov on 04/09/15.
//  Copyright (c) 2015 ethz. All rights reserved.
//

import Foundation

class ScalarKalman {

    
    func predict_x(x: Double, F: Double) -> Double
    {
        return (F*x);
    }
    
    func predict_p(p:Double, F:Double, q:Double) -> Double
    {
        return ((F*p)+q);
    }
    
    func update_K(p:Double, H:Double, r:Double) -> Double
    {
        return (p/((H*H*p)+r));
    }
    
    func update_x(x: Double, K: Double, H: Double, y: Double) -> Double
    {
        var a = 0.0;
        a = x + (K*(y - (H*x)));
        return a;
    }
    
    func update_p(K: Double, H: Double, p: Double) -> Double
    {
        return ((1 - (H*K))*p);
    }

}