//
//  Node.swift
//  MapApp
//
//  Created by Galen Long on 11/2/14.
//  Copyright (c) 2014 Galen Long. All rights reserved.
//

import Foundation
import UIKit

// define hashing equality
func ==(lhs: Node, rhs: Node) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class Node : Hashable {
    var point: CGPoint
    var parent: Int = -1
    var neighbors: [Node] = []
    
    
    
    init(point: CGPoint) {
        self.point = point
    }
    
    func addNeighbor(node: Node) {
        neighbors.append(node)
    }

    // make Node hashable
    var hashValue: Int {
        get {
            return "\(self.point.x),\(self.point.y)".hashValue
        }
    }
    
    func setParent(parent: Int){
        self.parent = parent
    }
    

}