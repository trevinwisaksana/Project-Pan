//
//  SCNNode+Movable.swift
//  SceneKit-Grid-Experiment
//
//  Created by Trevin Wisaksana on 16/05/2018.
//  Copyright © 2018 Trevin Wisaksana. All rights reserved.
//

import SceneKit

extension SCNNode {
    
    // MARK: - Child
    
    /// Appends a list of nodes as a child node.
    @objc
    func addChildNodes(_ nodes: [SCNNode]) {
        nodes.forEach { (node) in
            addChildNode(node)
        }
    }
    
    // MARK: - Opacity
    
    func hide() {
        opacity = 0
    }
    
    func unhide() {
        opacity = 1
    }
    
    // TODO: Make this savable
    
    // MARK: - Move
    
    private struct MovableState {
        static var isMovable = false
    }
    
    var isMovable: Bool {
        get {
            guard let movableState = objc_getAssociatedObject(self, &MovableState.isMovable) as? Bool else {
                return Bool()
            }
            
            return movableState
        }
        
        set(value) {
            objc_setAssociatedObject(self, &MovableState.isMovable, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Speech Bubble
    
    private struct SpeechBubbleState {
        static var willDisplaySpeechBubble = false
    }
    
    var willDisplaySpeechBubble: Bool {
        get {
            guard let speechBubbleState = objc_getAssociatedObject(self, &SpeechBubbleState.willDisplaySpeechBubble) as? Bool else {
                return Bool()
            }
            
            return speechBubbleState
        }
        
        set(value) {
            objc_setAssociatedObject(self, &SpeechBubbleState.willDisplaySpeechBubble, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Animations
    
    private struct ActionsState {
        static var actions = [SCNAction]()
    }
    
    public var actions: [SCNAction] {
        get {
            guard let cachedData = UserDefaults.standard.object(forKey: "\(name ?? "")-actions") as? Data
                else {
                    return []
            }
            
            do {
                let unarchivedData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(cachedData) as! [SCNAction]
                return unarchivedData
            } catch {
                fatalError("Failed to retrieve object catalog models.")
            }
        }
        set {
            do {
                let actionsData = try NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false)
                UserDefaults.standard.set(actionsData, forKey: "\(name ?? "")-actions")
            } catch {
                fatalError("Cannot save object catalog models.")
            }
            
            objc_setAssociatedObject(self, &ActionsState.actions, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func addAction(_ action: SCNAction, forKey key: Animation) {
        actions.append(action)
    }
    
    func removeAllActions() {
        actions.removeAll()
    }
    
    func playAllAnimations(completionHandler: (() -> Void)?) {
        var actionSequence = [SCNAction]()
        
        actions.forEach { (action) in
            switch action.animationType() {
            case .speechBubble:
                // 0.6 is the default duration of fade in and fade out animation
                Timer.scheduledTimer(timeInterval: State.animationDuration - 0.6, target: self, selector: #selector(didStartSpeechBubbleAnimationTimer(_:)), userInfo: nil, repeats: false)
                
                let customAction = SCNAction.customAction(duration: action.duration) { (node, time) in
                    let speechBubbleNode = node.childNode(withName: Constants.Node.speechBubble, recursively: true)
                    speechBubbleNode?.runAction(action)
                }
                
                actionSequence.append(customAction)
                
            default:
                break
            }
            
            actionSequence.append(action)
        }
        
        let sequence = SCNAction.sequence(actionSequence)
        runAction(sequence, completionHandler: completionHandler)
    }
    
    @objc
    private func didStartSpeechBubbleAnimationTimer(_ sender: Timer) {
        guard let speechBubbleNode = parent?.childNode(withName: Constants.Node.speechBubble, recursively: true) else {
            return
        }
        
        let fadeOutAnimation = SCNAction.fadeOut(duration: 0.15)
        fadeOutAnimation.timingMode = .linear
        speechBubbleNode.runAction(fadeOutAnimation) {
            speechBubbleNode.opacity = 0
        }
    }
    
    // MARK: - Duplicate
    
    public func duplicate() -> SCNNode {
        let newNode = clone()
        newNode.geometry = geometry?.copy() as? SCNGeometry
        newNode.geometry?.firstMaterial = geometry?.firstMaterial?.copy() as? SCNMaterial
        newNode.position = SCNVector3Zero
        
        return newNode
    }
    
    // MARK: - Utilities
    
    static func daeToSCNNode(filepath: String) -> SCNNode? {
        let scene = SCNScene(named: filepath)
        
        let childNodes = scene?.rootNode.childNodes
        
        for childNode in childNodes ?? [] {
            // TODO: Create a parameter to insert these names
            if childNode.name == "car" || childNode.name == "house" || childNode.name == "seaplane" || childNode.name == "Tree" {
                return childNode
            }
        }
        
        return nil
    }
    
}


// MARK: - NodeInspectorViewModel

extension SCNNode: NodeInspectorViewModel {
    
    // MARK: - Color
    
    public var color: UIColor {
        get {
            return geometry?.firstMaterial!.diffuse.contents as! UIColor
        }
    }
    
    private struct OriginalColorState {
        static var originalColor: UIColor?
    }
    
    public var originalColor: UIColor {
        get {
            guard let originalColorState = objc_getAssociatedObject(self, &OriginalColorState.originalColor) as? UIColor else {
                return UIColor.white
            }
            
            return originalColorState
        }
        
        set(value) {
            objc_setAssociatedObject(self, &OriginalColorState.originalColor, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func changeColor(to color: UIColor) {
        geometry?.firstMaterial?.diffuse.contents = color
        originalColor = color
    }
    
    /// Changes the node color to yellow to indicate it is selected
    public func highlight() {
        // Save the original color so it can be returned to normal when deselected
        originalColor = color
        
        geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
    }
    
    func createLineNode(fromPos origin: SCNVector3, toPos destination: SCNVector3, color: UIColor) -> SCNNode {
        let lineGeometry = line(fromVector: origin, toVector: destination)
        lineGeometry.firstMaterial?.diffuse.contents = color
        lineGeometry.firstMaterial?.lightingModel = .constant
        let lineNode = SCNNode(geometry: lineGeometry)
        
        let middleX = (destination.x + origin.x) / 2
        let middleY = (destination.y + origin.y) / 2
        let middleZ = (destination.z + origin.z) / 2
        
        lineNode.position = SCNVector3(middleX, middleY, middleZ)
        
        return lineNode
    }
    
    func line(fromVector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNBox {
        var xDifference = CGFloat(vector2.x - vector1.x)
        var yDifference = CGFloat(vector2.y - vector1.y)
        var zDifference = CGFloat(vector2.z - vector1.z)
        
        if xDifference.isZero {
            xDifference = 0.1
        }
        
        if yDifference.isZero {
            yDifference = 0.1
        }
        
        if zDifference.isZero {
            zDifference = 0.1
        }
        
        print("__________________")
        print("X: \(xDifference)")
        print("Y: \(yDifference)")
        print("Z: \(zDifference)")
        print("__________________")
        
        let lineGeometry = SCNBox(width: xDifference, height: yDifference, length: zDifference, chamferRadius: 0)
        return lineGeometry
    }
    
    
    // MARK: - Type
    
    public var type: NodeModel {
        get {
            switch geometry?.name {
            case NodeType.SCNPlane.string:
                return .plane
                
            case NodeType.SCNBox.string:
                return .box
                
            case NodeType.LVNCar.string:
                return .car
                
            case NodeType.LVNHouse.string:
                return .house
                
            case NodeType.SCNSphere.string:
                return .sphere
                
            case NodeType.LVNTree.string:
                return .tree
                
            default:
                return .default
            }
        }
    }
    
    // MARK: - Size
    
    public var length: CGFloat? {
        get {
            return CGFloat(boundingBox.max.y - boundingBox.min.y)
        }
    }
    
    public var width: CGFloat? {
        get {
            return CGFloat(boundingBox.max.x - boundingBox.min.x)
        }
    }
    
    // MARK: - Position
    
    public var angle: SCNVector3 {
        get {
            return eulerAngles
        }
    }
    
}
