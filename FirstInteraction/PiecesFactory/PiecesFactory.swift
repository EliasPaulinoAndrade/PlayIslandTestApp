//
//  PiecesFactory.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 17/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation
import SceneKit

struct PiecesFactory {
    func makePiece(ofType pieceType: PieceType, withColor pieceColor: PieceColorType) -> PieceDescriptor {
        switch pieceType {
        case .block1x1:
            return makeBlock1x1(withColor: pieceColor)
        case .block2x1:
            return makeBlock2x1(withColor: pieceColor)
        case .block3x1:
            return makeBlock3x1(withColor: pieceColor)
        case .block2x2:
            return makeBlock2x2(withColor: pieceColor)
        case .ceil:
            return makeCeil(withColor: pieceColor)
        case .arch1x1:
            return makeArch1x1(withColor: pieceColor)
        case .arch2x2:
            return makeArch2x2(withColor: pieceColor)
        case .floorAsphalt:
            return makeFloorAsphalt()
        case .floorSideWalk:
            return makeFloorSidewalk()
        case .clockTower:
            return makeClockTower(withColor: pieceColor)
        }
    }
    
    func makeClockTower(withColor color: PieceColorType) -> PieceDescriptor {
        let cube = SCNBox.init(width: 0.5, height: 1, length: 0.5, chamferRadius: 0)
        let cubeMaterial = SCNMaterial.init()
        cubeMaterial.diffuse.contents = UIImage.init(named: "clock\(color)")

        let cubeMaterialClean = SCNMaterial.init()
        cubeMaterialClean.diffuse.contents = UIImage.init(named:"walls\(color)")

        cube.materials = [cubeMaterial, cubeMaterial, cubeMaterial, cubeMaterial, cubeMaterialClean, cubeMaterial]
        
        let cubeNode = SCNNode.init(geometry: cube)
        
        return PieceDescriptor.init(
            pieceNode: cubeNode,
            pieceGridSize: (width: 1, height: 1),
            pieceRealSize: (width: 0.5, height: 1, depth: 0.5)
        )
    }
    
    func makeBlock1x1(withColor color: PieceColorType) -> PieceDescriptor {
        let cube = SCNBox.init(width: 0.5, height: 1, length: 0.5, chamferRadius: 0)

        cube.firstMaterial?.diffuse.contents = UIImage.init(named:"walls\(color)")
        let cubeNode = SCNNode.init(geometry: cube)
        
        return PieceDescriptor.init(
            pieceNode: cubeNode,
            pieceGridSize: (width: 1, height: 1),
            pieceRealSize: (width: 0.5, height: 1, depth: 0.5)
        )
    }
    
    func makeBlock2x1(withColor color: PieceColorType) -> PieceDescriptor {
        
        let cube2x1 = SCNBox.init(width: 1, height: 1, length: 0.5, chamferRadius: 0)
        cube2x1.firstMaterial?.diffuse.contents = UIImage.init(named:"walls\(color)")
        let cubeNode2x1 = SCNNode.init(geometry: cube2x1)
        
        return PieceDescriptor.init(
            pieceNode: cubeNode2x1,
            pieceGridSize: (width: 2, height: 1),
            pieceRealSize: (width: 1, height: 1, depth: 0.5)
        )
    }
    
    func makeBlock3x1(withColor color: PieceColorType) -> PieceDescriptor {
        let cube3x1 = SCNBox.init(width: 1.5, height: 1, length: 0.5, chamferRadius: 0)
        cube3x1.firstMaterial?.diffuse.contents = UIImage.init(named:"walls\(color)")
        let cubeNode3x1 = SCNNode.init(geometry: cube3x1)
        
        return PieceDescriptor.init(
            pieceNode: cubeNode3x1,
            pieceGridSize: (width: 3, height: 1),
            pieceRealSize: (width: 1.5, height: 1, depth: 0.5)
        )
    }
    
    func makeBlock2x2(withColor color: PieceColorType) -> PieceDescriptor {
        let cube2x2 = SCNBox.init(width: 1, height: 1, length: 1, chamferRadius: 0)
        cube2x2.firstMaterial?.diffuse.contents = UIImage.init(named:"walls\(color)")
        let cubeNode2x2 = SCNNode.init(geometry: cube2x2)
        return PieceDescriptor.init(
            pieceNode: cubeNode2x2,
            pieceGridSize: (width: 2, height: 2),
            pieceRealSize: (width: 1, height: 1, depth: 1)
        )
    }
    
    func makeCeil(withColor color: PieceColorType) -> PieceDescriptor {
        let bezier = UIBezierPath.init()
        bezier.move(to: CGPoint.init(x: -0.25, y: -0.25))
        bezier.addLine(to: CGPoint.init(x: 0.25, y: -0.25))
        bezier.addLine(to: CGPoint.init(x: 0, y: 0.25))
        bezier.addLine(to: CGPoint.init(x: -0.25, y: -0.25))
        
        let telhado = SCNShape.init(path: bezier, extrusionDepth: 0.5)
        telhado.firstMaterial?.diffuse.contents = UIImage.init(named:"walls\(color)")
        let telhadoNode = SCNNode.init(geometry: telhado)
        
        return PieceDescriptor.init(
            pieceNode: telhadoNode,
            pieceGridSize: (width: 1, height: 1),
            pieceRealSize: (width: 0.4, height: 0.5, depth: 0.4)
        )
    }
    
    func makeArch1x1(withColor color: PieceColorType) -> PieceDescriptor {
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
        calcado.firstMaterial?.diffuse.contents = UIImage.init(named:"walls\(color)")
        let calcadoNode = SCNNode.init(geometry: calcado)
        
        return PieceDescriptor.init(
            pieceNode: calcadoNode,
            pieceGridSize: (width: 1, height: 1),
            pieceRealSize: (width: 18, height: 18, depth: 16)
        )
        
    }
    
    func makeArch2x2(withColor color: PieceColorType) -> PieceDescriptor {
        
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
        calcado.firstMaterial?.diffuse.contents = UIImage.init(named:"walls\(color)")
        let calcadoNode = SCNNode.init(geometry: calcado)
        
        return PieceDescriptor.init(
            pieceNode: calcadoNode,
            pieceGridSize: (width: 2, height: 2),
            pieceRealSize: (width: 18, height: 18, depth: 16)
        )
    }
    
    func makeFloorAsphalt() -> PieceDescriptor {
        let floor = SCNBox.init(width: 0.5, height: 0.001, length: 0.5, chamferRadius: 0)
        let floorNode = SCNNode.init(geometry: floor)
        
        floor.firstMaterial?.diffuse.contents = UIImage.init(named: "floor")
        
        return PieceDescriptor.init(
            pieceNode: floorNode,
            pieceGridSize: (width: 1, height: 1),
            pieceRealSize: (width: 0.5, height: 0.001, depth: 0.5)
        )
    }
    
    func makeFloorSidewalk() -> PieceDescriptor {
        let floor = SCNBox.init(width: 0.5, height: 0.001, length: 0.5, chamferRadius: 0)
        let floorNode = SCNNode.init(geometry: floor)
        
        floor.firstMaterial?.diffuse.contents = UIImage.init(named: "floor2")
        
        return PieceDescriptor.init(
            pieceNode: floorNode,
            pieceGridSize: (width: 1, height: 1),
            pieceRealSize: (width: 0.5, height: 0.001, depth: 0.5)
        )
    }
}
