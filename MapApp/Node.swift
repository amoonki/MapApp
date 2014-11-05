//
//  Node.swift
//  MapApp
//
//  Created by Galen Long on 11/2/14.
//  Copyright (c) 2014 Galen Long. All rights reserved.
//

import Foundation
import UIKit

class Node {
    var point: CGPoint
    var neighbors: [Node] = []
    
    init(point: CGPoint) {
        self.point = point
    }
    
    func addNeighbor(nodes: [Node]) {
        neighbors += nodes
    }
}