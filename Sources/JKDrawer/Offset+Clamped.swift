//
//  Offset+Clamped.swift
//  Inclinos
//
//  Created by Johan Kool on 12/11/2018.
//  Copyright © 2018 Flat Planetoid. All rights reserved.
//

import Foundation

public extension Offset {
    
    func clamped(to range: ClosedRange<Offset>) -> Offset {
        return Offset.minimum(range.upperBound, Offset.maximum(range.lowerBound, self))
    }
    
}
