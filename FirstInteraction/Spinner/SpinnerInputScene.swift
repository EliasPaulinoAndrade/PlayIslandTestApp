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
    
    lazy var wireButton: SKShapeNode = {
        let wireButton = SKShapeNode.init(circleOfRadius: 40)
        
        wireButton.fillColor = UIColor.white
        wireButton.strokeColor = UIColor.init(named: "menuBorder") ?? UIColor.clear
        wireButton.lineWidth = 3
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
        
//        physicsWorld.gravity.dy = -20
    }
    
    override func didMove(to view: SKView) {

        backgroundColor = UIColor.clear
        view.backgroundColor = UIColor.clear
        
        createWire()
        
        if let view = self.view {
            
            wireButton.position = CGPoint.init(x: 0, y: -view.frame.height/2 + 40)
            placeHolderButton.position = CGPoint.init(x: 20, y: -view.frame.height/2 - 40)
        }
    }
    
    func sizeOfParentChanged() {
        if let view = self.view {
            
            wireButton.position = CGPoint.init(x: 0, y: -view.frame.height/2 + 40)
            placeHolderButton.position = CGPoint.init(x: -40, y: -view.frame.height/2 - 40)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else {
            return
        }
        
        wireButton.position = point
        self.spinnerInput?.spinnerDelegate?.needRotateSpinner()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.spinnerInput?.spinnerDelegate?.needAddSpinner()
        
        if let endJoint = self.endJoint {
            physicsWorld.remove(endJoint)
        }
        
        if let beginJoint = self.beginJoint {
            physicsWorld.remove(beginJoint)
        }
        
        if let view = self.view {
            wireButton.position = CGPoint.init(x: 0, y: -view.frame.height/2 + 40)
        }
        
    }
    
    func eraseWire() {
        for wireNode in wireNodes {
            wireNode.removeFromParent()
        }
        
        self.wireNodes = []
    }
    
    func createWire() {
        var wireNodes: [SKNode] = []
        
        for _ in 0..<200 {
            let wireNode = SKShapeNode.init(circleOfRadius: 5)
            wireNode.physicsBody = SKPhysicsBody.init(circleOfRadius: 5)
            wireNode.fillColor = UIColor.black
            wireNode.strokeColor = UIColor.clear
            wireNode.physicsBody?.collisionBitMask = 0
            wireNode.zPosition = -1
            
            
            addChild(wireNode)
            
            if let lastWire = wireNodes.last {
                let pinJoint = SKPhysicsJointPin.joint(withBodyA: lastWire.physicsBody!, bodyB: wireNode.physicsBody!, anchor: lastWire.position)
                
                physicsWorld.add(pinJoint)
            } else {
                let pinJoint = SKPhysicsJointPin.joint(withBodyA: placeHolderButton.physicsBody!, bodyB: wireNode.physicsBody!, anchor: placeHolderButton.position)
                
                physicsWorld.add(pinJoint)
                self.beginJoint = pinJoint
            }
            
            wireNodes.append(wireNode)
        }
        
        if let lastWire = wireNodes.last {
            let pinJoint = SKPhysicsJointPin.joint(withBodyA: lastWire.physicsBody!, bodyB: wireButton.physicsBody!, anchor: CGPoint.init(x: lastWire.frame.midX, y: lastWire.frame.midY))
            physicsWorld.add(pinJoint)
            self.endJoint = pinJoint
        }
    }
}
