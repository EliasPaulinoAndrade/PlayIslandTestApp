//
//  SCNVector3+zero.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 15/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation
import SceneKit

extension SCNVector3 {
    static var zero: SCNVector3 {
        return SCNVector3.init(0, 0, 0)
    }
}
