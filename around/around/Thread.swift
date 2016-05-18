//
//  Thread.swift
//  around
//
//  Created by Tom Wieschalla  on 18.05.16.
//  Copyright © 2016 Beuth. All rights reserved.
//

import UIKit
import CoreLocation

class Thread: NSObject, NSCoding {
    
    var title: String
    var threadDescription: String
    var range: Int
    
    init(title: String, description: String, range: Int) {
        self.title = title
        self.threadDescription = description
        self.range = range
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let title = decoder.decodeObjectForKey("title") as? String,
            let threadDescription = decoder.decodeObjectForKey("threadDescription") as? String,
            let range = decoder.decodeObjectForKey("range") as? Int
            else { return nil }
        
        self.init(title: title, description: threadDescription, range: range)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.title, forKey: "title")
        aCoder.encodeObject(self.threadDescription, forKey: "threadDescription")
        aCoder.encodeObject(self.range, forKey: "range")
    }

}
