//
//  Edge.swift
//  MapApp
//
//  Created by Galen Long on 11/16/14.
//  Copyright (c) 2014 Galen Long. All rights reserved.
//

import Foundation

// define hashing equality
func ==(lhs: Edge, rhs: Edge) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class Edge : Hashable {
    var n1: Node
    var n2: Node
    
    init(n1: Node, n2: Node) {
        self.n1 = n1
        self.n2 = n2
    }
    
    // make Edge hashable
    var hashValue: Int {
        get {
            return "\(self.n1.hashValue),\(self.n2.hashValue)".hashValue
        }
    }
}