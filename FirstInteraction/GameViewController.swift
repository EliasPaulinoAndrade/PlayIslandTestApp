//
//  GameViewController.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 15/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    lazy var piecesPicker: PiecesPicker = {
        let piecesPicker = PiecesPicker.init()
        piecesPicker.piecesDelegate = self
        
        return piecesPicker
    }()
    
    lazy var cameraNode: SCNNode = {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        return cameraNode
    }()
    
    lazy var lightNode: SCNNode = {
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        
        return lightNode
    }()
    
    lazy var ambientLightNode: SCNNode = {
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        
        return ambientLightNode
    }()
    
    lazy var sandBox: SandBoxPlace = {
        let sandBox = SandBoxPlace.init(withHeight: 10, width: 10, andOverlayDistance: 5, sceneView: sceneView)
        sandBox.position = SCNVector3.zero
        sandBox.position.y -= 2
        
        return sandBox
    }()
    
    lazy var sceneView: SCNView = {
        
        return SCNView.init()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = UIView()
        let scene = SCNScene.init()
        
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(ambientLightNode)
        scene.rootNode.addChildNode(sandBox)
        
        setupSceneView()
        self.view.addSubview(piecesPicker)
        
        
        // set the scene to the view
        sceneView.scene = scene
    }
    
    func setupSceneView() {
        self.view.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        
        sceneView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        sceneView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        sceneView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        // allows the user to manipulate the camera
        sceneView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.debugOptions = .showPhysicsShapes
        
        // configure the view
        sceneView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}

extension GameViewController: PiecePickerDelegate {
    func piecePanDidBegan(withGestureRecognizer gestureRecognizer: UILongPressGestureRecognizer) {
        
        sandBox.pieceDragNeedBegan(withPiece: defaultPiece())
    }
    
    func piecePanDidEnded(withGestureRecognizer gestureRecognizer: UILongPressGestureRecognizer) {
        sandBox.pieceDragNeedEnd()
    }
    
    func piecePanDidChange(withGestureRecognizer gestureRecognizer: UILongPressGestureRecognizer) {
        
        let touchPoint = gestureRecognizer.location(in: sceneView)
        sandBox.handlePieceDrag(inPoint: touchPoint)
    }
    
    func defaultPiece() -> SCNNode {

        let cube = SCNBox.init(width: 0.5, height: 2, length: 0.5, chamferRadius: 0)
        cube.firstMaterial?.diffuse.contents = UIImage.init(named: "walls")
        let cubeNode = SCNNode.init(geometry: cube)
        cubeNode.name = "cube"
        cubeNode.pivot = SCNMatrix4MakeTranslation(0, -1, 0)
        
//        cubeNode.eulerAngles.x = .pi/Float(2)
        
        return cubeNode
    }
}
