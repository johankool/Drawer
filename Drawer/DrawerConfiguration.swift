//
//  DrawerConfiguration.swift
//  Inclinos
//
//  Created by Johan Kool on 12/11/2018.
//  Copyright © 2018 Flat Planetoid. All rights reserved.
//

import Foundation

struct Values {
    static var animationDuration = 0.3
    static var snapAnimationDuration = 0.2
    static var fadeAnimationDuration = 0.1
}

public typealias Offset = CGFloat

enum DrawerConstraintIdentifier: String {
    case height = "drawer_height"
    case leading = "drawer_leading"
    case trailing = "drawer_trailing"
    case bottom = "drawer_bottom"
}

public struct DrawerConfiguration {
    public enum Gravity {
        case leading
        case trailing
        case top
        case bottom
    }
    
    /// Gravity determines on which side the drawer appears. Currently only `.bottom` is supported
    public let gravity: Gravity
    
    /// The initial offset for the drawer.
    ///
    /// The offset is distance from the parent view at the side where the drawer is attached to the opposite side. For example, when `gravity` is `.bottom` it is the distance from the bottom of the parent view to the top of the drawer. Note that the height of the drawer may be different and could be partly offscreen.
    public let initialOffset: Offset
    
    /// The range of offsets the drawer is allowed to have.
    public var allowedRange: ClosedRange<Offset>
    
    /// Ability to adjust offset to enable snapping
    public let adjustRange: ((Offset) -> Offset)?
    
    /// When `true` the drawer can be dragged to change its offset.
    public var isDraggable: Bool {
        didSet {
            panGestureRecognizer?.isEnabled = isDraggable
        }
    }
    
    /// When `true` the drawer can be dragged closed. It will close if the offset is below half of the lower bound of the `allowedRange`.
    public let isClosable: Bool
    
    public init(initialOffset: Offset = 0, allowedRange: ClosedRange<Offset>, adjustRange: ((Offset) -> Offset)? = nil, isDraggable: Bool = true, isClosable: Bool = false) {
        self.gravity = .bottom
        self.initialOffset = initialOffset
        self.allowedRange = allowedRange
        self.adjustRange = adjustRange
        self.panGestureRecognizer = nil
        self.drawerConstraints = [:]
        self.isDraggable = isDraggable
        self.isClosable = isClosable
    }
    
    public init(offset: Offset, isDraggable: Bool = true, isClosable: Bool = false) {
        self.init(initialOffset: offset, allowedRange: offset...offset, isDraggable: isDraggable, isClosable: isClosable)
    }
    
    var panGestureRecognizer: UIPanGestureRecognizer?
    var drawerConstraints: [DrawerConstraintIdentifier: NSLayoutConstraint]
    
    // State before drawer gets other drawer stacked on top
    var beforeState: DrawerState?
}

struct DrawerState {
    let offset: CGFloat
    let height: CGFloat
}
