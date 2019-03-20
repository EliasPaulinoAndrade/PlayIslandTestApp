//
//  SpinnerInput.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 18/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class SpinnerInput: SKView {
    
    weak var spinnerDelegate: SpinnerInputDelegate?
    
    var thereIsASpinner = true

    var sliderScene: SKScene? = SKScene.init(fileNamed: "SpinnerInputScene")
    
    init() {
        super.init(frame: CGRect.zero)
        
        allowsTransparency = true
        sliderScene?.scaleMode = .resizeFill
        ignoresSiblingOrder = true
        
        if let scene = sliderScene, let spinnerScene = scene as? SpinnerInputScene {
            spinnerScene.spinnerInput = self
        }
        
    }
    
    func needResetView() {
        guard let sliderScene = sliderScene as? SpinnerInputScene else {
            return
        }
        
        sliderScene.resetWire()
        thereIsASpinner = true
    }
    
    override func layoutSubviews() {
        if let scene = sliderScene, let spinnerScene = scene as? SpinnerInputScene {
            presentScene(scene)
            spinnerScene.sizeOfParentChanged()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {

        guard let superView = self.superview else {
            return
        }

        translatesAutoresizingMaskIntoConstraints = false
        bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
        leftAnchor.constraint(equalTo: superView.leftAnchor).isActive = true
        topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
        rightAnchor.constraint(equalTo: superView.rightAnchor).isActive = true
    }
}
