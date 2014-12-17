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
    
    @IBOutlet weak var mapView: UIImageView!
    
    // when true, removes a node when node is clicked
    
    // when false, adds an edge when two nodes are clicked
    var removeNodeOrAddEdge: Bool = false;
    
    // set panning boundaries
    var topBoundary: CGFloat = 0
    var leftBoundary: CGFloat = 0
    var rightBoundary: CGFloat = 375
    var bottomBoundary: CGFloat = 710
    
    var buttonImage = UIImage(named: "button.png")

    // get node-id dict made with dev tool
    var nodeIDdict = Nodes().nodes
    
    // dictionary to map buttons with corresponding node
    var nodeIDButtonDict = [Int: UIButton]()
    var buttonNodeIDDict = [UIButton: Int]()
    
    var previouslyClickedNode: Int? = nil
    
    var previousPath = [Int]()
    
    // dict of node ids and a list of ids of their neighbors
    var nodeIDEdgeDict = Nodes().edges
    
    // counter to keep track of source/dest
    var count: Int = 0
    
    // source node
    var srcNodeID: Int = 0
    // dest node
    var destNodeID: Int = 0

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
    
    
    
    //Not working
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {

        longitude = manager.location.coordinate.longitude
        latitude = manager.location.coordinate.latitude
        
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawExistingNodes()
        setUpEdges()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        let userLocation = Node(point: CGPoint(x: coordx,y:coordy))
        
        // draws node as green rectangle on map
        let button = UIButton.buttonWithType(UIButtonType.System) as UIButton
        button.frame = CGRect(x: userLocation.point.x-2.5, y: userLocation.point.y-2.5, width:5, height:5)
        //button.backgroundColor = UIColor.blueColor()
        mapView.addSubview(button)
        
        for id in nodeIDdict.keys {
            var thisNode :Node = nodeIDdict[id]!
            thisNode.id = id
        }
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
        
        
        // click on map adds node
        let node = Node(point: recognizer.locationOfTouch(0, inView: mapView))
        
        /*
        // create button for node
        var id = nodeIDButtonDict.count
        createButtonForNode(node, id: id)
        nodeIDdict[id] = node
        printNodes()
        */
        
        
        /* gets nearest node, performs bfs to find closest path if another node clicked */
        
        var closestNodeID :Int = findClosestNode(node)
        var closestButton: UIButton! = nodeIDButtonDict[closestNodeID]
        //closestButton.backgroundColor = UIColor.blackColor()
        
        if (count % 2 == 0){
            srcNodeID = closestNodeID
            
            for nodeID in previousPath{
                var btn: UIButton = nodeIDButtonDict[nodeID]!
                //btn.backgroundColor = UIColor.clearColor()
                btn.setImage(UIImage(named:"button_transparent.png"), forState: .Normal)
            }
            nodeIDButtonDict[srcNodeID]?.setImage(buttonImage, forState: .Normal)
            //nodeIDButtonDict[srcNodeID]?.backgroundColor = UIColor.blackColor()
            

        } else {
            destNodeID = closestNodeID
            let srcNode: Node = nodeIDdict[srcNodeID]!
            let destNode: Node = nodeIDdict[destNodeID]!
            findAndColorPath(srcNode, destNode: destNode)
        }
        count++
        
     
        let n: Node = nodeIDdict[closestNodeID] as Node!
        
        // resets previously clicked node
        previouslyClickedNode = nil;
    }
    
    func findAndColorPath(srcNode: Node, destNode:Node){
        self.bfs(srcNode, destination: destNode)
        srcNode.parent = nil
        self.colorPath(destNode)

    }
    
    func findClosestNode(inputNode: Node) -> Int{
        var p1: CGPoint = inputNode.point
        var min: CGFloat = 999.9
        var minNodeID :Int = -1
        for id in nodeIDdict.keys {
            var node2 = nodeIDdict[id]!
            var p2: CGPoint = node2.point
            var xDist :CGFloat = (p2.x - p1.x); //[2]
            var yDist :CGFloat = (p2.y - p1.y); //[3]
            var distanceVal :CGFloat = distance(p1, p2: p2)
            if (distanceVal < min) {
                min = distanceVal
                minNodeID = id
            }
        }
        return minNodeID
    }
    
