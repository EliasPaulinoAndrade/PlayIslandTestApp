//
//  PieceDescriptor.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 16/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation
import SceneKit

typealias PieceGridSize = (width: Int, height: Int)
typealias PieceSize = (width: CGFloat, height: CGFloat, depth: CGFloat)

struct PieceDescriptor {
    var pieceNode: SCNNode
    var pieceGridSize: PieceGridSize
    var pieceRealSize: PieceSize
    
    var placeHolderImage: UIImage?
    
    var heightRate: CGFloat {
        return pieceRealSize.height/pieceRealSize.width
    }
    
    func scaledSize(gridSize: CGFloat) -> PieceSize {
        let scale = scaleToReach(gridSize: gridSize)
        
        return (
            width: CGFloat(scale.x) * pieceRealSize.width,
            height: CGFloat(scale.y) * pieceRealSize.height,
            depth: CGFloat(scale.z) * pieceRealSize.depth
        )
    }
    
    func scaleToReach(gridSize: CGFloat) -> SCNVector3 {
        let totalX = CGFloat(pieceGridSize.width) * gridSize
        let totalZ = CGFloat(pieceGridSize.height) * gridSize
        
        let scaleX = totalX/pieceRealSize.width
        let scaleZ = totalZ/pieceRealSize.depth
        let scaleY = (scaleX * pieceRealSize.height)/pieceRealSize.height
        
        let scale = SCNVector3.init(scaleX, scaleY, scaleZ)
        
        return scale
    }
}
