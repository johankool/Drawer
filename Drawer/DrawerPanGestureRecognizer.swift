//
//  DrawerPanGestureRecognizer.swift
//  Inclinos
//
//  Created by Johan Kool on 12/11/2018.
//  Copyright © 2018 Flat Planetoid. All rights reserved.
//

import Foundation

class DrawerPanGestureRecognizer: UIPanGestureRecognizer, UIGestureRecognizerDelegate {
    
    private var didPan: ((UIPanGestureRecognizer) -> Void)?
    private var shouldRecognizeSimultaneously: ((UIPanGestureRecognizer, UIGestureRecognizer) -> Bool)?

    init() {
        super.init(target: nil, action: nil)
        delegate = self
        addTarget(self, action: #selector(handlePanGestureRecognizer(_:)))
        minimumNumberOfTouches = 1
        maximumNumberOfTouches = 1
    }
    
    func setDidPan<Object: AnyObject>(delegate: Object, callback: @escaping (Object, UIPanGestureRecognizer) -> Void) {
        didPan = { [weak delegate] recognizer in
            if let delegate = delegate {
                callback(delegate, recognizer)
            }
        }
    }
    
    @objc private func handlePanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        didPan?(gestureRecognizer)
    }

    func setShouldRecognizeSimultaneously<Object: AnyObject>(delegate: Object, callback: @escaping (Object, UIPanGestureRecognizer, UIGestureRecognizer) -> Bool) {
        shouldRecognizeSimultaneously = { [weak delegate] recognizer, other -> Bool in
            if let delegate = delegate {
                return callback(delegate, recognizer, other)
            } else {
                return false
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return shouldRecognizeSimultaneously?(gestureRecognizer as! UIPanGestureRecognizer, otherGestureRecognizer) ?? false
    }

}
