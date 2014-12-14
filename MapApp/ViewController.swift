//
//  ViewController.swift 
//  MapApp
//
//  Created by Galen Long on 10/19/14.
//  Copyright (c) 2014 Galen Long. All rights reserved.
//

// todo: ask Emily how many pixels = 1 meter
// todo: add in geolocation to find current point on map

import UIKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    
    //Have Lat and Long be global.
    //Default is Facilities Management
    var latitude :CLLocationDegrees = 42.312521
    var longitude :CLLocationDegrees = -72.639737
    
    var initialLat :CGFloat = 42.312521
    var initialLong :CGFloat = -72.639737
    
    var coordx :CGFloat =  235.839038689627
    var coordy :CGFloat = 608.919720229753
    
    let xChangeWithLongitude :CGFloat = 33944.3292149
    let yChangeWithLatitude : CGFloat = 608.919720229753
    
    @IBOutlet weak var mapView: UIImageView!
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        println("Entered the function")
        
        //NOTE:
        //The CLGeocoder class provides services for converting between a coordinate (specified as a latitude and longitude) and the user-friendly representation of that coordinate.
        longitude = manager.location.coordinate.longitude
        latitude = manager.location.coordinate.latitude
        
        println("Assignment happended")
        println(longitude)
        println(latitude)
        
        //add node here as well
        var changeInLatitude: CGFloat = initialLat - 42.312521
        var changeInLongitude: CGFloat = initialLong - (-72.639737)
        
        coordx = coordx + (changeInLongitude * xChangeWithLongitude)
        coordy = coordy + (changeInLatitude * yChangeWithLatitude)
        
        let userLocation2 = Node(point: CGPoint(x: coordx,y:coordy))
        // draws node as green rectangle on map
        let button = UIButton.buttonWithType(UIButtonType.System) as UIButton
        button.frame = CGRect(x: userLocation2.point.x-2.5, y: userLocation2.point.y-2.5, width:5, height:5)
        button.backgroundColor = UIColor.redColor()
        
        mapView.addSubview(button)
        
    }
    
    
    // set panning boundaries
    var topBoundary: CGFloat = 0
    var leftBoundary: CGFloat = 0
    var rightBoundary: CGFloat = 375
    var bottomBoundary: CGFloat = 710
    
    // display these on screen
    var nodes = [
        Node(point: CGPoint(x: 221.174884249296, y: 418.856713540855)),
        Node(point: CGPoint(x: 223.689176439299, y: 390.906497867527)),
        Node(point: CGPoint(x: 232.55393552395, y: 351.070079518988)),
        Node(point: CGPoint(x: 254.01157507044, y: 367.48842492956)),
        Node(point: CGPoint(x: 226.215149253875, y: 373.308887259314))
    ]
    
    // when true, removes a node when node is clicked
    // when false, adds an edge when two nodes are clicked
    var removeNodeOrAddEdge: Bool = false;
    
    // dictionary to map buttons with corresponding node
    var nodeButtonDict = [UIButton: Node]()
    
    var previouslyClickedNode: Node? = nil
    // dictionary to store an edge and its weight
    var edgeWeightDict = [Edge: Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawExistingNodes()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        println("inside viewDidLoad")
        println(longitude)
        println(latitude)
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        //new for iOS8. We may add a description as to why we would like to add a user's description
        self.locationManager.startUpdatingLocation()
        
        let userLocation = Node(point: CGPoint(x: coordx,y:coordy))
        // draws node as green rectangle on map
        let button = UIButton.buttonWithType(UIButtonType.System) as UIButton
        button.frame = CGRect(x: userLocation.point.x-2.5, y: userLocation.point.y-2.5, width:5, height:5)
        button.backgroundColor = UIColor.blueColor()
        mapView.addSubview(button)
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        //new for iOS8. We may add a description as to why we would like to add a user's description
        self.locationManager.startUpdatingLocation()
        
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
            && bottomRightY + translation.y > bottomBoundary) {
            recognizer.view!.center = desiredCenter
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
        
        createButtonForNode(node)
        
        // todo: print nodes in code friendly format
        // prints list of nodes so far
        /*
        var i = nodeButtonDict.count
        for node in nodeButtonDict.values {
            i--
            print("Node(point: CGPoint(x: ")
            print(node.point.x)
            print(", y: ")
            print(node.point.y)
            if (i > 0) {
                print(")),\n")
            } else {
                print("))\n")
            }
        }
        println("\n")
        */
        
        // prints most recent node for Tish
        println(node.point)
        println()
        
        // resets previously clicked node
        previouslyClickedNode = nil;
    }
    
    func createButtonForNode(node: Node) {
        // draws node as green rectangle on map
        let button = UIButton.buttonWithType(UIButtonType.System) as UIButton
        button.frame = CGRect(x: node.point.x-1.25, y: node.point.y-1.25, width:2.5, height:2.5)
        button.backgroundColor = UIColor.greenColor()
        
        // clicking on a node either removes it or adds an edge to prev clicked node
        if (removeNodeOrAddEdge) {
            button.addTarget(self, action: "removeNode:", forControlEvents: UIControlEvents.TouchUpInside)
        } else {
            button.addTarget(self, action: "createEdge:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        mapView.addSubview(button)
        nodeButtonDict[button] = node
    }
    
    func drawExistingNodes() {
        for node in nodes {
            createButtonForNode(node)
        }
        
        // prints list of nodes so far
        //print("Nodes: ")
        //for node in nodeButtonDict.values {
        //print(node.point)
          //  print(", ")
        //}
        //println("\n")
        
        // resets previously clicked node
        previouslyClickedNode = nil;
    }
    
    func removeNode(sender: UIButton!) {
        println("Removed node")
        let node = nodeButtonDict[sender]
        if (node != nil){
            nodeButtonDict[sender] = nil
        }
        sender.removeFromSuperview()
        
        // todo: remove edge associated with node
        // todo: remove line representing edge
    }
    
    
    func createEdge(sender: UIButton!) {
        // if no node previously clicked, store clicked node
        if (previouslyClickedNode == nil) {
            previouslyClickedNode = nodeButtonDict[sender]
        }
        // else, create edge between nodes
        else {
            var n1: Node = nodeButtonDict[sender]!
            var n2: Node = previouslyClickedNode!
            n1.addNeighbor(n2)
            n2.addNeighbor(n1)
            var d: Double = distance(n1.point, p2: n2.point)
            edgeWeightDict[Edge(n1: n1, n2: n2)] = d;
            previouslyClickedNode = nil;
            
            
            // prints list of edges so far
            print("Edges: ")
            for (edge, weight) in edgeWeightDict {
                print(edge.n1.point)
                print(", ")
                print(edge.n2.point)
                print(" = ")
                print(weight)
                println()
            }
            println("\n")
        }
    }
    
    
    func distance(p1: CGPoint, p2: CGPoint) -> Double {
        // sqrt((x2 - x1)^2 + (y2 - y1)^2)
        var x: Double = pow(Double(p1.x) - Double(p2.x), 2)
        var y: Double = pow(Double(p1.y) - Double(p2.y), 2)
        return sqrt(x + y)
    }
    
}
