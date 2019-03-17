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
            UIImage.init(named: "walls"),
            UIImage.init(named: "walls")
        ]
        let piecesPicker = PiecesPicker.init(piecesImages: piecesImages)
        piecesPicker.piecesDelegate = self
        piecesPicker.layer.masksToBounds = false
        
        piecesPicker.layer.shadowColor = UIColor.black.cgColor
        piecesPicker.layer.shadowOpacity = 1
        piecesPicker.layer.shadowOffset = CGSize.zero
       
        piecesPicker.layer.shadowPath = UIBezierPath(rect: piecesPicker.layer.bounds).cgPath
        piecesPicker.layer.shouldRasterize = true
        
        return piecesPicker
    }()
    
    lazy var cameraNode: SCNNode = {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 15, z: 20)
        cameraNode.eulerAngles.x = -Float(Double.pi / 6)
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
        let sandBox = SandBoxPlace.init(withHeight: 10, width: 10, overlayDistance: 7, minimumOfLines: 10, andSceneView: sceneView)
        sandBox.position = SCNVector3.zero
        
        return sandBox
    }()
    
    lazy var rotateButton: UIView = {
        let view = UIView.init()
        
        view.backgroundColor = UIColor.red
        view.layer.cornerRadius = 40
        view.layer.masksToBounds = true
        
        return view
    }()
    
    lazy var earthNode: SCNNode = {
        
        let earthNode = SCNScene.init(named: "art.scnassets/earthScene.scn")!.rootNode.childNodes.first!
        earthNode.scale = SCNVector3.init(7.5, 7.5, 7.5)
        earthNode.pivot = SCNMatrix4MakeTranslation(0, 1, 0)
        earthNode.position.y -= 0.7
        
        return earthNode
    }()
    
    lazy var sceneView: SCNView = {
        
        return SCNView.init()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = UIView()
        let scene = SCNScene.init()
        
        // set the scene to the view
        sceneView.scene = scene
        
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(ambientLightNode)
        scene.rootNode.addChildNode(sandBox)
        scene.rootNode.addChildNode(earthNode)
        
        setupSceneView()
        self.view.addSubview(piecesPicker)
        self.view.addSubview(rotateButton)
        rotateButton.translatesAutoresizingMaskIntoConstraints = false
        rotateButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        rotateButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        rotateButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        rotateButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        rotateButton.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(rotateButtonTapped(tapGestureRecognizer:))))
        
    }
    
    @objc func rotateButtonTapped(tapGestureRecognizer: UITapGestureRecognizer) {
      
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
//        sceneView.showsStatistics = true
        
        sceneView.debugOptions = .showPhysicsShapes
        
        // configure the view
        sceneView.backgroundColor = UIColor.black
        
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
        if let descriptor = defaultPiece(
            type: position,
            image: piecesPicker.piecesImages[position]) {
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
    
    func defaultPiece(type: Int, image: UIImage?) -> PieceDescriptor? {

        let cube = SCNBox.init(width: 0.5, height: 1, length: 0.5, chamferRadius: 0)
        cube.firstMaterial?.diffuse.contents = UIImage.init(named: "walls")
        let cubeNode = SCNNode.init(geometry: cube)
        cubeNode.name = "cube"
        
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
        
        switch type {
        case 0:
            return PieceDescriptor.init(
                pieceNode: cubeNode,
                pieceGridSize: (width: 1, height: 1),
                pieceRealSize: (width: 0.5, height: 1, depth: 0.5),
                placeHolderImage: image
            )
        case 1:
            return PieceDescriptor.init(
                pieceNode: cubeNode,
                pieceGridSize: (width: 2, height: 1),
                pieceRealSize: (width: 0.5, height: 1, depth: 0.5),
                placeHolderImage: image
            )
        case 2:
            return PieceDescriptor.init(
                pieceNode: cubeNode,
                pieceGridSize: (width: 2, height: 2),
                pieceRealSize: (width: 0.5, height: 1, depth: 0.5),
                placeHolderImage: image
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
                pieceRealSize: (width: 0.4, height: 0.5, depth: 0.4),
                placeHolderImage: image
            )
        case 4:
            return PieceDescriptor.init(
                pieceNode: calcadoNode,
                pieceGridSize: (width: 1, height: 1),
                pieceRealSize: (width: 18, height: 18, depth: 16),
                placeHolderImage: image
            )
        case 5:
            return PieceDescriptor.init(
                pieceNode: calcadoNode,
                pieceGridSize: (width: 2, height: 2),
                pieceRealSize: (width: 18, height: 18, depth: 16),
                placeHolderImage: image
            )
        default:
            return nil
        }
    }
}
