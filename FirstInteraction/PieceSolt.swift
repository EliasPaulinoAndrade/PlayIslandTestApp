//
//  PiecesAmount.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 17/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation

struct PieceSlot {
    var pieceType: PieceType
    var quantity: Int
    var color: PieceColorType
    var usedPieces = 0
    
    init(pieceType: PieceType, quantity: Int, color: PieceColorType) {
        self.pieceType = pieceType
        self.quantity = quantity
        self.color = color
    }
}
