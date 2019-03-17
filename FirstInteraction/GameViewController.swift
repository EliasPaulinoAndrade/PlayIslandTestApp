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
    
    private var piecesFactory = PiecesFactory()
    private var pieceSlots: [PieceSlot] = []
    
    lazy var piecesPicker: PiecesPicker = {
        
        let pieces = self.pieceSlots.pieces()
        
        let piecesPicker = PiecesPicker.init(piecesImages: pieces)
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
        let sandBox = SandBoxPlace.init(withHeight: 10, width: 10, overlayDistance: 8.5, minimumOfLines: 10, andSceneView: sceneView)
        sandBox.position = SCNVector3.zero
        
        return sandBox
    }()
    
    lazy var earthNode: SCNNode = {
        
        let earthNode = SCNScene.init(named: "art.scnassets/earth")!.rootNode.childNode(withName: "Cone_003", recursively: false)!
        
        var imageMaterial = SCNMaterial.init()
        imageMaterial.diffuse.contents = UIImage(named: "mountainMaterial")
        imageMaterial.isDoubleSided = false
        
//        earthNode.geometry?.materials = [imageMaterial]
        
        earthNode.scale = SCNVector3.init(7.5, 7.5, 7.5)
        earthNode.pivot = SCNMatrix4MakeTranslation(0, -1, 0)
        earthNode.position.y -= 0.7
        
        return earthNode
    }()
    
    lazy var linearGradientLayer: CAGradientLayer = {
        let linearGradientLayer = CAGradientLayer()
        
        guard let colorTop = UIColor.init(named: "backgroundColor")?.cgColor,
              let colorBottom = UIColor.init(named: "backgroundColorLight")?.cgColor else {
            return linearGradientLayer
        }
    
        linearGradientLayer.colors = [colorBottom, colorTop, colorTop]
        linearGradientLayer.locations = [ 0.0, 0.1, 1.0]
        
        return linearGradientLayer
    }()
    
    lazy var sceneView: SCNView = {
        
        return SCNView.init()
    }()
    
    init(withPieces pieces: [PieceSlot]) {
        self.pieceSlots = pieces
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
       
        self.sceneView.backgroundColor = UIColor.clear
        self.view.layer.insertSublayer(linearGradientLayer, at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        linearGradientLayer.frame = self.view.bounds
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
        
//        sceneView.debugOptions = .showPhysicsShapes
        
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

        self.pieceSlots[position].usedPieces += 1
        let slot = self.pieceSlots[position]
        let descriptor = piecesFactory.makePiece(ofType: slot.pieceType, withColor: slot.color)
        sandBox.pieceDragNeedBegan(withPiece: descriptor)
        piecesPicker.piecesImages[position].number = slot.quantity - slot.usedPieces
    }
    
    func piecePanDidEnded(withGestureRecognizer gestureRecognizer: UILongPressGestureRecognizer, atPosition position: Int) {
        sandBox.pieceDragNeedEnd()
        let slot = self.pieceSlots[position]
        if slot.usedPieces == slot.quantity {
            piecesPicker.disableCellAt(position: position)
        }
    }
    
    func piecePanDidChange(withGestureRecognizer gestureRecognizer: UILongPressGestureRecognizer, atPosition position: Int) {
        
        let touchPoint = gestureRecognizer.location(in: sceneView)
        sandBox.handlePieceDrag(inPoint: touchPoint)
    }
}
