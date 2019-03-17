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
    
    private(set) var piecesImages: [UIImage?]
    
    init(piecesImages: [UIImage?]) {
        let layout = UICollectionViewFlowLayout.init()

        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        
        self.piecesImages = piecesImages
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
        return piecesImages.count
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
        
        imageView.image = piecesImages[indexPath.row]
        
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
        
        guard let cellView = longPressRecognizer.view as? UICollectionViewCell,
              let cellPosition = indexPath(for: cellView) else {
            return
        }
        
        switch longPressRecognizer.state {
        case .began:
            hideOtherCells(forCellAtIndex: cellPosition)
            piecesDelegate?.piecePanDidBegan(withGestureRecognizer: longPressRecognizer, atPosition: cellPosition.row)
        case .ended:
            showAllCells()
            piecesDelegate?.piecePanDidEnded(withGestureRecognizer: longPressRecognizer, atPosition: cellPosition.row)
        case .changed:
            
            piecesDelegate?.piecePanDidChange(withGestureRecognizer: longPressRecognizer, atPosition: cellPosition.row)
        default:
            break
        }
    }
    
    func hideOtherCells(forCellAtIndex mainCellIndex: IndexPath) {
        for cell in visibleCells where indexPath(for: cell) != mainCellIndex {
            cell.layer.opacity = 0.7
        }
    }
    
    func showAllCells() {
        for cell in visibleCells {
            UIView.animate(withDuration: 0.5) {
                cell.layer.opacity = 1
            }
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
