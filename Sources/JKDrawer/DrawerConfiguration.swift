//
//  DrawerConfiguration.swift
//  Inclinos
//
//  Created by Johan Kool on 12/11/2018.
//  Copyright © 2018 Flat Planetoid. All rights reserved.
//

import Foundation
import UIKit

struct Values {
    static var animationDuration = 0.3
    static var snapAnimationDuration = 0.2
    static var fadeAnimationDuration = 0.1
}

public typealias Offset = CGFloat
public typealias Size = CGFloat

enum DrawerConstraintIdentifier: String {
    case size = "drawerSize"
    case side1 = "drawerSide1"
    case side2 = "drawerSide2"
    case edge = "drawerEdge"
}

public enum Gravity {
    case left
    case right
    case top
    case bottom
}

public struct DrawerConfiguration {
   
    /// Gravity determines on which side the drawer appears.
    public var gravity: Gravity
    
    /// The initial offset for the drawer.
    ///
    /// The offset is distance from the parent view at the side where the drawer is attached to the opposite side. For example, when `gravity` is `.bottom` it is the distance from the bottom of the parent view to the top of the drawer. Note that the size of the drawer may be different and could be partly offscreen.
    public var initialOffset: Offset
    
    /// The range of offsets the drawer is allowed to have.
    public var allowedRange: ClosedRange<Offset>
    
    /// Ability to adjust offset to enable snapping
    public var adjustRange: ((Offset) -> Offset)?
    
    /// When `true` the drawer can be dragged to change its offset.
    public var isDraggable: Bool {
        didSet {
            panGestureRecognizer?.isEnabled = isDraggable
        }
    }

    /// If the drawer contains a scrollview, provide it here so that can drag the drawer when scrolled to the top
    public weak var scrollView: UIScrollView?
    
    /// When `true` the drawer can be dragged closed. It will close if the offset is below half of the lower bound of the `allowedRange`.
    public var isClosable: Bool
    
    /// Speed with which user has to swipe to trigger closing a drawer without dragging all the way
    public var velocityTreshold: CGFloat
    
    public init(gravity: Gravity = .bottom, initialOffset: Offset = 0, allowedRange: ClosedRange<Offset>, adjustRange: ((Offset) -> Offset)? = nil, isDraggable: Bool = true, isClosable: Bool = false, velocityTreshold: CGFloat = 200, scrollView: UIScrollView? = nil) {
        self.gravity = gravity
        self.initialOffset = initialOffset
        self.allowedRange = allowedRange
        self.adjustRange = adjustRange
        self.panGestureRecognizer = nil
        self.drawerConstraints = [:]
        self.isDraggable = isDraggable
        self.isClosable = isClosable
        self.velocityTreshold = velocityTreshold
        self.scrollView = scrollView
    }
    
    public init(gravity: Gravity = .bottom, offset: Offset, isDraggable: Bool = true, isClosable: Bool = false) {
        self.init(gravity: gravity, initialOffset: offset, allowedRange: offset...offset, isDraggable: isDraggable, isClosable: isClosable)
    }
    
    var panGestureRecognizer: UIPanGestureRecognizer?
    var drawerConstraints: [DrawerConstraintIdentifier: NSLayoutConstraint]
    
    // State before drawer gets other drawer stacked on top
    var beforeState: DrawerState?
}

struct DrawerState {
    let offset: Offset
    let size: Size
}
