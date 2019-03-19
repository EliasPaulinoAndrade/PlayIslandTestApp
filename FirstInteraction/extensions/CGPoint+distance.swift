//
//  CGPoint+distance.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 19/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGPoint {
    func distance(to otherPoint: CGPoint) -> CGFloat {
        let xDist = self.x - otherPoint.x
        let yDist = self.y - otherPoint.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
}
