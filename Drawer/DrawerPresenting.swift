//
//  DrawerPresenting.swift
//  Inclinos
//
//  Created by Johan Kool on 12/11/2018.
//  Copyright © 2018 Flat Planetoid. All rights reserved.
//

import Foundation

public protocol DrawerPresenting: class {
    
    func openDrawer(_ drawer: DrawerPresentable, animated: Bool)
    func closeDrawer(_ drawer: DrawerPresentable, animated: Bool)
    
    func changeDrawer(_ drawer: DrawerPresentable, offset: Offset, clamped: Bool, animated: Bool)
    
    func willOpenDrawer(_ drawer: DrawerPresentable)
    func didOpenDrawer(_ drawer: DrawerPresentable)
    
    func willCloseDrawer(_ drawer: DrawerPresentable)
    func didCloseDrawer(_ drawer: DrawerPresentable)
    
    func didChangeHeightOfDrawer(_ drawer: DrawerPresentable, to height: CGFloat)
    
}

public extension DrawerPresenting where Self: UIViewController {
    
    private var currentDrawer: DrawerPresentable? {
        return children.reversed().first(where: { $0 is DrawerPresentable }) as? DrawerPresentable
    }
    
    private func drawerBelowDrawer(_ drawer: DrawerPresentable) -> DrawerPresentable? {
        guard let drawerController = drawer as? UIViewController else {
            fatalError()
        }
        
        let drawers = children.filter { $0 is DrawerPresentable }
        guard let index = drawers.firstIndex(of: drawerController), index > 0 else {
           return nil
        }
        return drawers[index - 1] as? DrawerPresentable
    }
    
    func openDrawer(_ drawer: DrawerPresentable, animated: Bool) {
        guard let drawerController = drawer as? UIViewController else {
            fatalError()
        }
        
        let currentDrawer = self.currentDrawer

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
                currentDrawer.adjustConstraintsForOpened(offset: drawer.configuration.initialOffset, height: currentDrawer.height)
            }
        }
   
        drawer.adjustConstraintsForOpened(offset: drawer.configuration.initialOffset, height: drawer.configuration.initialOffset)
        
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
        panGestureRecognizer.setShouldRecognizeSimultaneously(delegate: self) { [weak drawer] delegate, recognizer, other -> Bool in
            guard let scrollView = drawer?.configuration.scrollView else {
                return false
            }
            let direction = recognizer.velocity(in: contentView).y
            if scrollView.contentOffset.y == 0 && direction > 0 {
                scrollView.isScrollEnabled = false
            } else {
                scrollView.isScrollEnabled = true
            }

            let isPan = scrollView.panGestureRecognizer == other
            return !isPan
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
        guard let drawerController = drawer as? UIViewController else {
            return
        }
        
        let nextDrawer = drawerBelowDrawer(drawer)
        
        // Restore previous drawer
        if let nextDrawer = nextDrawer, let beforeState = nextDrawer.configuration.beforeState {
            nextDrawer.adjustConstraintsForOpened(offset: beforeState.offset, height: beforeState.height)
            
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
            adjustedOffset = height
        } else {
            height = offset.clamped(to: drawer.configuration.allowedRange)
            if drawer.configuration.isClosable {
                let maxHeight = drawer.configuration.allowedRange.upperBound
                adjustedOffset = min(maxHeight, offset)
            } else {
                adjustedOffset = offset.clamped(to: drawer.configuration.allowedRange)
            }
        }
        
        drawer.adjustConstraintsForOpened(offset: adjustedOffset, height: height)
        
        let animations: () -> Void = {
            self.view.layoutIfNeeded()
        }
        
        let completion: (Bool) -> Void = { finished in
            self.didChangeHeightOfDrawer(drawer, to: adjustedOffset)
        }
        
        if animated {
            UIView.animate(withDuration: Values.snapAnimationDuration, animations: animations, completion: completion)
        } else {
            animations()
            completion(true)
        }
    }
}