//    func printNodes() {
//        // prints list of nodes in code friendly format
//        var i = -1
//        for id in nodeIDButtonDict.keys {
//            var point: CGPoint = nodeIDdict[id]!.point
//            i++
//            print("\(i): Node(point: CGPoint(x: \(point.x), y: \(point.y)))")
//            if (i < nodeIDdict.count-1) {
//                print(",\n")
//            } else {
//                print("\n")
//            }
//        }
//        println("\n")
//    }
    
    func createButtonForNode(node: Node, id: Int) {
        // draws node as green rectangle on map
        let button = UIButton.buttonWithType(UIButtonType.System) as UIButton
        button.frame = CGRect(x: node.point.x-1.25, y: node.point.y-1.25, width:2.5, height:2.5)
    
        //button.backgroundColor = UIColor.greenColor()
        
        /* dev tool disabled
        // clicking on a node either removes it or adds an edge to prev clicked node
        if (removeNodeOrAddEdge) {
            button.addTarget(self, action: "removeNode:", forControlEvents: UIControlEvents.TouchUpInside)
        } else {
            button.addTarget(self, action: "createEdge:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        */
        
        // for debugging
        //button.addTarget(self, action: "trackClickedNode:", forControlEvents: UIControlEvents.TouchUpInside)
        button.addTarget(self, action: "printID:", forControlEvents: UIControlEvents.TouchUpInside)
        
        mapView.addSubview(button)
        
        // add button with id
        nodeIDButtonDict[id] = button
        buttonNodeIDDict[button] = id
    }
    
    func drawExistingNodes() {
        for i in nodeIDdict.keys {
            createButtonForNode(nodeIDdict[i]!,id: i)
        }
    }
    
    func printID(sender: UIButton!) {
        
    }
    
    func setUpEdges() {
        for (headId, ids) in nodeIDEdgeDict {
            var head: Node = nodeIDdict[headId]!
            for tailId in ids {
                var tail: Node = nodeIDdict[tailId]!
                // will this work?
                head.addNeighbor(tail)
                nodeIDdict[headId] = head
            }
        }
    }
    
    func trackClickedNode(sender: UIButton!){
        if(count % 2 == 0){
            srcNodeID = buttonNodeIDDict[sender]!
            
            for nodeID in previousPath{
                var btn: UIButton = nodeIDButtonDict[nodeID]!
                //btn.backgroundColor = UIColor.clearColor()
                btn.setImage(UIImage(named:"button_transparent.png"), forState: .Normal)
            }
            
            //sender.backgroundColor = UIColor.blackColor()
            sender.setImage(buttonImage, forState: .Normal)
        }
        else {
            destNodeID = buttonNodeIDDict[sender]!
            let srcNode: Node = nodeIDdict[srcNodeID]!
            let destNode: Node = nodeIDdict[destNodeID]!
            findAndColorPath(srcNode, destNode: destNode)
        }
        count++
    }
    
    //dev tool
    func removeNode(sender: UIButton!) {
        let id = buttonNodeIDDict[sender]
        let node = nodeIDdict[id!]
        if (node != nil){
            buttonNodeIDDict[sender] = nil
            nodeIDButtonDict[id!] = nil
        }
        sender.removeFromSuperview()
    }
    
    //dev tool
    func createEdge(sender: UIButton!) {
        
        // if no node previously clicked, store clicked node
        if (previouslyClickedNode == nil) {
            previouslyClickedNode = buttonNodeIDDict[sender]
        }
        // else, create edge between nodes
        else {
            var n1: Int = buttonNodeIDDict[sender]!
            var n2: Int = previouslyClickedNode!
            
            previouslyClickedNode = nil;
            
            // if clicked on same node, don't add edge
            if n1 == n2 {
                return
            }
            
            /* add to edge dict */
            
            var n1ids: [Int] = []
            if nodeIDEdgeDict[n1] != nil {
                // if already in list, don't add it
                if (find(nodeIDEdgeDict[n1]!, n2) != nil) {
                    return
                }
                n1ids = nodeIDEdgeDict[n1]! + [n2]
            } else {
                n1ids = [n2]
            }
            
            var n2ids: [Int] = []
            if nodeIDEdgeDict[n2] != nil {
                n2ids = nodeIDEdgeDict[n2]! + [n1]
            } else {
                n2ids = [n1]
            }
            
            nodeIDEdgeDict[n1] = n1ids
            nodeIDEdgeDict[n2] = n2ids
            
            /* add to node's list of neighbors */
            // technically not necessary since we'll always restart the program
            // after adding edges, so the neighbor lists will get lost anyway
            // and reset when the program starts in the "setUpEdges" function
            
            var n1neighbors: [Node] = []
            for id in n1ids {
                n1neighbors += [nodeIDdict[id]!]
            }
            
            var n2neighbors: [Node] = []
            for id in n2ids {
                n2neighbors += [nodeIDdict[id]!]
            }
            
            nodeIDdict[n1]!.neighbors = n1neighbors
            nodeIDdict[n2]!.neighbors = n2neighbors
            
            /* color clicked node red */
            
            sender.backgroundColor = UIColor.redColor()
            
            /*
            var d: Double = distance(n1.point, p2: n2.point)
            edgeWeightDict[Edge(n1: n1, n2: n2)] = d;
            */
            
            // prints list of edges so far
            var i = 0
            for (id, ids) in nodeIDEdgeDict {
                print("\(id): \(ids)")
                if i < nodeIDEdgeDict.count - 1 {
                    print(",\n")
                } else {
                    print("\n")
                }
                i++
            }
            println("\n\n\n\n")
            
        }
    }
    
    func bfs(source: Node, destination: Node)
    {
        var checked = [Node: Bool]()
        var loopBroken: Bool = false
        
        var parentsQueue = Queue()     //Create a queue
        //We check the source passed in as a parameter and marked it as checked
        checked[source] = true
        parentsQueue.enqueue(source)   //We add our parent to the queue
        
        
        while !parentsQueue.isEmpty()
        {
            
            //We hold the parentVertex or source in this variable
            var parentNode = parentsQueue.dequeue()

            for child in parentNode!.neighbors
            {
                if (checked[child] == nil)
                {
                    child.parent = parentNode!
                    checked[child] = true             //So we don't check this node again
                    parentsQueue.enqueue(child)       //We add the next parent to the queue
                    
                }
                if(child == destination){

                    loopBroken = true
                    break
                }
            }
            if (loopBroken) {
                break
            }
        }
    }

    func colorPath(lastNode: Node){
        previousPath = [Int]()
        var considerNode :Node = lastNode
        do{
            var btn: UIButton = nodeIDButtonDict[considerNode.id]!
            //btn.backgroundColor = UIColor.blueColor()
            btn.setImage(buttonImage, forState: .Normal)
            previousPath.append(considerNode.id)
            considerNode = considerNode.parent!
        } while (considerNode.parent != nil)
        //(nodeIDButtonDict[considerNode.id]!).backgroundColor = UIColor.blueColor()
        (nodeIDButtonDict[considerNode.id]!).setImage(buttonImage, forState: .Normal)
        previousPath.append(considerNode.id)
    }
    
    func distance(p1: CGPoint, p2: CGPoint) -> CGFloat {
        var x: CGFloat = pow(CGFloat(p1.x) - CGFloat(p2.x), 2)
        var y: CGFloat = pow(CGFloat(p1.y) - CGFloat(p2.y), 2)
        return sqrt(x + y)
    }
    
}
