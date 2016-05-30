//
//  Thread.swift
//  around
//
//  Created by Tom Wieschalla  on 18.05.16.
//  Copyright © 2016 Beuth. All rights reserved.
//

import UIKit
import CoreLocation

class Thread: NSObject {
    
    var threadID: String
    var title: String
    var threadDescription: String
    var range: Int
    
    init(threadID: String, title: String, description: String, range: Int) {
        self.threadID = threadID
        self.title = title
        self.threadDescription = description
        self.range = range
    }

}
