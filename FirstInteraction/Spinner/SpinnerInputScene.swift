//
//  SpinnerInputScene.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 18/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation
import SpriteKit

class SpinnerInputScene: SKScene {
    
    weak var spinnerInput: SpinnerInput?
    
    var beginPoint: CGPoint?
    var lastPoint: CGPoint?
    var lastPointTime: CFAbsoluteTime?
    var soundService = SoundsService()
    
    lazy var wireButton: SKSpriteNode = {
        let texture = SKTexture.init(image: UIImage.init(named: "runSpinnerButton") ?? UIImage.init())
        let wireButton = SKSpriteNode.init(texture: texture)
        
        wireButton.scale(to: CGSize.init(width: 85, height: 85))

        wireButton.physicsBody = SKPhysicsBody.init(circleOfRadius: 40)
        wireButton.physicsBody?.affectedByGravity = false
        wireButton.physicsBody?.isDynamic = false
        wireButton.physicsBody?.collisionBitMask = 0
        
        return wireButton
    }()
    
    lazy var placeHolderButton: SKShapeNode = {
        let placeHolderButton = SKShapeNode.init(circleOfRadius: 40)
        
        placeHolderButton.physicsBody = SKPhysicsBody.init(circleOfRadius: 40)
        placeHolderButton.physicsBody?.affectedByGravity = false
        placeHolderButton.physicsBody?.isDynamic = false
        placeHolderButton.physicsBody?.collisionBitMask = 0
        
        return placeHolderButton
    }()
    
    var wireNodes: [SKNode] = []
    
    var beginJoint: SKPhysicsJointPin?
    var endJoint: SKPhysicsJointPin?
    
    override func sceneDidLoad() {
        
        addChild(placeHolderButton)
        addChild(wireButton)
        
        physicsWorld.gravity.dy = -40
    }
    
    override func didMove(to view: SKView) {

        backgroundColor = UIColor.clear
        view.backgroundColor = UIColor.clear
        if let view = self.view {
            
            wireButton.position = CGPoint.init(x: 0, y: -view.frame.height/2 + 50)
            placeHolderButton.position = CGPoint.init(x: 20, y: -view.frame.height/2 - 80)
        }
    }
    
