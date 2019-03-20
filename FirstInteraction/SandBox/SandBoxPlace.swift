//
//  SandBoxPlace.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 15/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation
import SceneKit
import CoreMotion

typealias GridPosition = (line: Int, column: Int)

class SandBoxPlace: SCNNode {
    
    weak var sceneView: SCNView?
    
    private(set) var height: CGFloat
    private(set) var width: CGFloat
    private(set) var overlayDistance: Float
    private(set) var minimumNumberOfLines: Int
    
    var motion = CMMotionManager.init()
    var timer: Timer?
    
    private var addingPiece: PieceDescriptor?
    
    private var pieces: [SCNNode: PieceDescriptor] = [:]
    
    private var soundService = SoundsService.init()
    
    private var pieceIsFalling: Bool = false
    
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
        floor.firstMaterial?.diffuse.contents = UIColor.red
        
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
        placePlane.firstMaterial?.diffuse.contents = UIImage(named: "mountainMaterial")
        placePlane.firstMaterial?.isDoubleSided = true
        
        var placePlaneNode = SCNNode.init(geometry: placePlane)
        placePlaneNode.position = SCNVector3.zero
        placePlaneNode.position.y -= 1.3
        placePlaneNode.eulerAngles.x += Float.pi / 2.0
        
        placePlaneNode.runAction(SCNAction.sequence([
            SCNAction.wait(duration: 2.5),
            SCNAction.move(to: SCNVector3.init(0, -0.5, 0), duration: 0.5),
            SCNAction.run({ (_) in
                placePlaneNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
                placePlaneNode.physicsBody?.isAffectedByGravity = false

                placePlaneNode.physicsBody?.angularDamping = 1
                placePlaneNode.physicsBody?.friction = 1
                placePlaneNode.physicsBody?.restitution = 0
                placePlaneNode.categoryBitMask = CategoryMask.floor.rawValue
                placePlaneNode.categoryBitMask = CategoryMask.piece.rawValue
            }
        )]))
        
