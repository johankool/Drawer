//
//  DrawerPresentable.swift
//  Inclinos
//
//  Created by Johan Kool on 12/11/2018.
//  Copyright © 2018 Flat Planetoid. All rights reserved.
//

import Foundation
import UIKit

public protocol DrawerPresentable: class {
    
    var configuration: DrawerConfiguration { get set }
    
}

public extension DrawerPresentable {
    
    internal func addConstraint(_ constraint: NSLayoutConstraint, for identifier: DrawerConstraintIdentifier) {
        constraint.identifier = identifier.rawValue
        configuration.drawerConstraints[identifier] = constraint
    }
    
    func adjustConstraintsForOpened(offset: CGFloat, height: CGFloat) {
        guard let heightConstraint = configuration.drawerConstraints[.height] else {
            return
        }
        heightConstraint.constant = height
        
        guard let bottomConstraint = configuration.drawerConstraints[.bottom] else {
            return
        }
        bottomConstraint.constant = -(offset - height)
    }
    
    func adjustConstraintsForClosed() {
        guard let heightConstraint = configuration.drawerConstraints[.height] else {
            return
        }
        adjustConstraintsForOpened(offset: -heightConstraint.constant, height: heightConstraint.constant)
    }
    
    var offset: CGFloat {
        guard let heightConstraint = configuration.drawerConstraints[.height] else {
            return 0
        }
        let height = heightConstraint.constant
        
        guard let bottomConstraint = configuration.drawerConstraints[.bottom] else {
            return height
        }
        let offset = height - bottomConstraint.constant
        
        return offset
    }
    
    var height: CGFloat {
        guard let heightConstraint = configuration.drawerConstraints[.height] else {
            return 0
        }
        return heightConstraint.constant
    }
    
}

extension DrawerPresentable {
    
    var state: DrawerState {
        return DrawerState(offset: offset, height: height)
    }
    
}
