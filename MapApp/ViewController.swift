//
//  ViewController.swift 
//  MapApp
//
//  Created by Galen Long on 10/19/14.
//  Copyright (c) 2014 Galen Long. All rights reserved.
//

// TODO: ask Emily how many pixels = 1 meter

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: UIImageView!
    
    // set panning boundaries
    var topBoundary: CGFloat = 0
    var leftBoundary: CGFloat = 0
    var rightBoundary: CGFloat = 375
    var bottomBoundary: CGFloat = 710
    
    var nodes: [Node] = []

    var nodeButtonDict = [UIButton: Node]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        
        var desiredCenter = CGPoint(x:recognizer.view!.center.x + translation.x,
            y:recognizer.view!.center.y + translation.y)
        
        // coordinates of current position relative to superview
        var topLeftX: CGFloat = mapView.frame.origin.x
        var topLeftY: CGFloat = mapView.frame.origin.y
        var bottomRightX: CGFloat = mapView.frame.origin.x + mapView.frame.width
        var bottomRightY: CGFloat = mapView.frame.origin.y + mapView.frame.height
        
        // limit panning to screen bounaries
        if (topLeftX + translation.x < leftBoundary
            && topLeftY + translation.y < topBoundary
            && bottomRightX + translation.x > rightBoundary
            && bottomRightY + translation.y > bottomBoundary)
        {
            recognizer.view!.center = desiredCenter
            //println("ok!")
        } else {
            //println("oh no!")
        }
        
        // don't compound translation with multiple calls for same pan
        recognizer.setTranslation(CGPointZero, inView: self.view)
    }
    
    @IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformScale(recognizer.view!.transform,
            recognizer.scale, recognizer.scale)
        
        // todo: limit pinching
        // todo: automatically move image back to within boundaries if pinching would move it out
        
        // don't compound scaling with multiple calls for same pinch
        recognizer.scale = 1
    }
    
    @IBAction func handleTap(recognizer : UITapGestureRecognizer) {
        // creates node object, adds to list of nodes
        let node = Node(point: recognizer.locationOfTouch(0, inView: mapView))
        nodes += [node]
        
        // draws node as green rectangle on map
        let button = UIButton.buttonWithType(UIButtonType.System) as UIButton
        button.frame = CGRect(x: node.point.x-2.5, y: node.point.y-2.5, width:5, height:5)
        button.backgroundColor = UIColor.greenColor()
        
        // TODO: add edges on single click
        // have to store previously clicked node (and delete it if you click somewhere that's not a node)
        
        // TODO: change to removing on double, NOT single, click
        button.addTarget(self, action: "removeNode:", forControlEvents: UIControlEvents.TouchUpInside)
        
        // TODO: immediately pan back to current position after adding a button to avoid jerking back to center
        mapView.addSubview(button)
        
        nodeButtonDict[button] = node
        
        // prints list of nodes so far
        // TODO: change to print nodes from dictionary
        for node in nodes {
            print(node.point)
            print(", ")
        }
        println("\n")
    }
    
    
    func removeNode(sender: UIButton!) {
        println("Removed node")
        let node = nodeButtonDict[sender]
        if (node != nil){
            // remove node from dictionary -> node can no longer be referenced and will be deleted?
            nodeButtonDict[sender] = nil
        }
        sender.removeFromSuperview()
    }
    
}
