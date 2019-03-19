//
//  PickPiecesCollectionView.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 15/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import UIKit

class PiecesPicker: UIView {
    
    weak var piecesDelegate: PiecePickerDelegate?
    
    var piecesImages: [Piece]
    var aligment: PiecesPickerAligment
    
    var soundsService = SoundsService()
    
    lazy private var pieceBackgroundView: UIView = {
        let pieceBackgroundView = UIView.init()
        
        pieceBackgroundView.backgroundColor = UIColor.white
        pieceBackgroundView.layer.opacity = 0.7
        
        return pieceBackgroundView
    }()
    
    lazy private var piecesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        
        let piecesCollectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        piecesCollectionView.backgroundColor = UIColor.clear

        return piecesCollectionView
    }()
    
    init(piecesImages: [Piece], andAligment aligment: PiecesPickerAligment) {
        
        self.piecesImages = piecesImages
        self.aligment = aligment
        super.init(frame: CGRect.zero)
        addSubview(pieceBackgroundView)
        addSubview(piecesCollectionView)
        
        backgroundColor = UIColor.clear
        layer.borderWidth = 2
        layer.borderColor = UIColor.init(named: "menuBorder")?.cgColor
        piecesCollectionView.delegate = self
        piecesCollectionView.dataSource = self
        piecesCollectionView.register(PieceCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        guard let superView = self.superview else {
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if aligment == .bottom {
            bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -10).isActive = true
        } else {
            topAnchor.constraint(equalTo: superView.topAnchor, constant: 10).isActive = true
        }
        centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        let selfLeftAnchor = leftAnchor.constraint(equalTo: superView.leftAnchor, constant: 10)
        selfLeftAnchor.priority = .defaultHigh
        selfLeftAnchor.isActive = true
        
        let selfWidth = widthAnchor.constraint(lessThanOrEqualToConstant: 400)
        selfWidth.priority = .required
        selfWidth.isActive = true
        
        piecesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        piecesCollectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        piecesCollectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        piecesCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        piecesCollectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        pieceBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        pieceBackgroundView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        pieceBackgroundView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        pieceBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        pieceBackgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        self.layer.cornerRadius = 50
        self.layer.masksToBounds = true
    }

    func reloadData() {
        self.piecesCollectionView.reloadData()
    }
}

extension PiecesPicker: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return piecesImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        if let pieceCell = cell as? PieceCollectionViewCell {
            let piece = piecesImages[indexPath.row]
            pieceCell.imageView.image = piece.image
            pieceCell.tagLabel.text = piece.tag
            
            if piece.enabled {
                pieceCell.layer.opacity = 1
            } else {
                pieceCell.layer.opacity = 0.5
            }
        }
        
        let cellLongPressGestureRecognizer = UILongPressGestureRecognizer.init(
                target: self,
                action: #selector(cellWasLongPressed(longPressRecognizer:)
            )
        )
        
        cellLongPressGestureRecognizer.minimumPressDuration = 0.2
        
        cell.addGestureRecognizer(
            cellLongPressGestureRecognizer
        )
                
        return cell
    }
    
    @objc func cellWasLongPressed(longPressRecognizer: UILongPressGestureRecognizer) {
        
        guard let cellView = longPressRecognizer.view as? UICollectionViewCell,
              let cellPosition = piecesCollectionView.indexPath(for: cellView),
              self.piecesImages[cellPosition.row].enabled == true else {
            return
        }
        
        switch longPressRecognizer.state {
        case .began:
            soundsService.didBeginDrag()
            hideOtherCells(forCellAtIndex: cellPosition)
            piecesDelegate?.piecePanDidBegan(withGestureRecognizer: longPressRecognizer, atPosition: cellPosition.row)
        case .ended:
            showAllCells()
            reloadData()
            piecesDelegate?.piecePanDidEnded(withGestureRecognizer: longPressRecognizer, atPosition: cellPosition.row)
        case .changed:
            piecesDelegate?.piecePanDidChange(withGestureRecognizer: longPressRecognizer, atPosition: cellPosition.row)
        default:
            break
        }
    }
    
    func disableCellAt(position: Int) {
        self.piecesImages[position].enabled = false
    }
    
    func hideOtherCells(forCellAtIndex mainCellIndex: IndexPath) {
        for cell in piecesCollectionView.visibleCells where piecesCollectionView.indexPath(for: cell) != mainCellIndex {
            cell.layer.opacity = 0.5
        }
    }
    
    func showAllCells() {
        for cell in piecesCollectionView.visibleCells {
            
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
    
    func removeFirstPeace() {
        if piecesImages.count > 0 {
            self.piecesImages.remove(at: 0)
            self.piecesCollectionView.deleteItems(at: [IndexPath.init(row: 0, section: 0)])
        }
    }
}
