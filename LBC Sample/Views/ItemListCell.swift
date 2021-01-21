//
//  ItemListCell.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 19/01/2021.
//

import Foundation
import UIKit

class ItemListCell: UICollectionViewCell {
    private static let noImage = UIImage(named: "noImage")
    
    var item: Item? {
        didSet {
            self.updateContent()
        }
    }
    
    private var photoFetchRequest: NBNetwork.Request?
    
    let photoView: UIImageView = {
        let imageView = UIImageView(image: ItemListCell.noImage)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let imageLoader: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: .gray)
        aiView.translatesAutoresizingMaskIntoConstraints = false
        aiView.hidesWhenStopped = true
        aiView.stopAnimating() // start stopped and hidden
        return aiView
    }()
    
    static let urgentImage = UIImage(named: "urgent")! // load resource image only once.
    
    let urgentTag: UIImageView = {
        let imageView = UIImageView(image: ItemListCell.urgentImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let lbl = UILabel(text: "<title>")
        lbl.font = UI.itemCellTitleFont
        lbl.numberOfLines = 2
        lbl.textColor = .text
        return lbl
    }()
    
    let priceLabel: UILabel = {
        let lbl = UILabel(text: "<Price>")
        lbl.font = UI.itemCellPriceFont
        lbl.numberOfLines = 1
        lbl.textColor = .main
        return lbl
    }()
    
    let categoryBadge: Badge = {
        let badge = Badge(.small)
        badge.text = "<Category>"
        return badge
    }()
    
    let proBadge = Badge.pro()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundColor = .white
        self.addSubview(self.photoView)
        self.addSubview(self.imageLoader)
        self.addSubview(self.urgentTag)
        self.addSubview(self.priceLabel)
        self.addSubview(self.categoryBadge)
        self.addSubview(self.proBadge)
        self.addSubview(self.titleLabel)
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.25
        
        self.layoutContent()
    }
    
    private func layoutContent() {
        
        let constraints = [
            // 4 px insets around image
            self.photoView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -8.0),
            self.photoView.widthAnchor.constraint(equalTo: self.photoView.heightAnchor),
            self.photoView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4.0),
            self.photoView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4.0),

            self.urgentTag.widthAnchor.constraint(equalTo: self.photoView.widthAnchor, multiplier: 0.5),
            self.urgentTag.heightAnchor.constraint(equalTo: self.urgentTag.widthAnchor, multiplier: ItemListCell.urgentImage.size.height/ItemListCell.urgentImage.size.width),
            self.urgentTag.leadingAnchor.constraint(equalTo: self.photoView.leadingAnchor, constant: 0.0),
            self.urgentTag.topAnchor.constraint(equalTo: self.photoView.topAnchor, constant: 0.0),

            self.imageLoader.centerXAnchor.constraint(equalTo: self.photoView.centerXAnchor),
            self.imageLoader.centerYAnchor.constraint(equalTo: self.photoView.centerYAnchor),
            
            // Price right aligned, centerY
            self.priceLabel.topAnchor.constraint(equalTo: self.topAnchor),
            self.priceLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4.0),
            self.priceLabel.heightAnchor.constraint(equalTo: self.heightAnchor),
            self.priceLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 32.0),
            
            // Badges bottom aligned on photo.bottom
            self.categoryBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 0.0),
            self.categoryBadge.heightAnchor.constraint(greaterThanOrEqualToConstant: 0.0),
            self.categoryBadge.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.categoryBadge.bottomAnchor.constraint(equalTo: self.photoView.bottomAnchor, constant: -4.0),
            
            self.proBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 0.0),
            self.proBadge.heightAnchor.constraint(greaterThanOrEqualToConstant: 0.0),
            self.proBadge.leadingAnchor.constraint(equalTo: self.categoryBadge.trailingAnchor, constant: 8.0),
            self.proBadge.centerYAnchor.constraint(equalTo: self.categoryBadge.centerYAnchor),
            
            // top aligned on photo.top
            self.titleLabel.leadingAnchor.constraint(equalTo: self.photoView.trailingAnchor, constant: 16.0),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.priceLabel.leadingAnchor, constant: -16.0),
            self.titleLabel.topAnchor.constraint(equalTo: self.photoView.topAnchor, constant: 4.0)
        ]

        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
        self.photoView.image = Self.noImage
        self.proBadge.isHidden = true // PRO badge is hidden by default
        self.urgentTag.isHidden = true // Urgent tag is hidden by default
    }
    
    private func updateContent() {
        if self.photoFetchRequest != nil {
            // Cancel any pending request
            self.photoFetchRequest!.cancel()
        }
        self.photoFetchRequest = nil
        self.imageLoader.stopAnimating()
        self.urgentTag.isHidden = !(self.item?.isUrgent ?? false)
       
        self.priceLabel.text = self.item?.price.localePriceString
        self.titleLabel.text = self.item?.title ?? "<no title>"
        self.categoryBadge.text = self.item?.category?.name
        self.categoryBadge.isHidden = self.categoryBadge.text == nil
        self.proBadge.isHidden = !(self.item?.isProfessional ?? false)
        
        if let thumbUrl = self.item?.image.thumb {
        self.photoFetchRequest = AppNetwork.shared.fetchImage(imageUrlString: thumbUrl, { (data, error) in
            if let data = data {
                self.photoView.image = UIImage(data: data)
            }
            else {
                // load default missing image
                self.photoView.image = Self.noImage
            }
            
            self.imageLoader.stopAnimating()
            self.photoFetchRequest = nil
        })
            self.imageLoader.startAnimating()
        }
    }
    
    
}
