//
//  Queue.swift
//  MapApp
//
//  Created by Pratistha Bhattarai on 12/15/14.
//  Copyright (c) 2014 Galen Long. All rights reserved.
//

import Foundation

    public classpublic class Queue {
        private var top: Int! = Int()
        
        
        //enqueue the specified object 
        func enQueue(var key: Int) {
//check for the instance 
            if (top == nil) {
                top = key
}
            var childToUse: QNode<T> = QNode<T>()
            var current: QNode = top
//cycle through the list of items to get to the end. 
            while (current.next != nil) {
                current = current.next!
} //append a new item 
            childToUse.key = key;
            current.next = childToUse;
        }
}