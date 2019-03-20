//
//  ARView.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 20/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation
import ARKit

class ARView: ARSCNView {

    private var hasDetectedPlane: Bool = false
    
    var sandBox: SandBoxPlace?
    var gameType: GameType
    
    private var piecesFactory = PiecesFactory()
    private var pieceSlots: [PieceSlot] = []
    private var spinnerSlots: [SpinnerSlot] = []
    
    lazy var piecesPicker: PiecesPicker = {
        
        var pieces: [Piece] = []
        
        switch gameType {
        case .blocks:
            pieces = self.pieceSlots.pieces()
        case .spin:
            pieces = self.spinnerSlots.pieces()
        }
        
        let piecesPicker = PiecesPicker.init(piecesImages: pieces, andAligment: gameType == .blocks ? .bottom : .top )
        piecesPicker.piecesDelegate = self
        piecesPicker.layer.masksToBounds = false
        
        piecesPicker.layer.shadowColor = UIColor.black.cgColor
        piecesPicker.layer.shadowOpacity = 1
        piecesPicker.layer.shadowOffset = CGSize.zero
        
        piecesPicker.layer.shadowPath = UIBezierPath(rect: piecesPicker.layer.bounds).cgPath
        piecesPicker.layer.shouldRasterize = true
        
        return piecesPicker
    }()
    
    lazy var arBackButton: UIImageView = {
        let arBackButton = UIImageView.init()
        
        arBackButton.clipsToBounds = true
        arBackButton.layer.cornerRadius = 35
        arBackButton.backgroundColor = UIColor.red
        arBackButton.isUserInteractionEnabled = true
        
        return arBackButton
    }()
    

    init(withGameType gameType: GameType, withSlots: [PieceSlot]) {
        self.gameType = gameType
        self.pieceSlots = withSlots
        
        super.init(frame: CGRect.zero, options: nil)
        
        self.addSubview(piecesPicker)
    }
    
    init(withGameType gameType: GameType, withSlots: [SpinnerSlot]) {
        self.gameType = gameType
        self.spinnerSlots = withSlots
        
        super.init(frame: CGRect.zero, options: nil)
        
        
        self.addSubview(piecesPicker)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        guard let superview = self.superview else {
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
        self.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        
        self.isHidden = true
        
        self.session.delegate = self
        self.delegate = self
    }
    
    func setupArButton() {
        self.addSubview(arBackButton)
        arBackButton.translatesAutoresizingMaskIntoConstraints = false
        arBackButton.isUserInteractionEnabled = true
        
        arBackButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        arBackButton.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        arBackButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        arBackButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        arBackButton.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(arButtonTapped(tapGestureRecognizer:))))
    }
    
    @objc func arButtonTapped(tapGestureRecognizer: UIGestureRecognizer) {
        
    }
    
    func setupARView() {
        self.isHidden = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        
        self.session.run(configuration)
        self.debugOptions = .showBoundingBoxes
        
        UIApplication.shared.isIdleTimerDisabled = true

    }
    
    func stopARView() {
        self.session.pause()
        self.isHidden = true
        UIApplication.shared.isIdleTimerDisabled = true
    }
}


extension ARView: ARSCNViewDelegate, ARSessionDelegate, SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor, !hasDetectedPlane else {
            return
            
        }
        
        DispatchQueue.main.async {
            self.sandBox = SandBoxPlace.init(withHeight: CGFloat(planeAnchor.extent.z), width: CGFloat(planeAnchor.extent.x), overlayDistance: 0.4, minimumOfLines: 10, andSceneView: self, type: .ar, andAnchorPosition: planeAnchor.center)
        
            
            self.scene.rootNode.addChildNode(self.sandBox!)
        }
        
        
        
//        // Create a node to visualize the plane's bounding rectangle.
//        let extentPlane: SCNPlane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
//        extentNode = SCNNode(geometry: extentPlane)
//        extentNode.simdPosition = anchor.center
//        extentNode.position.y = 0
//        let plane = Plane(anchor: planeAnchor, in: self)
        
        hasDetectedPlane = true
//
        
//        self.scene.rootNode.addChildNode(plane)
       
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

        guard let planeAnchor = anchor as? ARPlaneAnchor,
              let sandBox = self.sandBox else {
              return
        }
        
//        sandBox.simdPosition = planeAnchor.center
        
//        // Update extent visualization to the anchor's new bounding rectangle.
//        if let extentGeometry = plane.extentNode.geometry as? SCNPlane {
//            extentGeometry.width = CGFloat(planeAnchor.extent.x)
//            extentGeometry.height = CGFloat(planeAnchor.extent.z)
//            plane.extentNode.simdPosition = planeAnchor.center
//        }
        
    }
    
}

extension ARView: PiecePickerDelegate {
    func piecePanDidBegan(withGestureRecognizer gestureRecognizer: UILongPressGestureRecognizer, atPosition position: Int) {
        
        self.pieceSlots[position].usedPieces += 1
        let slot = self.pieceSlots[position]
        let descriptor = piecesFactory.makePiece(ofType: slot.pieceType, withColor: slot.color)
        sandBox?.pieceDragNeedBegan(withPiece: descriptor)
        piecesPicker.piecesImages[position].tag = String(slot.quantity - slot.usedPieces)
    }
    
    func piecePanDidEnded(withGestureRecognizer gestureRecognizer: UILongPressGestureRecognizer, atPosition position: Int) {
        sandBox?.pieceDragNeedEnd()
        let slot = self.pieceSlots[position]
        if slot.usedPieces == slot.quantity {
            piecesPicker.disableCellAt(position: position)
        }
    }
    
    func piecePanDidChange(withGestureRecognizer gestureRecognizer: UILongPressGestureRecognizer, atPosition position: Int) {
        
        let touchPoint = gestureRecognizer.location(in: self)
        sandBox?.handlePieceDrag(inPoint: touchPoint)
    }
}
