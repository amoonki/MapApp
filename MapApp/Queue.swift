//
//  Queue.swift
//  MapApp
//
//  Copyright (c) 2014 Galen Long & Pratistha Bhattarai & Linh Le. All rights reserved.
//

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
