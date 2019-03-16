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
        
        let piecesImages = [
            UIImage.init(named: "walls"),
            UIImage.init(named: "walls"),
            UIImage.init(named: "walls"),
            UIImage.init(named: "walls"),
            UIImage.init(named: "walls")
        ]
        let piecesPicker = PiecesPicker.init(piecesImages: piecesImages)
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
        let sandBox = SandBoxPlace.init(withHeight: 5, width: 10, overlayDistance: 5, minimumOfLines: 5, andSceneView: sceneView)
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
    var teste = 0
}

extension GameViewController: PiecePickerDelegate {
    func piecePanDidBegan(withGestureRecognizer gestureRecognizer: UILongPressGestureRecognizer, atPosition position: Int) {
        if let descriptor = defaultPiece(type: position) {
            sandBox.pieceDragNeedBegan(withPiece: descriptor)
        }
    }
    
    func piecePanDidEnded(withGestureRecognizer gestureRecognizer: UILongPressGestureRecognizer, atPosition position: Int) {
        sandBox.pieceDragNeedEnd()
    }
    
    func piecePanDidChange(withGestureRecognizer gestureRecognizer: UILongPressGestureRecognizer, atPosition position: Int) {
        
        let touchPoint = gestureRecognizer.location(in: sceneView)
        sandBox.handlePieceDrag(inPoint: touchPoint)
    }
    
    func defaultPiece(type: Int) -> PieceDescriptor? {

        let cube = SCNBox.init(width: 0.5, height: 1, length: 0.5, chamferRadius: 0)
        cube.firstMaterial?.diffuse.contents = UIImage.init(named: "walls")
        let cubeNode = SCNNode.init(geometry: cube)
        cubeNode.name = "cube"
        
        switch type {
        case 0:
            return PieceDescriptor.init(
                pieceNode: cubeNode,
                pieceGridSize: (width: 1, height: 1),
                pieceRealSize: (width: 0.5, height: 1, depth: 0.5)
            )
        case 1:
            return PieceDescriptor.init(
                pieceNode: cubeNode,
                pieceGridSize: (width: 2, height: 1),
                pieceRealSize: (width: 0.5, height: 1, depth: 0.5)
            )
        case 2:
            return PieceDescriptor.init(
                pieceNode: cubeNode,
                pieceGridSize: (width: 2, height: 2),
                pieceRealSize: (width: 0.5, height: 1, depth: 0.5)
            )
        case 3:
            let bezier = UIBezierPath.init()
            bezier.move(to: CGPoint.init(x: -0.25, y: -0.25))
            bezier.addLine(to: CGPoint.init(x: 0.25, y: -0.25))
            bezier.addLine(to: CGPoint.init(x: 0, y: 0.25))
            bezier.addLine(to: CGPoint.init(x: -0.25, y: -0.25))
            
            let telhado = SCNShape.init(path: bezier, extrusionDepth: 0.5)
            telhado.firstMaterial?.diffuse.contents = UIImage.init(named: "walls")
            let telhadoNode = SCNNode.init(geometry: telhado)
            
            return PieceDescriptor.init(
                pieceNode: telhadoNode,
                pieceGridSize: (width: 1, height: 1),
                pieceRealSize: (width: 0.5, height: 0.5, depth: 0.5)
            )
        case 4:
            let bezierCalcado = UIBezierPath.init()
            
            bezierCalcado.move(to: CGPoint.init(x: -9, y: -9))
            
            bezierCalcado.addLine(to: CGPoint.init(x: -5, y: -9))
            bezierCalcado.addLine(to: CGPoint.init(x: -5, y: 1))
            bezierCalcado.addQuadCurve(to: CGPoint.init(x: 5, y: 1), controlPoint: CGPoint.init(x: 0, y: 9))
            bezierCalcado.addLine(to: CGPoint.init(x: 5, y: -9))
            bezierCalcado.addLine(to: CGPoint.init(x: 9, y: -9))
            bezierCalcado.addLine(to: CGPoint.init(x: 9, y: 9))
            bezierCalcado.addLine(to: CGPoint.init(x: -9, y: 9))
            
            bezierCalcado.close()
            
            let calcado = SCNShape.init(path: bezierCalcado, extrusionDepth: 16)
            calcado.firstMaterial?.diffuse.contents = UIImage.init(named: "walls")
            let calcadoNode = SCNNode.init(geometry: calcado)
            
            return PieceDescriptor.init(
                pieceNode: calcadoNode,
                pieceGridSize: (width: 1, height: 1),
                pieceRealSize: (width: 18, height: 18, depth: 16)
            )
        default:
            return nil
        }
    }
}
