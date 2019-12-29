//
//  DrawerPresenting.swift
//  Inclinos
//
//  Created by Johan Kool on 12/11/2018.
//  Copyright © 2018 Flat Planetoid. All rights reserved.
//

import Foundation
import UIKit

public protocol DrawerPresenting: class {

    func openDrawer(_ drawer: DrawerPresentable, animated: Bool)
    func closeDrawer(_ drawer: DrawerPresentable, animated: Bool)

    func changeDrawer(_ drawer: DrawerPresentable, offset: Offset, clamped: Bool, animated: Bool)

    func willOpenDrawer(_ drawer: DrawerPresentable)
    func didOpenDrawer(_ drawer: DrawerPresentable)

    func willCloseDrawer(_ drawer: DrawerPresentable)
    func didCloseDrawer(_ drawer: DrawerPresentable)

    func didChangeSizeOfDrawer(_ drawer: DrawerPresentable, to size: Size)

}

public extension DrawerPresenting where Self: UIViewController {

    private func currentDrawerForGravity(_ gravity: Gravity) -> DrawerPresentable? {
        return children.reversed().first(where: { child in
            guard let drawer = child as? DrawerPresentable else {
                return false
            }
            return drawer.configuration.gravity == gravity
        }) as? DrawerPresentable
    }
    
    private func drawerBelowDrawer(_ drawer: DrawerPresentable) -> DrawerPresentable? {
        guard let drawerController = drawer as? UIViewController else {
            fatalError()
        }

        // Return the drawer below with the same gravity as ours
        let gravity = drawer.configuration.gravity
        let drawers = children.filter { child in
            guard let drawer = child as? DrawerPresentable else {
                return false
            }
            return drawer.configuration.gravity == gravity
        }
        guard let index = drawers.firstIndex(of: drawerController), index > 0 else {
            return nil
        }
        return drawers[index - 1] as? DrawerPresentable
    }

    func openDrawer(_ drawer: DrawerPresentable, animated: Bool) {
        guard let drawerController = drawer as? UIViewController else {
            fatalError()
        }

        let currentDrawer = currentDrawerForGravity(drawer.configuration.gravity)

        willOpenDrawer(drawer)

        addChild(drawerController)
        assert(!(self is UINavigationController), "You can't open a drawer over a UINavigationController. Consider using a custom view controller wrapping the UINavigationController instead.")
        view.addSubview(drawerController.view)

        setupPanGestureRecognizer(drawer: drawer)
        setupConstraints(drawer: drawer)

        drawer.adjustConstraintsForClosed()
        view.layoutIfNeeded()

        if let currentDrawer = currentDrawer {
            // Store before
            currentDrawer.configuration.beforeState = currentDrawer.state

            if currentDrawer.offset > drawer.configuration.initialOffset {
                currentDrawer.adjustConstraintsForOpened(offset: drawer.configuration.initialOffset, size: currentDrawer.size)
            }
        }

        drawer.adjustConstraintsForOpened(offset: drawer.configuration.initialOffset, size: drawer.configuration.initialOffset)

        let animations: () -> Void = {

            self.view.layoutIfNeeded()
        }

        let completion: (Bool) -> Void = { finished in
            drawerController.didMove(toParent: self)
            self.didOpenDrawer(drawer)
            if let currentDrawerViewController = currentDrawer as? UIViewController {
                self.fade(view: currentDrawerViewController.view, alpha: 0)
            }
        }

        if animated {
            UIView.animate(withDuration: Values.animationDuration, animations: animations, completion: completion)
        } else {
            animations()
            completion(true)
        }

    }

    private func fade(view: UIView, alpha: CGFloat) {
        let animations: () -> Void = {
            view.alpha = alpha
        }
        UIView.animate(withDuration: Values.fadeAnimationDuration, animations: animations, completion: nil)
    }

    func setupPanGestureRecognizer(drawer: DrawerPresentable) {
        guard let drawerController = drawer as? UIViewController, let contentView = drawerController.view else {
            fatalError()
        }

        let panGestureRecognizer = DrawerPanGestureRecognizer()
        panGestureRecognizer.setDidPan(delegate: self) { [weak drawer] delegate, recognizer in
            guard let drawer = drawer else {
                return
            }

            delegate.handlePanGestureRecognizer(recognizer, for: drawer)
        }
        let gravity = drawer.configuration.gravity
        panGestureRecognizer.setShouldRecognizeSimultaneously(delegate: self) { [weak drawer] delegate, recognizer, other -> Bool in
            guard let scrollView = drawer?.configuration.scrollView else {
                return false
            }
            
            switch gravity {
            case .left:
                scrollView.isScrollEnabled = !(scrollView.isAtRight && recognizer.velocity(in: contentView).x > 0)
            case .right:
                scrollView.isScrollEnabled = !(scrollView.isAtLeft && recognizer.velocity(in: contentView).x < 0)
            case .top:
                scrollView.isScrollEnabled = !(scrollView.isAtBottom && recognizer.velocity(in: contentView).y < 0)
            case .bottom:
                scrollView.isScrollEnabled = !(scrollView.isAtTop && recognizer.velocity(in: contentView).y > 0)
            }

            let isPan = scrollView.panGestureRecognizer == other
            return !isPan
        }
        panGestureRecognizer.isEnabled = drawer.configuration.isDraggable
        drawer.configuration.panGestureRecognizer = panGestureRecognizer
        contentView.addGestureRecognizer(panGestureRecognizer)
    }

    func removePanGestureRecognizer(drawer: DrawerPresentable) {
        guard let drawerController = drawer as? UIViewController, let contentView = drawerController.view else {
            fatalError()
        }

        if let panGestureRecognizer = drawer.configuration.panGestureRecognizer {
            panGestureRecognizer.removeTarget(nil, action: nil)
            contentView.removeGestureRecognizer(panGestureRecognizer)
            drawer.configuration.panGestureRecognizer = nil
        }
    }

