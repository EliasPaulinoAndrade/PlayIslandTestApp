//
//  SandBoxPlace.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 15/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation
import SceneKit

typealias GridPosition = (line: Int, column: Int)

class SandBoxPlace: SCNNode {
    
    weak var sceneView: SCNView?
    
    private(set) var height: CGFloat
    private(set) var width: CGFloat
    private(set) var overlayDistance: Float
    private(set) var minimumOfLines: Int
    
    private var addingPiece: SCNNode?
    
    lazy private var floorOverlayNode: SCNNode = {
        let floor = SCNCylinder.init(radius: gridSize/2, height: 0.001)
        floor.firstMaterial?.diffuse.contents = UIColor.green
        
        let floorNode = SCNNode.init(geometry: floor)
        floorNode.pivot = SCNMatrix4MakeTranslation(0, 0, -1)
        
        return floorNode
    }()
    
    var gridSize: CGFloat {
        if height > width {
            return width/CGFloat(minimumOfLines)
        }
        return height/CGFloat(minimumOfLines)
    }
    
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
    
    init(withHeight height: CGFloat, width: CGFloat, overlayDistance: Float, minimumOfLines: Int, andSceneView sceneView: SCNView) {
        
        self.height = height
        self.width = width
        self.overlayDistance = overlayDistance
        self.sceneView = sceneView
        self.minimumOfLines = minimumOfLines
        
        super.init()
        
        addChildNode(placePlaneNode)
        addChildNode(overlayPlaneNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func gridPosition(forPosition position: CGPoint) -> GridPosition {
        
        let gridLine = Int(position.x/gridSize)
        let gridColumn = Int(position.y/gridSize)
        
        return (line: gridLine, column: gridColumn)
    }
    
    func positionFor(gridPosition: GridPosition) -> CGPoint {
        let gridPositionX = gridSize * CGFloat(gridPosition.line)
        let gridPositionY = gridSize * CGFloat(gridPosition.column)
        
        return CGPoint.init(x: gridPositionX, y: gridPositionY)
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

        var piecePoint = arHitResult.worldCoordinates
        
        let pieceReal2DPoint = positionFor(gridPosition: gridPosition(forPosition: CGPoint.init(x: CGFloat(piecePoint.x), y: CGFloat(piecePoint.z))))
        
        piecePoint.x = Float(pieceReal2DPoint.x)
        piecePoint.z = Float(pieceReal2DPoint.y)
        
        var overlayPoint = piecePoint
        
        if arHitResult.node == overlayPlaneNode {
            overlayPoint.y -= self.overlayDistance - 0.002
        } else {
            overlayPoint.y += 0.001
        }
        
        floorOverlayNode.position = overlayPoint
        floorOverlayNode.opacity = 0.5
        
//        print(gridPosition(forPosition: CGPoint.init(x: CGFloat(piecePoint.x), y: CGFloat(piecePoint.z))))
        
        
        
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

