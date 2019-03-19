//
//  SpinnerPlace.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 18/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation
import SceneKit

class SpinnerPlace: SCNNode {
    
    weak var sceneView: SCNView?
    weak var parentView: UIView?
    
    lazy var spinnerNode: SCNNode = {
        let spinnerNode = SCNScene.init(named: "art.scnassets/spinner.scn")!.rootNode.childNode(withName: "spinner", recursively: false)!
        
        spinnerNode.position.z = 15
        spinnerNode.position.y = -21
        
//        spinnerNode.eulerAngles.x -= Float.pi/6
        
        spinnerNode.runAction(SCNAction.sequence([
            SCNAction.wait(duration: 2.3),
            SCNAction.moveBy(x: 0, y: 30, z: 0, duration: 0.6)
        ]))
        
//        spinnerNode.physicsBody = SCNPhysicsBody.init(type: .dynamic, shape: nil)
        spinnerNode.physicsBody?.isAffectedByGravity = false
        
        return spinnerNode
    }()
    
    init(withScene sceneView: SCNView, andParentView parentView: UIView) {
        super.init()
        
        self.parentView = parentView
        self.sceneView = sceneView
        
        addChildNode(spinnerNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
