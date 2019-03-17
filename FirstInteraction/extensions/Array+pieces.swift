//
//  Array+pieces.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 17/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation
import UIKit

extension Array where Element == PieceSlot {
    func pieces() -> [Piece] {
        var pieces = Array<Piece>()
        
        for slot in self {
            let pieceImage = UIImage.init(named: "\(slot.pieceType)\(slot.color)") ?? UIImage.init(named: "\(slot.pieceType)")
            let piece = Piece.init(image: pieceImage, number: slot.quantity, enabled: true)
            
            pieces.append(piece)
        }
        
        return pieces
    }
}
