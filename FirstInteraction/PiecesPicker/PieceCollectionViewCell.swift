//
//  PieceCollectionViewCell.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 16/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import UIKit

class PieceCollectionViewCell: UICollectionViewCell {
    
    lazy var tagLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.zero)
        
        label.textColor = UIColor.white

        label.textAlignment = .center
        
        return label
    }()
    
    lazy var tagView: UIView = {
        let tagView = UIView.init()
        tagView.backgroundColor = UIColor.init(named: "menuBorder")
        tagView.layer.masksToBounds = true
        tagView.layer.cornerRadius = 10
        
        tagView.addSubview(tagLabel)
        
        return tagView
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView.init(frame: CGRect.zero)
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.init(named: "menuBorder")?.cgColor
        imageView.backgroundColor = UIColor.white
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        addSubview(tagView)
        
        clipsToBounds = false
    }
    
    override func layoutSubviews() {
        tagView.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: frame.width/1.5, height: 20))
        tagView.center = CGPoint.init(x: frame.width/2, y: 0)
        tagView.frame.origin.y = 0
        
        imageView.frame = CGRect.init(
            origin: CGPoint.zero,
            size: CGSize.init(
                width: frame.width,
                height: frame.height
            )
        )
        
        imageView.layer.cornerRadius = frame.height/2
        tagLabel.frame = CGRect.init(origin: CGPoint.zero, size: tagView.frame.size)
        tagLabel.center = CGPoint.init(x: tagView.frame.width/2, y: tagView.frame.height/2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