    func sizeOfParentChanged() {
        if let view = self.view {
            
            wireButton.position = CGPoint.init(x: 0, y: -view.frame.height/2 + 50)
            placeHolderButton.position = CGPoint.init(x: -40, y: -view.frame.height/2 - 80)
            
            if wireNodes.count == 0 {
                createWire()
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let point = touches.first?.location(in: self) else {
            return
        }
        
        self.beginPoint = point
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.wireButton.isHidden = true
        
        guard let point = touches.first?.location(in: self),
              let spinnerInput = spinnerInput, spinnerInput.thereIsASpinner == true else {
            return
        }
        
        self.lastPoint = point
        self.lastPointTime = CFAbsoluteTimeGetCurrent()
        
        wireButton.position = point
        self.spinnerInput?.spinnerDelegate?.needRotateSpinner()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.wireButton.isHidden = false
        
        guard let spinnerInput = spinnerInput,
              spinnerInput.thereIsASpinner == true,
              let point = touches.first?.location(in: self),
              let beginPoint = self.beginPoint,
              point != beginPoint
              /*,let lastPoint = self.lastPoint,
              let lastPointTime = self.lastPointTime*/ else {
                
            return
        }
        
//        let currentTime = CFAbsoluteTimeGetCurrent()
//        let distance = lastPoint.distance(to: point)
//        let timeDifference = currentTime - lastPointTime
//
//        let velocity = distance / CGFloat(timeDifference)
        
//        print(distance, timeDifference)
        
        if point.x < beginPoint.x - 40 {
            self.spinnerInput?.spinnerDelegate?.needAddSpinner(to: .left)
        } else if point.x > beginPoint.x + 40{
            self.spinnerInput?.spinnerDelegate?.needAddSpinner(to: .right)
        } else {
            self.spinnerInput?.spinnerDelegate?.needAddSpinner(to: .middle)
        }
        self.spinnerInput?.spinnerDelegate?.needDequeueSpinner()
        fallWire()
        
        if let endJoint = self.endJoint {
            physicsWorld.remove(endJoint)
        }
        
        if let beginJoint = self.beginJoint {
            physicsWorld.remove(beginJoint)
        }
        
        
        if let view = self.view {
            wireButton.position = CGPoint.init(x: 0, y: -view.frame.height/2 + 50)
        }
        
        spinnerInput.thereIsASpinner = false
        
        soundService.didLauchSpinner()
    }
    
    func fallWire() {
        for wireNode in wireNodes {
            wireNode.physicsBody?.affectedByGravity = true
        }
    }
    
    func resetWire() {
        guard let firstWireNode = wireNodes.first, let lastWireNode = wireNodes.last else {
            return
        }
        
        for wireNode in wireNodes {
            wireNode.position = wireButton.position
            wireNode.physicsBody?.velocity = CGVector.init(dx: 0, dy: 0)
        }
        
        let beginPinJoint = SKPhysicsJointPin.joint(withBodyA: placeHolderButton.physicsBody!, bodyB: firstWireNode.physicsBody!, anchor: placeHolderButton.position)
        
        beginPinJoint.rotationSpeed = 10000
        physicsWorld.add(beginPinJoint)
        self.beginJoint = beginPinJoint
        
        let pinJoint = SKPhysicsJointPin.joint(withBodyA: lastWireNode.physicsBody!, bodyB: wireButton.physicsBody!, anchor: CGPoint.init(x: lastWireNode.frame.midX, y: lastWireNode.frame.midY))
        
        pinJoint.rotationSpeed = 10000
        physicsWorld.add(pinJoint)
        self.endJoint = pinJoint
        
    }
    
    func createWire() {
        var wireNodes: [SKNode] = []
        
//        var yBase: CGFloat = 0.0
        
        for wireNodeIndex in 0..<200 {
            let texture = SKTexture.init(image: UIImage.init(named: "wire")!)
            let wireNode = SKSpriteNode.init(texture: texture)
            
//            wireNode.color = UIColor.black
            
            wireNode.position = wireButton.position
            
            wireNode.physicsBody = SKPhysicsBody.init(circleOfRadius: 1)
//            wireNode.fillColor = UIColor.black
//            wireNode.strokeColor = UIColor.clear
            wireNode.physicsBody?.collisionBitMask = 0
            wireNode.zPosition = CGFloat(-wireNodeIndex)
            wireNode.physicsBody?.affectedByGravity = true
            
//            wireNode.position.y += yBase
            
            
            addChild(wireNode)
            
            if let lastWire = wireNodes.last {
                let pinJoint = SKPhysicsJointPin.joint(withBodyA: lastWire.physicsBody!, bodyB: wireNode.physicsBody!, anchor: lastWire.position)
                
                pinJoint.rotationSpeed = 10000
                physicsWorld.add(pinJoint)
                
                
//                yBase -= 5
            } else {
                let pinJoint = SKPhysicsJointPin.joint(withBodyA: placeHolderButton.physicsBody!, bodyB: wireNode.physicsBody!, anchor: placeHolderButton.position)

                pinJoint.rotationSpeed = 10000
                physicsWorld.add(pinJoint)
                self.beginJoint = pinJoint

            }
            
            wireNodes.append(wireNode)
        }
        
        if let lastWire = wireNodes.last {
            let pinJoint = SKPhysicsJointPin.joint(withBodyA: lastWire.physicsBody!, bodyB: wireButton.physicsBody!, anchor: CGPoint.init(x: lastWire.frame.midX, y: lastWire.frame.midY))
            
            pinJoint.rotationSpeed = 10000
            physicsWorld.add(pinJoint)
            self.endJoint = pinJoint
        }
        
        self.wireNodes = wireNodes
    }
}