        return placePlaneNode
    }()
    
    lazy var overlayPlaneNode: SCNNode = {
        let overlayPlane = SCNPlane.init(width: self.width*2, height: self.height*2)
        overlayPlane.firstMaterial?.diffuse.contents = UIColor.blue
        overlayPlane.firstMaterial?.isDoubleSided = true
        
        let overlayPlaneNode = SCNNode.init(geometry: overlayPlane)
        overlayPlaneNode.position = SCNVector3.zero
        overlayPlaneNode.position.y += self.overlayDistance
        overlayPlaneNode.eulerAngles.x += Float.pi / 2.0
        overlayPlaneNode.opacity = 0.001
        
        return overlayPlaneNode
    }()
    
    lazy var floorOverlayPlaneNode: SCNNode = {
        let floorOverlayPlane = SCNPlane.init(width: self.width*2, height: self.height*2)
        floorOverlayPlane.firstMaterial?.diffuse.contents = UIColor.red
        floorOverlayPlane.firstMaterial?.isDoubleSided = true
        
        let floorOverlayPlaneNode = SCNNode.init(geometry: floorOverlayPlane)
        floorOverlayPlaneNode.position = SCNVector3.zero
        floorOverlayPlaneNode.eulerAngles.x += Float.pi / 2.0
        floorOverlayPlaneNode.opacity = 0.001
        
        return floorOverlayPlaneNode
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
        addChildNode(floorOverlayPlaneNode)
        
        sceneView.addGestureRecognizer(UILongPressGestureRecognizer.init(target: self, action: #selector(sceneWasLongPressed(longPressGestureRecognizer:))))
        sceneView.scene?.physicsWorld.gravity.y = -20
        sceneView.scene?.physicsWorld.contactDelegate = self
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func sceneWasLongPressed(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        let point = longPressGestureRecognizer.location(in: sceneView)
        
        guard let arHitResult = sceneView?.hitTest(point, options: [SCNHitTestOption.boundingBoxOnly: true, SCNHitTestOption.categoryBitMask: 2]).first,
              arHitResult.node != overlayPlaneNode && arHitResult.node != placePlaneNode,
              let pieceDescriptor = pieces[arHitResult.node],
              self.addingPiece == nil else {
            
            if addingPiece != nil {
                switch longPressGestureRecognizer.state {
            
                case .changed:
                    handlePieceDrag(inPoint: point)
                default:
                    pieceDragNeedEnd()
                }
            }
                
            return
        }
        
        if longPressGestureRecognizer.state == .began {
            pieceDescriptor.pieceNode.opacity = 0.5
            
            pieceDescriptor.pieceNode.physicsBody = nil
            self.addingPiece = pieceDescriptor
        }
    }
    
    func allPiecesOpacity(_ opacity: CGFloat) {
        for piece in pieces.values {
            piece.pieceNode.opacity = opacity
        }
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
        
        let pieceDescriptor = piece

        pieceDescriptor.pieceNode.scale = pieceDescriptor.scaleToReach(gridSize: gridSize)
        pieceDescriptor.pieceNode.opacity = 0.5
        pieceDescriptor.pieceNode.categoryBitMask = 2
        
        self.addingPiece = pieceDescriptor
    }
    
    func handlePieceDrag(inPoint point: CGPoint) {
        
        guard let arHitResult = sceneView?.hitTest(point, options: [SCNHitTestOption.boundingBoxOnly : true]).first,
              arHitResult.node == overlayPlaneNode || arHitResult.node == placePlaneNode || arHitResult.node == floorOverlayPlaneNode else {
                
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
            
            allPiecesOpacity(0.7)
        
            floorOverlayNode.runAction(SCNAction.move(to: overlayPoint, duration: 0.05))
            
            floorOverlayNode.opacity = 0.5
            
            if floorOverlayNode.parent == nil {
                sceneView?.scene?.rootNode.addChildNode(floorOverlayNode)
            }
            
            piecePoint.x -= Float(addingObjectRealSize.width/2)
            piecePoint.z -= Float(addingObjectRealSize.depth/2)
            piecePoint.y += Float(addingObjectRealSize.height/2)
            
            floorOverlayNode.scale = SCNVector3.init(addingObjectGridSize.width, 1, addingObjectGridSize.height)
            floorOverlayNode.pivot = SCNMatrix4MakeTranslation(0.5, 0, 0.5)
            
            addingNode.pieceNode.runAction(SCNAction.move(to: piecePoint, duration: 0.05))
            
            if addingNode.pieceNode.parent == nil {
                sceneView?.scene?.rootNode.addChildNode(addingNode.pieceNode)
            }
        }
    }
    
    func pieceDragNeedEnd() {
        
        soundService.falling()
        pieceIsFalling = true
        if let addingPiece = self.addingPiece {
            allPiecesOpacity(1)
            addingPiece.pieceNode.removeAllActions()
            addingPiece.pieceNode.position.y += 20
            
            let gridSize = self.gridSize
            let addingPieceSize = addingPiece.scaledSize(gridSize: gridSize)

            let physicsGeometry = SCNBox.init(
                width: addingPieceSize.width - 0.1,
                height: addingPieceSize.height,
                length: addingPieceSize.depth - 0.1,
                chamferRadius: 0
            )
            
            let physicsShape = SCNPhysicsShape.init(geometry: physicsGeometry, options: nil)
            
            addingPiece.pieceNode.physicsBody = SCNPhysicsBody.init(type: .dynamic, shape: physicsShape)
            addingPiece.pieceNode.physicsBody?.angularDamping = 1
            addingPiece.pieceNode.physicsBody?.friction = 1
            addingPiece.pieceNode.physicsBody?.restitution = 0
            addingPiece.pieceNode.opacity = 1
            addingPiece.pieceNode.physicsBody?.categoryBitMask = CategoryMask.piece.rawValue
            addingPiece.pieceNode.physicsBody?.contactTestBitMask = CategoryMask.floor.rawValue | CategoryMask.piece.rawValue
            
            self.pieces[addingPiece.pieceNode] = addingPiece
            
            self.addingPiece = nil
        }
        
        floorOverlayNode.opacity = 0
    }
    
    func needAddSpinner(spinnerNode: SCNNode, direction: SpinnerDirection, completion: @escaping () -> ()) {
        
        spinnerNode.physicsBody = SCNPhysicsBody.init(type: .dynamic, shape: nil)
        spinnerNode.physicsBody?.isAffectedByGravity = true

        spinnerNode.eulerAngles = SCNVector3.zero
        spinnerNode.physicsBody?.applyTorque(SCNVector4.init(0, 1, 0, 10000), asImpulse: false)
        
        let baseAnimationTime = 0.3
        
        var groupedActions: [SCNAction] = [
            SCNAction.move(by: SCNVector3.init(-spinnerNode.position.x, -spinnerNode.position.y + 10, -spinnerNode.position.z), duration: baseAnimationTime * 2)
        ]
        
        switch direction {
        case .left:
            groupedActions.append(contentsOf: [
                SCNAction.move(by: SCNVector3.init(0, 3, 0), duration: baseAnimationTime),
                SCNAction.sequence([
                    SCNAction.wait(duration: baseAnimationTime),
                    SCNAction.move(by: SCNVector3.init(0, -3, 0), duration: baseAnimationTime)
                ]),
                SCNAction.move(by: SCNVector3.init(3, 0, 0), duration: baseAnimationTime),
                SCNAction.sequence([
                    SCNAction.wait(duration: baseAnimationTime),
                    SCNAction.move(by: SCNVector3.init(-3, 0, 0), duration: baseAnimationTime)
                ])]
            )
        case .right:
            groupedActions.append(contentsOf: [
                SCNAction.move(by: SCNVector3.init(0, 3, 0), duration: baseAnimationTime),
                SCNAction.sequence([
                    SCNAction.wait(duration: baseAnimationTime),
                    SCNAction.move(by: SCNVector3.init(0, -3, 0), duration: baseAnimationTime)
                ]),
                SCNAction.move(by: SCNVector3.init(-3, 0, 0), duration: baseAnimationTime),
                SCNAction.sequence([
                    SCNAction.wait(duration: baseAnimationTime),
                    SCNAction.move(by: SCNVector3.init(3, 0, 0), duration: baseAnimationTime)
                ])]
            )
        case .middle:
            groupedActions.append(contentsOf: [
                SCNAction.move(by: SCNVector3.init(0, 3, 0), duration: baseAnimationTime),
                SCNAction.sequence([
                    SCNAction.wait(duration: baseAnimationTime),
                    SCNAction.move(by: SCNVector3.init(0, -3, 0), duration: baseAnimationTime)
                ])]
            )
        }
        
        spinnerNode.runAction(
            SCNAction.sequence([
                SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.1),
                SCNAction.group(groupedActions),
                SCNAction.run({ (_) in
                    completion()
                })
            ])
        )
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            let randomX = Float.random(in: -5..<5)
            let randomZ = Float.random(in: -5..<5)
            
            let randomForce = SCNVector3.init(randomX, 0, randomZ)
            
            spinnerNode.physicsBody?.velocity = randomForce
        }
    }    
}

extension SandBoxPlace: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
       
        if pieceIsFalling {
            soundService.didFall()
            pieceIsFalling = false
        }
    }
}
