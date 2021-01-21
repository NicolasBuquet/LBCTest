//
//  FilterPane.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 20/01/2021.
//

import Foundation
import UIKit

class FilterPane : UIView {
    private static let CELL_REUSE_ID = #file + "_REUSE_ID"
    private static let CELL_HEIGHT = CGFloat(40.0)
    
    public typealias CompletionAction = (_ selected: ItemCategory?) -> Void
    
    // Use collectionView to be able to easily display Cards on iPad (larger screen)
    lazy var collectionView: UICollectionView = { [unowned self] in
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = true
       
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Self.CELL_REUSE_ID)
        
        return collectionView
    }()
    
    let data = AppData.shared.categories.sorted { (c1, c2) in c1.name.caseInsensitiveCompare(c2.name) == .orderedAscending } // Sort categories by name
    var currentCategory: ItemCategory?
    
    let completion: CompletionAction
    
    required init(currentCategory: ItemCategory?, completion: @escaping CompletionAction) {
        self.currentCategory = currentCategory
        self.completion = completion
        
        super.init(frame :.zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        
        self.addSubview(self.collectionView)
        self.layoutContent()
    }
    
    private func layoutContent() {
        
        let constraints = [
            self.collectionView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -16.0),
            self.collectionView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -16.0),
            self.collectionView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.collectionView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8.0
    }
}

extension FilterPane: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.CELL_REUSE_ID, for: indexPath)
        // Populate cell
        let badge = Badge(.big)
        badge.text = self.data[indexPath.row].name
        badge.isSelected = self.data[indexPath.row] == self.currentCategory
        cell.contentView.removeAllSubviews()
        
        cell.contentView.addSubview(badge)
        
        let constraints = [
            badge.widthAnchor.constraint(greaterThanOrEqualToConstant: 0.0),
            badge.heightAnchor.constraint(greaterThanOrEqualToConstant: 0.0),
            badge.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            badge.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        return cell
    }
}

extension FilterPane: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: Self.CELL_HEIGHT)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let rowCategory = self.data[indexPath.row]
        // set or remove current selected category
        self.currentCategory = rowCategory == self.currentCategory ? nil : rowCategory
        // call refresh to display new state
        collectionView.reloadData()
        // block any user interaction
        self.isUserInteractionEnabled = false
        
        // Call completion after short delay to show user UI refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.completion(self.currentCategory)
        }
        
    }
}