    private func handlePanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer, for drawer: DrawerPresentable) {
        let translation: CGFloat
        switch drawer.configuration.gravity {
        case .bottom:
            translation = gestureRecognizer.translation(in: view).y
        case .left:
            translation = -gestureRecognizer.translation(in: view).x
        case .top:
            translation = -gestureRecognizer.translation(in: view).y
        case .right:
            translation = gestureRecognizer.translation(in: view).x
        }
        gestureRecognizer.setTranslation(.zero, in: view)

        let offset = drawer.offset - translation

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

        let sizeConstraint: NSLayoutConstraint
        let side1Constraint: NSLayoutConstraint
        let side2Constraint: NSLayoutConstraint
        let edgeConstraint: NSLayoutConstraint
            
        switch drawer.configuration.gravity {
        case .left:
            sizeConstraint = contentView.widthAnchor.constraint(equalToConstant: drawer.configuration.initialOffset)
            side1Constraint = contentView.topAnchor.constraint(equalTo: view.topAnchor)
            side2Constraint = contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            edgeConstraint = view.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        case .right:
            sizeConstraint = contentView.widthAnchor.constraint(equalToConstant: drawer.configuration.initialOffset)
            side1Constraint = contentView.topAnchor.constraint(equalTo: view.topAnchor)
            side2Constraint = contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            edgeConstraint = contentView.rightAnchor.constraint(equalTo: view.rightAnchor)
        case .top:
            sizeConstraint = contentView.heightAnchor.constraint(equalToConstant: drawer.configuration.initialOffset)
            side1Constraint = contentView.leftAnchor.constraint(equalTo: view.leftAnchor)
            side2Constraint = contentView.rightAnchor.constraint(equalTo: view.rightAnchor)
            edgeConstraint = view.topAnchor.constraint(equalTo: contentView.topAnchor)
        case .bottom:
            sizeConstraint = contentView.heightAnchor.constraint(equalToConstant: drawer.configuration.initialOffset)
            side1Constraint = contentView.leftAnchor.constraint(equalTo: view.leftAnchor)
            side2Constraint = contentView.rightAnchor.constraint(equalTo: view.rightAnchor)
            edgeConstraint = contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        }
       
        drawer.addConstraint(sizeConstraint, for: .size)
        drawer.addConstraint(side1Constraint, for: .side1)
        drawer.addConstraint(side2Constraint, for: .side2)
        drawer.addConstraint(edgeConstraint, for: .edge)
        
        NSLayoutConstraint.activate([sizeConstraint, side1Constraint, side2Constraint, edgeConstraint])
    }

    func removeConstraints(drawer: DrawerPresentable) {
        let constraints = drawer.configuration.drawerConstraints.map { $0.value }
        NSLayoutConstraint.deactivate(constraints)
        drawer.configuration.drawerConstraints.removeAll()
    }

    func closeDrawer(_ drawer: DrawerPresentable, animated: Bool) {
        guard let drawerController = drawer as? UIViewController else {
            return
        }

        let nextDrawer = drawerBelowDrawer(drawer)

        // Restore previous drawer
        if let nextDrawer = nextDrawer, let beforeState = nextDrawer.configuration.beforeState {
            nextDrawer.adjustConstraintsForOpened(offset: beforeState.offset, size: beforeState.size)

            if let nextDrawerViewController = nextDrawer as? UIViewController {
                self.fade(view: nextDrawerViewController.view, alpha: 1)
            }
        }

        willCloseDrawer(drawer)

        drawer.adjustConstraintsForClosed()

        let animations: () -> Void = {
            self.view.layoutIfNeeded()
        }

        let completion: (Bool) -> Void = { finished in
            drawerController.view.removeFromSuperview()
            drawerController.removeFromParent()
            self.didCloseDrawer(drawer)
            self.removeConstraints(drawer: drawer)
            self.removePanGestureRecognizer(drawer: drawer)
        }

        if animated {
            UIView.animate(withDuration: Values.animationDuration, animations: animations, completion: completion)
        } else {
            animations()
            completion(true)
        }
    }

    func changeDrawer(_ drawer: DrawerPresentable, offset: CGFloat, clamped: Bool, animated: Bool) {
        let adjustedOffset: CGFloat
        var size: CGFloat
        let minSize = drawer.configuration.allowedRange.lowerBound

        if clamped {
            let closeTreshold = minSize / 2
            if drawer.configuration.isClosable, offset < closeTreshold {
                closeDrawer(drawer, animated: true)
                return
            }

            size = offset.clamped(to: drawer.configuration.allowedRange)
            if let adjustRange = drawer.configuration.adjustRange {
                size = adjustRange(size)
            }
            adjustedOffset = size
        } else {
            size = offset.clamped(to: drawer.configuration.allowedRange)
            if drawer.configuration.isClosable {
                let maxSize = drawer.configuration.allowedRange.upperBound
                adjustedOffset = min(maxSize, offset)
            } else {
                adjustedOffset = offset.clamped(to: drawer.configuration.allowedRange)
            }
        }

        drawer.adjustConstraintsForOpened(offset: adjustedOffset, size: size)

        let animations: () -> Void = {
            self.view.layoutIfNeeded()
        }

        let completion: (Bool) -> Void = { finished in
            self.didChangeSizeOfDrawer(drawer, to: adjustedOffset)
        }

        if animated {
            UIView.animate(withDuration: Values.snapAnimationDuration, animations: animations, completion: completion)
        } else {
            animations()
            completion(true)
        }
    }
}
