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
    
    func adjustConstraintsForOpened(offset: CGFloat, size: CGFloat) {
        guard let sizeConstraint = configuration.drawerConstraints[.size] else {
            return
        }
        sizeConstraint.constant = size
        
        guard let edgeConstraint = configuration.drawerConstraints[.edge] else {
            return
        }
        edgeConstraint.constant = -(offset - size)
    }
    
    func adjustConstraintsForClosed() {
        guard let sizeConstraint = configuration.drawerConstraints[.size] else {
            return
        }
        adjustConstraintsForOpened(offset: -sizeConstraint.constant, size: sizeConstraint.constant)
    }
    
    var offset: CGFloat {
        guard let sizeConstraint = configuration.drawerConstraints[.size] else {
            return 0
        }
        let size = sizeConstraint.constant
        
        guard let edgeConstraint = configuration.drawerConstraints[.edge] else {
            return size
        }
        let offset = size - edgeConstraint.constant
        
        return offset
    }
    
    var size: CGFloat {
        guard let sizeConstraint = configuration.drawerConstraints[.size] else {
            return 0
        }
        return sizeConstraint.constant
    }
    
}

extension DrawerPresentable {
    
    var state: DrawerState {
        return DrawerState(offset: offset, size: size)
    }
    
}
