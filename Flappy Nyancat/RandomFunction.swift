//
//  RandomFunction.swift
//  Flappy Nyancat
//
//  Created by Frank Hu on 2017/2/21.
//  Copyright © 2017年 Weichu Hu. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGFloat{
    
    
    public static func random() -> CGFloat{
        
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    public static func random(min : CGFloat, max : CGFloat) -> CGFloat{
        
        return CGFloat.random() * (max - min) + min
    }
}
