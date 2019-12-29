//
//  Log.swift
//  DrawerExample
//
//  Created by Johan Kool on 14/12/2019.
//  Copyright © 2019 Johan Kool. All rights reserved.
//

import Foundation
import os.log

struct Log {
    
    static var general: OSLog = {
        if let bundleID = Bundle.main.bundleIdentifier {
            return OSLog(subsystem: bundleID, category: "general")
        } else {
            fatalError("missing bundle ID")
        }
    }()
    
}
