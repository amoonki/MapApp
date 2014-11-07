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
    
    // dictionary to map buttons with corresponding node
    var nodeButtonDict = [UIButton: Node]()
    // var to store node clicked previously (if no edge has been established for this node yet)
    var previouslyClickedNode: Node? = nil
    // dictionary to store pairs of nodes and the weight of their edges
    var edgeDict = [(Node?, Node), Double?]()
    
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
        
        // draws node as green rectangle on map
        let button = UIButton.buttonWithType(UIButtonType.System) as UIButton
        button.frame = CGRect(x: node.point.x-2.5, y: node.point.y-2.5, width:5, height:5)
        button.backgroundColor = UIColor.greenColor()
        
        // TODO: add edges on single click
        // have to store previously clicked node (and delete it if you click somewhere that's not a node) <-- the section in 
        // parenthesis is redundant - createEdge method is not called if not clicked on a button (Linh)
        
        button.addTarget(self, action: "createEdge:", forControlEvents: UIControlEvents.TouchDown)
        // TODO: change to removing on double, NOT single, click // not yet implemented (Linh)
        // Obj-C codes
        /* #pragma mark Actions
        - (void) singleTapOnButton:(id)sender
        {
            label.text = @"Single Tap";
            }
            
            - (void) doubleTapOnButton:(id)sender
        {
            label.text = @"Double Tap";
        }
        
        #pragma mark Button UIControl Actions
        - (void) touchDown:(id)sender
        {
            NSLog(@"Touch Down");
            // give it 0.2 sec for second touch
            [self performSelector:@selector(singleTapOnButton:) withObject:sender afterDelay:0.2];
            }
            
            - (void) touchDownRepeat:(id)sender
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTapOnButton:) object:sender];
            NSLog(@"Touch Down Repeat");
            [self doubleTapOnButton:sender];
        }        button.addTarget(self, action: "removeNode:", forControlEvents: UIControlEvents.TouchDownRepeat)
        */
        
        
        // TODO: immediately pan back to current position after adding a button to avoid jerking back to center
        mapView.addSubview(button)
        
        nodeButtonDict[button] = node
        
        // prints list of nodes so far
        // TODO: change to print nodes from dictionary
        for node in nodeButtonDict.values {
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
    
    func createEdge(sender: UIButton!){
        println("created edge")
        if let node = nodeButtonDict[sender]{
            if (previouslyClickedNode == nil){
                previouslyClickedNode = node
            } else {
                edgeDict[(previouslyClickedNode, node)] = 1.0
            }
        }
    }
    
}
