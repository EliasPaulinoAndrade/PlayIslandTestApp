//
//  PiecePickerDelegate.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 15/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

protocol PiecePickerDelegate: AnyObject {
    func piecePanDidEnded(withGestureRecognizer gestureRecognizer: UILongPressGestureRecognizer, atPosition position: Int)
    func piecePanDidChange(withGestureRecognizer gestureRecognizer: UILongPressGestureRecognizer, atPosition position: Int)
    func piecePanDidBegan(withGestureRecognizer gestureRecognizer: UILongPressGestureRecognizer, atPosition position: Int)
}
