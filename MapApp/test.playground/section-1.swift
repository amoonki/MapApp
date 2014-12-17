// Playground - noun: a place where people can play

import UIKit

import Foundation

public class Queue {
    var head: QNode = QNode()
    var tail: QNode = QNode()
    var count: Int = 0
    
    init(){
    }
    
    // check if list is empty
    func isEmpty() -> Bool {
        return self.count == 0
    }
    // enqueue. add item to the end of list. head unchanged, tail changed
    func enqueue(node: Node){
        let newNode: QNode = QNode(node: node)
        if self.isEmpty(){
            self.head = newNode
            self.tail = newNode
        } else {
            self.tail.next = newNode
            self.tail = newNode
        }
        count++
    }
    
    // dequeue. takes item from the beginning of list. head changed, tail unchanged
    func dequeue() -> Node? {
        if self.isEmpty() {
            return nil
        } else if self.count == 1 {
            self.count--
            return self.head.data
        } else {
            var tmp: QNode = self.head
            self.head = self.head.next!
            self.count--
            return tmp.data
        }
    }
}

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

// private class to hold the objects in the list
public class QNode{
    // data in a QNode
    var data: Node? = nil
    
    // next QNode in list
    var next: QNode? = nil
    
    init(node: Node){
        self.data = node
        self.next = nil
    }
    
    init(){
    }
    
}

let node1 = Node(point: CGPoint(x: 0.1, y: 0.1))
let node2 = Node(point: CGPoint(x: 0.2, y: 0.2))
let node3 = Node(point: CGPoint(x: 0.3, y: 0.3))
let node4 = Node(point: CGPoint(x: 0.4, y: 0.4))

let qNode1: QNode = QNode(node: node1)
print(qNode1.data!.point)
let qNode2: QNode = QNode(node: node2)
print(qNode2.data!.point)
let qNode3: QNode = QNode(node: node3)
print(qNode3.data!.point)
let qNode4: QNode = QNode(node: node4)
print(qNode4.data!.point)

var queue1 :Queue = Queue()
queue1.enqueue(node1)

queue1.enqueue(node2)
queue1.tail.data!.point
var dequeuedNode1: Node! = queue1.dequeue()
dequeuedNode1.point
var dequeuedNode2: Node! = queue1.dequeue()
dequeuedNode2.point
queue1.isEmpty()
queue1.enqueue(node3)
queue1.head.data!.point



