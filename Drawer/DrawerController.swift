//
//  DrawerController.swift
//
//
//  Created by Johan Kool on 08/03/2018.
//  Copyright © 2018 Johan Kool. All rights reserved.
//

import UIKit

public typealias Offset = CGFloat

public extension Offset {
    func clamped(to range: ClosedRange<Offset>) -> Offset {
        return Offset.minimum(range.upperBound, Offset.maximum(range.lowerBound, self))
    }
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
    public let allowedRange: ClosedRange<Offset>
    
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
    
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer?
    fileprivate var drawerConstraints: [DrawerConstraintIdentifier: NSLayoutConstraint]
}

enum DrawerConstraintIdentifier: String {
    case height = "drawer_height"
    case leading = "drawer_leading"
    case trailing = "drawer_trailing"
    case bottom = "drawer_bottom"
}

public protocol DrawerPresenting: class {
    
    func openDrawer(_ drawer: DrawerPresentable, animated: Bool)
    func closeDrawer(_ drawer: DrawerPresentable, animated: Bool)
    
    func openDrawer(_ drawer: DrawerPresentable, notify: Bool, animated: Bool)
    func closeDrawer(_ drawer: DrawerPresentable, notify: Bool, animated: Bool)
    
    func changeDrawer(_ drawer: DrawerPresentable, offset: Offset, clamped: Bool, animated: Bool)
    
    func willOpenDrawer(_ drawer: DrawerPresentable)
    func didOpenDrawer(_ drawer: DrawerPresentable)
    
    func willCloseDrawer(_ drawer: DrawerPresentable)
    func didCloseDrawer(_ drawer: DrawerPresentable)
    
    func didChangeHeightOfDrawer(_ drawer: DrawerPresentable, to height: CGFloat)
    
}

public protocol DrawerPresentable: class {
    
    var configuration: DrawerConfiguration { get set }
    
}

private struct Values {
    static var animationDuration = 0.3
    static var snapAnimationDuration = 0.2
}

public extension DrawerPresenting where Self: UIViewController {
    
    func openDrawer(_ drawer: DrawerPresentable, animated: Bool) {
        openDrawer(drawer, notify: true, animated: animated)
    }
    
    func openDrawer(_ drawer: DrawerPresentable, notify: Bool, animated: Bool) {
        guard let drawerController = drawer as? UIViewController else {
            fatalError()
        }
        
        if notify {
            willOpenDrawer(drawer)
        }
        
        addChild(drawerController)
        assert(!(self is UINavigationController), "You can't open a drawer over a UINavigationController. Consider using a custom view controller wrapping the UINavigationController instead.")
        view.addSubview(drawerController.view)
        
        setupPanGestureRecognizer(drawer: drawer)
        setupConstraints(drawer: drawer)
        
        drawer.adjustConstraintsForClosed()
        view.layoutIfNeeded()
        
        drawer.adjustConstraintsForOpened(offset: drawer.configuration.initialOffset, height: drawer.configuration.initialOffset)
        
        let animations: () -> Void = {
            self.view.layoutIfNeeded()
        }
        
        let completion: (Bool) -> Void = { finished in
            drawerController.didMove(toParent: self)
            if notify {
                self.didOpenDrawer(drawer)
            }
        }
        
        if animated {
            UIView.animate(withDuration: Values.animationDuration, animations: animations, completion: completion)
        } else {
            animations()
            completion(true)
        }
        
    }
    
    func setupPanGestureRecognizer(drawer: DrawerPresentable) {
        guard let drawerController = drawer as? UIViewController, let contentView = drawerController.view else {
            fatalError()
        }
        
        let panGestureRecognizer = DrawerPanGestureRecognizer()
        panGestureRecognizer.setDidPan(delegate: self) { delegate, recognizer in
            delegate.handlePanGestureRecognizer(recognizer, for: drawer)
        }
        panGestureRecognizer.isEnabled = drawer.configuration.isDraggable
        drawer.configuration.panGestureRecognizer = panGestureRecognizer
        contentView.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func handlePanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer, for drawer: DrawerPresentable) {
        let yTranslation = gestureRecognizer.translation(in: view).y
        gestureRecognizer.setTranslation(.zero, in: view)
        
        let offset = drawer.offset - yTranslation
        
        switch gestureRecognizer.state {
        case .began, .changed:
            changeDrawer(drawer, offset: offset, clamped: false, animated: false)
        case .ended:
            changeDrawer(drawer, offset: offset, clamped: true, animated: true)
        default:
            break
        }
    }
    
    func setupConstraints(drawer: DrawerPresentable) {
        guard let drawerController = drawer as? UIViewController, let contentView = drawerController.view else {
            fatalError()
        }
        
        drawerController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstraint = contentView.heightAnchor.constraint(equalToConstant: drawer.configuration.initialOffset)
        drawer.addConstraint(heightConstraint, for: .height)
        
        let leadingConstraint = contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        drawer.addConstraint(leadingConstraint, for: .leading)
        
        let trailingConstraint = contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        drawer.addConstraint(trailingConstraint, for: .trailing)
        
        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        drawer.addConstraint(bottomConstraint, for: .bottom)
        
        NSLayoutConstraint.activate([heightConstraint, leadingConstraint, trailingConstraint, bottomConstraint])
    }
    
