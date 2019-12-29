//
//  MainViewController.swift
//  DrawerExample
//
//  Created by Johan Kool on 14/12/2019.
//  Copyright © 2019 Johan Kool. All rights reserved.
//

import UIKit
import JKDrawer
import os.log

class MainViewController: UIViewController {

    @IBOutlet weak var gravitySelector: UISegmentedControl!
    @IBOutlet weak var initialOffsetStepper: UIStepper!
    @IBOutlet weak var initialOffsetLabel: UILabel!
    @IBOutlet weak var minimumOffsetStepper: UIStepper!
    @IBOutlet weak var minimumOffsetLabel: UILabel!
    @IBOutlet weak var maximumOffsetStepper: UIStepper!
    @IBOutlet weak var maximumOffsetLabel: UILabel!
    @IBOutlet weak var draggableSwitch: UISwitch!
    @IBOutlet weak var closeableSwitch: UISwitch!
    
    @IBAction func openDrawer(_ sender: Any) {
        let drawerViewController = storyboard?.instantiateViewController(withIdentifier: "Drawer") as! DrawerViewController
        let gravity: Gravity
        switch gravitySelector.selectedSegmentIndex {
        case 0:
            gravity = .top
        case 1:
            gravity = .bottom
        case 2:
            gravity = .left
        case 3:
            gravity = .right
        default:
            fatalError()
        }
        let initialOffset = Offset(initialOffsetStepper!.value)
        let minimumOffset = Offset(minimumOffsetStepper!.value)
        let maximumOffset = Offset(maximumOffsetStepper!.value)
        let isDraggable = draggableSwitch!.isOn
        let isClosable = closeableSwitch!.isOn
        drawerViewController.configuration = DrawerConfiguration(gravity: gravity, initialOffset: initialOffset, allowedRange: minimumOffset...maximumOffset, adjustRange: nil, isDraggable: isDraggable, isClosable: isClosable, scrollView: nil)
        openDrawer(drawerViewController, animated: true)
    }
    
    private let numberFormatter = NumberFormatter()
    
    @IBAction func initialOffsetChanged(_ sender: Any) {
        initialOffsetLabel.text = numberFormatter.string(for: initialOffsetStepper.value)
    }
    
    @IBAction func minimumSizeChanged(_ sender: Any) {
        minimumOffsetLabel.text = numberFormatter.string(for: minimumOffsetStepper.value)
    }
    
    @IBAction func maximumSizeChanged(_ sender: Any) {
        maximumOffsetLabel.text = numberFormatter.string(for: maximumOffsetStepper.value)
    }
    
}

extension MainViewController: DrawerPresenting {
    
    func willOpenDrawer(_ drawer: DrawerPresentable) {
        os_log("Will open drawer: %{public}@", log: Log.general, type: .info, "\(drawer)")
    }
    
    func didOpenDrawer(_ drawer: DrawerPresentable) {
        os_log("Did open drawer: %{public}@", log: Log.general, type: .info, "\(drawer)")
    }
    
    func willCloseDrawer(_ drawer: DrawerPresentable) {
        os_log("Will close drawer: %{public}@", log: Log.general, type: .info, "\(drawer)")
    }
    
    func didCloseDrawer(_ drawer: DrawerPresentable) {
        os_log("Did close drawer: %{public}@", log: Log.general, type: .info, "\(drawer)")
    }
    
    func didChangeSizeOfDrawer(_ drawer: DrawerPresentable, to size: Size) {
        os_log("Did change to size %f for drawer: %{public}@", log: Log.general, type: .info, size, "\(drawer)")
    }
    
}
