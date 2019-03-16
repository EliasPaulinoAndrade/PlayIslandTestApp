//
//  PickPiecesCollectionView.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 15/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import UIKit

class PiecesPicker: UICollectionView {
    
    weak var piecesDelegate: PiecePickerDelegate?
    
    init() {
        let layout = UICollectionViewFlowLayout.init()

        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        
        super.init(frame: CGRect.zero, collectionViewLayout: layout)
        
        backgroundColor = UIColor.red
        delegate = self
        dataSource = self
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMoveToSuperview() {
        guard let superView = self.superview else {
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: superView.leftAnchor, constant: 10).isActive = true
        rightAnchor.constraint(equalTo: superView.rightAnchor, constant: -10).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -10).isActive = true
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        self.layer.cornerRadius = 50
        self.layer.masksToBounds = true
    }
}

extension PiecesPicker: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let cellSize = sizeForCell(withCollectionSize: collectionView.frame.size)
        
        cell.backgroundColor = UIColor.blue
        cell.layer.cornerRadius = cellSize.height/2
        cell.layer.masksToBounds = true
        
        let imageView = UIImageView.init(
            frame: CGRect.init(
                origin: CGPoint.zero,
                size: CGSize.init(
                    width: cellSize.width,
                    height: cellSize.height
                )
            )
        )
        
        imageView.image = UIImage.init(named: "walls")
        
        cell.addGestureRecognizer(
            UILongPressGestureRecognizer.init(
                target: self,
                action: #selector(cellWasLongPressed(longPressRecognizer:)
                )
            )
        )
        
        cell.addSubview(imageView)
        
        return cell
    }
    
    @objc func cellWasLongPressed(longPressRecognizer: UILongPressGestureRecognizer) {
        
        switch longPressRecognizer.state {
        case .began:
            
            piecesDelegate?.piecePanDidBegan(withGestureRecognizer: longPressRecognizer)
        case .ended:
            
            piecesDelegate?.piecePanDidEnded(withGestureRecognizer: longPressRecognizer)
        case .changed:
            
            piecesDelegate?.piecePanDidChange(withGestureRecognizer: longPressRecognizer)
        default:
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return sizeForCell(withCollectionSize: collectionView.frame.size)
    }
    
    func sizeForCell(withCollectionSize collectionSize: CGSize) -> CGSize {
        let height = collectionSize.height - 20
        let width = height
        
        return CGSize.init(width: width, height: height)
    }
}
