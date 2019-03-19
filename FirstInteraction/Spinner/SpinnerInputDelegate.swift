//
//  SpinnerPlaceDelegate.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 18/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation

protocol SpinnerInputDelegate: AnyObject {
    func needAddSpinner(to direction: SpinnerDirection)
    func needRotateSpinner()
    func needDequeueSpinner()
}
