//
//  DrawerNavigationController.swift
//  Inclinos
//
//  Created by Johan Kool on 12/11/2018.
//  Copyright © 2018 Flat Planetoid. All rights reserved.
//

import UIKit

public class DrawerNavigationController: UINavigationController, DrawerPresentable {
    
    public var configuration: DrawerConfiguration
    
    public init(rootViewController: UIViewController, configuration: DrawerConfiguration) {
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
