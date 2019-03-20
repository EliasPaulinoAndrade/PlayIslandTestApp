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
        spinnerNode.position.y = 9
        spinnerNode.position.x = 0
//        spinnerNode.eulerAngles.x -= Float.pi/6
    
        return spinnerNode
    }()
    
    func addNewSpinner(withColor color: PieceColorType = PieceColorType.blue) {
        if let newSpinner = SCNScene.init(named: "art.scnassets/spinner.scn")?.rootNode.childNode(withName: "spinner", recursively: false) {
            self.spinnerNode = newSpinner
            spinnerNode.position.z = 15
            spinnerNode.position.y = 9
            spinnerNode.removeAllActions()
            spinnerNode.physicsBody = nil
            
            spinnerNode.geometry?.material(named: "spinnerTexture")?.diffuse.contents = UIImage.init(named: "spinnerTexture\(color)") ?? UIImage.init(named: "spinnerTexture")
            
            addChildNode(self.spinnerNode)
        }
    }
    
    init(withScene sceneView: SCNView, andParentView parentView: UIView, andFirstSpinnerColor color: PieceColorType?) {
        super.init()
        
        self.parentView = parentView
        self.sceneView = sceneView
        
        addChildNode(spinnerNode)
        if let color = color {
            spinnerNode.geometry?.material(named: "spinnerTexture")?.diffuse.contents = UIImage.init(named: "spinnerTexture\(color)") ?? UIImage.init(named: "spinnerTexture")
        } else {
            spinnerNode.geometry?.material(named: "spinnerTexture")?.diffuse.contents = UIImage.init(named: "spinnerTexture")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
