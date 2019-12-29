//
//  Offset+Clamped.swift
//  Inclinos
//
//  Created by Johan Kool on 12/11/2018.
//  Copyright © 2018 Flat Planetoid. All rights reserved.
//

import Foundation
import UIKit

public extension CGFloat {
    
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        return CGFloat.minimum(range.upperBound, CGFloat.maximum(range.lowerBound, self))
    }
    
}
