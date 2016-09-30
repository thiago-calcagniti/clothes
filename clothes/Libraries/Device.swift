//
//  Device.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 08/01/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import Foundation
import UIKit

class Device {
    
    func getType() -> Int {
        var iphoneDevice = 0
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.bounds.size.height {
            case 400:
//            print("iPhone Classic \(UIScreen.mainScreen().bounds.size.height)")
                iphoneDevice = 30
            case 480:
//            print("iPhone 4 or 4S \(UIScreen.mainScreen().bounds.size.height)")
                iphoneDevice = 40
            case 568:
//            print("iPhone 5 or 5S or 5C \(UIScreen.mainScreen().bounds.size.height)")
                iphoneDevice = 50
            case 667:
//            print("iPhone 6 or 6S \(UIScreen.mainScreen().bounds.size.height)")
                iphoneDevice = 60
            case 736:
//            print("iPhone 6+ or 6S+ \(UIScreen.mainScreen().bounds.size.height)")
                iphoneDevice = 61
            default:
            print("unknown size: \(UIScreen.main.bounds.size.height)")
            }
        }
        return iphoneDevice
    }
}
