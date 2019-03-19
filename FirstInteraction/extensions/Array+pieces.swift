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
            let piece = Piece.init(image: pieceImage, tag: String(slot.quantity), enabled: true)
            
            pieces.append(piece)
        }
        
        return pieces
    }
}

extension Array where Element == SpinnerSlot {
    func pieces() -> [Piece] {
        var pieces = Array<Piece>()
        
        for slot in self {
            
            let pieceImage = UIImage.init(named: "spinner\(slot.color)") ?? UIImage.init(named: "spinner")
            let piece = Piece.init(image: pieceImage, tag: "\(slot.color)", enabled: true)
            
            pieces.append(piece)
        }
        
        return pieces
    }
}
