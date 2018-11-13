//
//  UIViewController+Drawer.swift
//  Inclinos
//
//  Created by Johan Kool on 12/11/2018.
//  Copyright © 2018 Flat Planetoid. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    public var drawerController: DrawerPresenting? {
        var candidate: UIViewController? = self
        while !(candidate is DrawerPresenting || candidate == nil) {
            candidate = candidate?.parent
        }
        return candidate as? DrawerPresenting
    }
    
}
