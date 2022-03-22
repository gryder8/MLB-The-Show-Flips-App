//
//  Cache.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 3/21/22.
//

import Foundation
import SwiftUI

class Cache {
    static let shared = Cache()
    
    public var imagesCache: NSCache<NSString, UIImage>?
    
    init() {
        self.imagesCache = NSCache<NSString, UIImage>()
    }
}
