//
//  PieceType.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 17/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation

enum PieceType: String, CustomStringConvertible {
    var description: String {
        return self.rawValue
    }
    
    case block1x1, block2x1, block3x1, block2x2, ceil, arch1x1, arch2x2, floorAsphalt, floorSideWalk, clockTower
}

enum PieceColorType: String, CustomStringConvertible {
    
    var description: String {
        return self.rawValue.capitalized
    }
    
    case blue, green, pink, red
}