    func removeConstraints(drawer: DrawerPresentable) {
        let constraints = drawer.configuration.drawerConstraints.map { return $0.value }
        NSLayoutConstraint.deactivate(constraints)
        drawer.configuration.drawerConstraints.removeAll()
    }
    
    func closeDrawer(_ drawer: DrawerPresentable, animated: Bool) {
        closeDrawer(drawer, notify: true, animated: animated)
    }
    
    func closeDrawer(_ drawer: DrawerPresentable, notify: Bool, animated: Bool) {
        guard let drawerController = drawer as? UIViewController else {
            return
        }
        
        if notify {
            willCloseDrawer(drawer)
        }
        
        drawer.adjustConstraintsForClosed()
        
        let animations: () -> Void = {
            self.view.layoutIfNeeded()
        }
        
        let completion: (Bool) -> Void = { finished in
            drawerController.view.removeFromSuperview()
            drawerController.removeFromParent()
            if notify {
                self.didCloseDrawer(drawer)
            }
            self.removeConstraints(drawer: drawer)
        }
        
        if animated {
            UIView.animate(withDuration: Values.animationDuration, animations: animations, completion: completion)
        } else {
            animations()
            completion(true)
        }
    }
    
    func changeDrawer(_ drawer: DrawerPresentable, offset: CGFloat, clamped: Bool, animated: Bool) {
        let offset2: CGFloat
        var height: CGFloat
        let minHeight = drawer.configuration.allowedRange.lowerBound
        
        if clamped {
            let closeTreshold = minHeight / 2
            if drawer.configuration.isClosable, offset < closeTreshold {
                closeDrawer(drawer, animated: true)
                return
            }
            
            height = offset.clamped(to: drawer.configuration.allowedRange)
            if let adjustRange = drawer.configuration.adjustRange {
                height = adjustRange(height)
            }
            offset2 = height
        } else {
            height = offset.clamped(to: drawer.configuration.allowedRange)
            if drawer.configuration.isClosable {
                let maxHeight = drawer.configuration.allowedRange.upperBound
                offset2 = min(maxHeight, offset)
            } else {
                offset2 = offset.clamped(to: drawer.configuration.allowedRange)
            }
        }
        
        drawer.adjustConstraintsForOpened(offset: offset2, height: height)
        
        let animations: () -> Void = {
            self.view.layoutIfNeeded()
        }
        
        let completion: (Bool) -> Void = { finished in
            self.didChangeHeightOfDrawer(drawer, to: offset)
        }
        
        if animated {
            UIView.animate(withDuration: Values.snapAnimationDuration, animations: animations, completion: completion)
        } else {
            animations()
            completion(true)
        }
    }
}

class DrawerPanGestureRecognizer: UIPanGestureRecognizer, UIGestureRecognizerDelegate {
    
    private var didPan: ((UIPanGestureRecognizer) -> Void)?
    
    init() {
        super.init(target: nil, action: nil)
        delegate = self
        addTarget(self, action: #selector(handlePanGestureRecognizer(_:)))
        minimumNumberOfTouches = 1
        maximumNumberOfTouches = 1
    }
    
    func setDidPan<Object: AnyObject>(delegate: Object, callback: @escaping (Object, UIPanGestureRecognizer) -> Void) {
        self.didPan = { [weak delegate] recognizer in
            if let delegate = delegate {
                callback(delegate, recognizer)
            }
        }
    }
    
    @objc private func handlePanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        didPan?(gestureRecognizer)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
}

public extension DrawerPresentable {
    
    fileprivate func addConstraint(_ constraint: NSLayoutConstraint, for identifier: DrawerConstraintIdentifier) {
        constraint.identifier = identifier.rawValue
        configuration.drawerConstraints[identifier] = constraint
    }
    
    fileprivate func adjustConstraintsForOpened(offset: CGFloat, height: CGFloat) {
        guard let heightConstraint = configuration.drawerConstraints[.height] else {
            return
        }
        heightConstraint.constant = height
        
        guard let bottomConstraint = configuration.drawerConstraints[.bottom] else {
            return
        }
        bottomConstraint.constant = -(offset - height)
    }
    
    fileprivate func adjustConstraintsForClosed() {
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
    
}

public extension UIViewController {
    
    var drawerController: DrawerPresenting? {
        var candidate: UIViewController? = self
        while !(candidate is DrawerPresenting || candidate == nil) {
            candidate = candidate?.parent
        }
        return candidate as? DrawerPresenting
    }
    
}

public class DrawerNavigationController: UINavigationController, DrawerPresentable {
    
    public var configuration: DrawerConfiguration
    
    init(rootViewController: UIViewController, configuration: DrawerConfiguration) {
        self.configuration = configuration
        super.init(rootViewController: rootViewController)
        self.configuration = configuration // Because UINavigationController init calls are a mess!
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.configuration = DrawerConfiguration(offset: 0)
        super.init(coder: aDecoder)
    }
    
    override init(rootViewController: UIViewController) {
        self.configuration = DrawerConfiguration(offset: 0)
        super.init(rootViewController: rootViewController)
        if let rootViewController = rootViewController as? DrawerPresentable {
            self.configuration = rootViewController.configuration
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.configuration = DrawerConfiguration(offset: 0)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
}
