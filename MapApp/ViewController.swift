import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: UIImageView!
    
    // set panning boundaries so user can't pan too far off image
    var topBoundary: CGFloat = 0
    var leftBoundary: CGFloat = 0
    var rightBoundary: CGFloat = 375
    var bottomBoundary: CGFloat = 710

    // get stored nodes and edges for pathfinding
    var nodeIDdict = Graph().nodes
    var nodeIDEdgeDict = Graph().edges
    
    // map nodes with corresponding UI buttons
    var nodeIDButtonDict = [Int: UIButton]()
    var buttonNodeIDDict = [UIButton: Int]()
    
    var buttonImage = UIImage(named: "button.png")
    var transparentButtonImage = UIImage(named: "button_transparent.png")
    
    var previouslyClickedNodeID: Int? = nil
    
    var previousPath = [Int]()
    
    // click counter to track whether both source and dest nodes have been clicked
    var clickCount: Int = 0
    
    // ids of source and dest nodes for pathfinding
    var srcNodeID: Int = 0
    var destNodeID: Int = 0
    
    // dev tool
    // when true, removes a node when node is clicked
    // when false, adds an edge when two nodes are clicked
    var removeNodeOrAddEdge: Bool = false;

    /* getting user's current location */
    
    let locationManager = CLLocationManager()
    
    var latitude :CLLocationDegrees = 42.312521
    var longitude :CLLocationDegrees = -72.639737
    
    var initialLat :CGFloat = 42.312521
    var initialLong :CGFloat = -72.639737
    
    var coordx :CGFloat =  235.839038689627
    var coordy :CGFloat = 608.919720229753
    
    let xChangeWithLongitude :CGFloat = 33944.3292149
    let yChangeWithLatitude : CGFloat = 608.919720229753
    
    
    
    // ------------------------
    // LOCATION
    // not working
    // ------------------------
    
    /* NOT WORKING */
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {

        longitude = manager.location.coordinate.longitude
        latitude = manager.location.coordinate.latitude
        
        var changeInLatitude: CGFloat = initialLat - 42.312521
        var changeInLongitude: CGFloat = initialLong - (-72.639737)
        
        coordx = coordx + (changeInLongitude * xChangeWithLongitude)
        coordy = coordy + (changeInLatitude * yChangeWithLatitude)
        
        let userLocation = Node(point: CGPoint(x: coordx,y:coordy))
        
        // draw user location on map
        let button = UIButton.buttonWithType(UIButtonType.System) as UIButton
        button.frame = CGRect(x: userLocation.point.x-2.5, y: userLocation.point.y-2.5, width:5, height:5)
        button.backgroundColor = UIColor.redColor()
        mapView.addSubview(button)
    }
    
    
    
    // ------------------------
    // SETUP
    // ------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // creates node and edge objects stored in Graph.swift
        setUpNodes()
        setUpEdges()
        
        // sets ids inside nodes
        for id in nodeIDdict.keys {
            var thisNode :Node = nodeIDdict[id]!
            thisNode.id = id
        }
        
        /* NOT WORKING
        attempts to draw user location on map
        */
        
        // get user location
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        let userLocation = Node(point: CGPoint(x: coordx,y:coordy))
        
        // draw location on map
        let button = UIButton.buttonWithType(UIButtonType.System) as UIButton
        button.frame = CGRect(x: userLocation.point.x-2.5, y: userLocation.point.y-2.5, width:5, height:5)
        mapView.addSubview(button)
    }
    
    func setUpNodes() {
        for i in nodeIDdict.keys {
            createButtonForNode(nodeIDdict[i]!,id: i)
        }
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
    
    func createButtonForNode(node: Node, id: Int) {
        let button = UIButton.buttonWithType(UIButtonType.System) as UIButton
        button.frame = CGRect(x: node.point.x-1.25, y: node.point.y-1.25, width:2.5, height:2.5)
        
        /* dev tool disabled
        // clicking on a node either removes it or adds an edge to prev clicked node
        if (removeNodeOrAddEdge) {
            button.addTarget(self, action: "removeNode:", forControlEvents: UIControlEvents.TouchUpInside)
        } else {
            button.addTarget(self, action: "createEdge:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        */
        
        button.addTarget(self, action: "trackClickedNode:", forControlEvents: UIControlEvents.TouchUpInside)
        
        // for debugging
        //button.addTarget(self, action: "printID:", forControlEvents: UIControlEvents.TouchUpInside)
        
        mapView.addSubview(button)
        
        // add button with id
        nodeIDButtonDict[id] = button
        buttonNodeIDDict[button] = id
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // ------------------------
    // TOUCH INTERACTION
    // ------------------------
    
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
        
        /* dev tool
        // create node and button on click
        var id = nodeIDButtonDict.count
        createButtonForNode(node, id: id)
        nodeIDdict[id] = node
        printNodes()
        */
        
        var closestButton: UIButton = nodeIDButtonDict[findClosestNode(node)]!
        
        pathfinding(closestButton)
        
        // resets previously clicked node
        previouslyClickedNodeID = nil;
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
    
    func trackClickedNode(sender: UIButton!) {
        pathfinding(sender)
    }
    
    
    
    // ------------------------
    // PATHFINDING
    // ------------------------
    
    func pathfinding(sender: UIButton) {
        // if only one node has been clicked
        if(clickCount % 2 == 0){
            srcNodeID = buttonNodeIDDict[sender]!
            
            undrawPrevPath()
            
            // color the clicked node
            sender.setImage(buttonImage, forState: .Normal)
        }
            // else, color the path between the two nodes
        else {
            destNodeID = buttonNodeIDDict[sender]!
            let srcNode: Node = nodeIDdict[srcNodeID]!
            let destNode: Node = nodeIDdict[destNodeID]!
            findAndColorPath(srcNode, destNode: destNode)
        }
        
        // update click count
        clickCount++
    }
    
    func bfs(source: Node, destination: Node) {
        var checked = [Node: Bool]()
        var loopBroken: Bool = false
        var parentsQueue = Queue()

        // mark first node as visited
        checked[source] = true

        parentsQueue.enqueue(source)
        
        while !parentsQueue.isEmpty() {
            //We hold the parentVertex or source in this variable
            var parentNode = parentsQueue.dequeue()
            
            for child in parentNode!.neighbors {
                if (checked[child] == nil) {
                    child.parent = parentNode!
                    // don't check node again
                    checked[child] = true
                    
                    parentsQueue.enqueue(child)
                }
                if(child == destination) {
                    loopBroken = true
                    break
                }
            }
            if (loopBroken) {
                break
            }
        }
    }
    
    func findAndColorPath(srcNode: Node, destNode:Node){
        self.bfs(srcNode, destination: destNode)
        srcNode.parent = nil
        self.colorPath(destNode)
    }
    
    func colorPath(lastNode: Node){
        previousPath = [Int]()
        var considerNode: Node = lastNode
        
        // follow each node's parent, color them
        do {
            var btn: UIButton = nodeIDButtonDict[considerNode.id]!
            btn.setImage(buttonImage, forState: .Normal)
            previousPath.append(considerNode.id)
            considerNode = considerNode.parent!
        } while (considerNode.parent != nil)
        
        (nodeIDButtonDict[considerNode.id]!).setImage(buttonImage, forState: .Normal)
        previousPath.append(considerNode.id)
    }
    
    func distance(p1: CGPoint, p2: CGPoint) -> CGFloat {
        var x: CGFloat = pow(CGFloat(p1.x) - CGFloat(p2.x), 2)
        var y: CGFloat = pow(CGFloat(p1.y) - CGFloat(p2.y), 2)
        return sqrt(x + y)
    }
    
    func undrawPrevPath() {
        for nodeID in previousPath {
            var btn: UIButton = nodeIDButtonDict[nodeID]!
            btn.setImage(transparentButtonImage, forState: .Normal)
        }
    }
    
    
    
    // ------------------------
    // DEV TOOLS
    // disabled for user version
    // ------------------------
    
    // dev tool
    func printID(sender: UIButton!) {
        println(buttonNodeIDDict[sender]!)
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
        if (previouslyClickedNodeID == nil) {
            previouslyClickedNodeID = buttonNodeIDDict[sender]
        }
        // else, create edge between nodes
        else {
            var n1: Int = buttonNodeIDDict[sender]!
            var n2: Int = previouslyClickedNodeID!
            
            previouslyClickedNodeID = nil;
            
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

            sender.backgroundColor = UIColor.redColor()
            
            printEdges()
        }
    }
    
    // dev tool
    func printEdges() {
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
    
    // dev tool
    func printNodes() {
        // prints list of nodes in code friendly format
        var i = -1
        for id in nodeIDButtonDict.keys {
            var point: CGPoint = nodeIDdict[id]!.point
            i++
            print("\(i): Node(point: CGPoint(x: \(point.x), y: \(point.y)))")
            if (i < nodeIDdict.count-1) {
                print(",\n")
            } else {
                print("\n")
            }
        }
        println("\n")
    }
    
}
