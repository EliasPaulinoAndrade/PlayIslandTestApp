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
    private(set) var minimumNumberOfLines: Int
    
    private var addingPiece: PieceDescriptor?
    
    lazy private(set) var heights: [[Float]] = {
        var heights = [Array<Float>]()
        for lineIndex in 0..<minimumNumberOfLines {
            heights.append(Array<Float>())
            for columnIndex in 0..<numberOfColumns {
                heights[lineIndex].append(0)
            }
        }
        return heights
    }()
    
    lazy private var floorOverlayNode: SCNNode = {
        let gridSize = self.gridSize
        let floor = SCNBox.init(width: gridSize, height: 0.001, length: gridSize, chamferRadius: 0)
        floor.firstMaterial?.diffuse.contents = UIColor.green
        
        let floorNode = SCNNode.init(geometry: floor)
        
        return floorNode
    }()
    
    var gridSize: CGFloat {
        if height > width {
            return width/CGFloat(minimumNumberOfLines)
        }
        return height/CGFloat(minimumNumberOfLines)
    }
    
    lazy private(set) var numberOfColumns: Int = {
        let gridSize = self.gridSize
        
        if height > width {
            return Int(height/gridSize)
        }
        return Int(width/gridSize)
    }()
    
    lazy var placePlaneNode: SCNNode = {
        let placePlane = SCNBox.init(width: self.width, height: self.height, length: 1, chamferRadius: 0)
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
        let overlayPlane = SCNPlane.init(width: self.width, height: self.height)
        overlayPlane.firstMaterial?.diffuse.contents = UIColor.blue
        overlayPlane.firstMaterial?.isDoubleSided = true
        
        let overlayPlaneNode = SCNNode.init(geometry: overlayPlane)
        overlayPlaneNode.position = SCNVector3.zero
        overlayPlaneNode.position.y += self.overlayDistance
        overlayPlaneNode.eulerAngles.x += Float.pi / 2.0
        overlayPlaneNode.opacity = 0.2
        
        return overlayPlaneNode
    }()
    
    init(withHeight height: CGFloat, width: CGFloat, overlayDistance: Float, minimumOfLines: Int, andSceneView sceneView: SCNView) {
        
        self.height = height
        self.width = width
        self.overlayDistance = overlayDistance
        self.sceneView = sceneView
        self.minimumNumberOfLines = minimumOfLines
        
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
    
    func pieceDragNeedBegan(withPiece piece: PieceDescriptor) {
        
        var pieceDescriptor = piece

        let pieceOwnerNode = SCNNode.init()
        
        pieceOwnerNode.addChildNode(pieceDescriptor.pieceNode)
        
        pieceDescriptor.pieceNode = pieceOwnerNode
        
        pieceDescriptor.pieceNode.pivot = SCNMatrix4MakeTranslation(
            0,
            Float(pieceDescriptor.pieceRealSize.height/2),
            0)
        pieceDescriptor.pieceNode.scale = pieceDescriptor.scaleToReach(gridSize: gridSize)
        pieceDescriptor.pieceNode.opacity = 0.5
        
        self.addingPiece = pieceDescriptor
    }
    
    func handlePieceDrag(inPoint point: CGPoint) {
        guard let arHitResult = sceneView?.hitTest(point, options: [SCNHitTestOption.boundingBoxOnly : true]).first,
              arHitResult.node == overlayPlaneNode || arHitResult.node == placePlaneNode else {
                
            return
        }

        if let addingNode = self.addingPiece {
            
            var piecePoint = arHitResult.worldCoordinates
            
            let pieceReal2DPoint = positionFor(gridPosition: gridPosition(forPosition: CGPoint.init(x: CGFloat(piecePoint.x), y: CGFloat(piecePoint.z))))
            
            let addingObjectGridSize = addingNode.pieceGridSize
            let addingObjectRealSize = addingNode.scaledSize(gridSize: gridSize)
            
            piecePoint.x = Float(pieceReal2DPoint.x)
            piecePoint.z = Float(pieceReal2DPoint.y)
            
            var overlayPoint = piecePoint
            
            if arHitResult.node == overlayPlaneNode {
                overlayPoint.y -= self.overlayDistance - 0.002
            } else {
                overlayPoint.y += 0.002
            }
            
            overlayPoint.x += Float(CGFloat(addingNode.pieceGridSize.width - 1) * gridSize)
            overlayPoint.z += Float(CGFloat(addingNode.pieceGridSize.height - 1) * gridSize)
            
            floorOverlayNode.runAction(SCNAction.move(to: overlayPoint, duration: 0.05))
            
            floorOverlayNode.opacity = 0.5
            
            if floorOverlayNode.parent == nil {
                sceneView?.scene?.rootNode.addChildNode(floorOverlayNode)
            }
            
            piecePoint.x -= Float(addingObjectRealSize.width/2)
            piecePoint.z -= Float(addingObjectRealSize.depth/2)
            piecePoint.y += Float(addingObjectRealSize.height/2)
            
            let floorRealSizeX = gridSize * CGFloat(addingObjectGridSize.width)
            let floorRealSizeY = gridSize * CGFloat(addingObjectGridSize.height)
            
            floorOverlayNode.scale = SCNVector3.init(addingObjectGridSize.width, 1, addingObjectGridSize.height)
            floorOverlayNode.pivot = SCNMatrix4MakeTranslation(Float(floorRealSizeX/2), 0, Float(floorRealSizeY/2))
            
            addingNode.pieceNode.runAction(SCNAction.move(to: piecePoint, duration: 0.05))
            
            if addingNode.pieceNode.parent == nil {
                sceneView?.scene?.rootNode.addChildNode(addingNode.pieceNode)
            }
        }
    }
    
    func pieceDragNeedEnd() {
        if let addingPiece = self.addingPiece {
            let gridSize = self.gridSize
            let addingPieceSize = addingPiece.scaledSize(gridSize: gridSize)
            
//            addingPiece.pieceNode.pivot = SCNMatrix4MakeTranslation(-Float(addingPieceSize.width/2), Float(addingPieceSize.height/2), -Float(addingPieceSize.depth/2))

            
            let physicsGeometry = SCNBox.init(width: addingPieceSize.width-0.1, height: addingPieceSize.height, length: addingPieceSize.depth-0.1, chamferRadius: 0)
            let physicsShape = SCNPhysicsShape.init(geometry: physicsGeometry, options: nil)
            
            addingPiece.pieceNode.physicsBody = SCNPhysicsBody.init(type: .dynamic, shape: physicsShape)
            
            addingPiece.pieceNode.physicsBody?.angularDamping = 1
            addingPiece.pieceNode.physicsBody?.friction = 1
            addingPiece.pieceNode.physicsBody?.restitution = 0
            addingPiece.pieceNode.opacity = 1
            
//            addingPiece.pieceNode.pivot = SCNMatrix4MakeTranslation(Float(addingPieceSize.width/2), -Float(addingPieceSize.height/2), Float(addingPieceSize.depth/2))

        }
        
        floorOverlayNode.opacity = 0
    }
}

