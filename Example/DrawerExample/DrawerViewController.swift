//
//  DrawerViewController.swift
//  DrawerExample
//
//  Created by Johan Kool on 14/12/2019.
//  Copyright © 2019 Johan Kool. All rights reserved.
//

import UIKit
import JKDrawer
import os.log

class DrawerViewController: UIViewController, DrawerPresentable {

    var configuration: DrawerConfiguration = DrawerConfiguration(offset: 200)

    @IBAction func close(_ sender: Any) {
        drawerController?.closeDrawer(self, animated: true)
    }
    
}
