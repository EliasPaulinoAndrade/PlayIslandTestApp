//
//  SandBoxPlace.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 15/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation
import SceneKit

class SandBoxPlace: SCNNode {
    
    weak var sceneView: SCNView?
    
    private(set) var height: CGFloat
    private(set) var width: CGFloat
    private(set) var overlayDistance: Float
    
    private var addingPiece: SCNNode?
    
    private var floorOverlayNode: SCNNode = {
        let floor = SCNCylinder.init(radius: 1, height: 0.001)
        floor.firstMaterial?.diffuse.contents = UIColor.green
        
        let floorNode = SCNNode.init(geometry: floor)
        floorNode.pivot = SCNMatrix4MakeTranslation(0, 0, -1)
        
        
        
        return floorNode
    }()
    
    lazy var placePlaneNode: SCNNode = {
        let placePlane = SCNBox.init(width: 10, height: 10, length: 1, chamferRadius: 0)
        placePlane.firstMaterial?.diffuse.contents = UIColor.red
        placePlane.firstMaterial?.isDoubleSided = true
        
        let placePlaneNode = SCNNode.init(geometry: placePlane)
        placePlaneNode.position = SCNVector3.zero
        placePlaneNode.eulerAngles.x += Float.pi / 2.0
        
        placePlaneNode.pivot = SCNMatrix4MakeTranslation(0, 0, -0.5)
        
        placePlaneNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        placePlaneNode.physicsBody?.isAffectedByGravity = false
        
        placePlaneNode.physicsBody?.angularDamping = 1
        placePlaneNode.physicsBody?.friction = 1
        placePlaneNode.physicsBody?.restitution = 0
        
        return placePlaneNode
    }()
    
    lazy var overlayPlaneNode: SCNNode = {
        let overlayPlane = SCNPlane.init(width: 10, height: 10)
        overlayPlane.firstMaterial?.diffuse.contents = UIColor.blue
        overlayPlane.firstMaterial?.isDoubleSided = true
        
        let overlayPlaneNode = SCNNode.init(geometry: overlayPlane)
        overlayPlaneNode.position = SCNVector3.zero
        overlayPlaneNode.position.y += self.overlayDistance
        overlayPlaneNode.eulerAngles.x += Float.pi / 2.0
        overlayPlaneNode.opacity = 0.001
        
        return overlayPlaneNode
    }()
    
    init(withHeight height: CGFloat, width: CGFloat, andOverlayDistance overlayDistance: Float, sceneView: SCNView) {
        
        self.height = height
        self.width = width
        self.overlayDistance = overlayDistance
        self.sceneView = sceneView
        
        super.init()
        
        addChildNode(placePlaneNode)
        addChildNode(overlayPlaneNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pieceDragNeedBegan(withPiece piece: SCNNode) {
        self.addingPiece = piece
        
        let physicsGeometry = SCNBox.init(width: 1, height: 0.01, length: 1, chamferRadius: 0)
        let physicsShape = SCNPhysicsShape.init(geometry: physicsGeometry, options: nil)
        piece.physicsBody = SCNPhysicsBody.init(type: .dynamic, shape: physicsShape)
        piece.physicsBody?.isAffectedByGravity = false
        
        piece.physicsBody?.angularDamping = 1
        piece.physicsBody?.friction = 1
        piece.physicsBody?.restitution = 0
        
    }
    
    func handlePieceDrag(inPoint point: CGPoint) {
        guard let arHitResult = sceneView?.hitTest(point, options: [SCNHitTestOption.boundingBoxOnly : true]).first,
              arHitResult.node == overlayPlaneNode || arHitResult.node == placePlaneNode else {
                
            return
        }

        let piecePoint = arHitResult.worldCoordinates
        var overlayPoint = piecePoint
        
        if arHitResult.node == overlayPlaneNode {
            overlayPoint.y -= self.overlayDistance - 0.002
        } else {
            overlayPoint.y += 0.001
        }
        
        floorOverlayNode.position = overlayPoint
        floorOverlayNode.opacity = 0.5
        
        if floorOverlayNode.parent == nil {
            sceneView?.scene?.rootNode.addChildNode(floorOverlayNode)
        }
        
        if let addingNode = self.addingPiece {
            addingNode.position = piecePoint
            addingNode.position.z += 1
            
            if addingNode.parent == nil {
                sceneView?.scene?.rootNode.addChildNode(addingNode)
            }
        }
    }
    
    func pieceDragNeedEnd() {
        addingPiece?.physicsBody?.isAffectedByGravity = true
        floorOverlayNode.opacity = 0
    }
}

