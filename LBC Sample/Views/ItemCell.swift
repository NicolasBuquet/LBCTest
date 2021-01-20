//
//  ItemCell.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 19/01/2021.
//

import Foundation
import UIKit

class ItemCell: UICollectionViewCell {
    private static let noImage = UIImage(named: "noImage")
    
    var item: Item? {
        didSet {
            self.updateContent()
        }
    }
    
    private var photoFetchRequest: NBNetwork.Request?
    
    let photo: UIImageView = {
        let imageView = UIImageView(image: ItemCell.noImage)
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
        let imageView = UIImageView(image: ItemCell.urgentImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let title: UILabel = {
        let lbl = UILabel(text: "<title>")
        lbl.font = UI.itemCellTitleFont
        lbl.numberOfLines = 2
        lbl.textColor = .text
        return lbl
    }()
    
    let price: UILabel = {
        let lbl = UILabel(text: "<Price>")
        lbl.font = UI.itemCellPriceFont
        lbl.numberOfLines = 1
        lbl.textColor = .main
        return lbl
    }()
    
    private var localePriceString: String? {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale(identifier: "fr_FR")
        if let price = self.item?.price {
            return currencyFormatter.string(from: NSNumber(value: price))
        }
        else {
            return nil
        }
    }
    
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
        self.addSubview(self.photo)
        self.addSubview(self.imageLoader)
        self.addSubview(self.urgentTag)
        self.addSubview(self.price)
        self.addSubview(self.categoryBadge)
        self.addSubview(self.proBadge)
        self.addSubview(self.title)
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.25
        
        self.layoutContent()
    }
    
    private func layoutContent() {
        
        let constraints = [
            // 4 px insets around image
            self.photo.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0, constant: -8.0),
            self.photo.widthAnchor.constraint(equalTo: self.photo.heightAnchor, multiplier: 1.0),
            self.photo.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4.0),
            self.photo.topAnchor.constraint(equalTo: self.topAnchor, constant: 4.0),

            self.urgentTag.widthAnchor.constraint(equalTo: self.photo.widthAnchor, multiplier: 1.0),
            self.urgentTag.heightAnchor.constraint(equalTo: self.urgentTag.widthAnchor, multiplier: ItemCell.urgentImage.size.height/ItemCell.urgentImage.size.width),
            self.urgentTag.leadingAnchor.constraint(equalTo: self.photo.leadingAnchor, constant: 0.0),
            self.urgentTag.topAnchor.constraint(equalTo: self.photo.topAnchor, constant: 0.0),

            self.imageLoader.centerXAnchor.constraint(equalTo: self.photo.centerXAnchor),
            self.imageLoader.centerYAnchor.constraint(equalTo: self.photo.centerYAnchor),
            
            // Price right aligned, centerY
            self.price.topAnchor.constraint(equalTo: self.topAnchor),
            self.price.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4.0),
            self.price.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0),
            self.price.widthAnchor.constraint(greaterThanOrEqualToConstant: 32.0),
            
            // Badges bottom aligned on photo.bottom
            self.categoryBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 0.0),
            self.categoryBadge.heightAnchor.constraint(greaterThanOrEqualToConstant: 0.0),
            self.categoryBadge.leadingAnchor.constraint(equalTo: self.title.leadingAnchor),
            self.categoryBadge.bottomAnchor.constraint(equalTo: self.photo.bottomAnchor, constant: -4.0),
            
            self.proBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 0.0),
            self.proBadge.heightAnchor.constraint(greaterThanOrEqualToConstant: 0.0),
            self.proBadge.leadingAnchor.constraint(equalTo: self.categoryBadge.trailingAnchor, constant: 8.0),
            self.proBadge.centerYAnchor.constraint(equalTo: self.categoryBadge.centerYAnchor),
            
            // top aligned on photo.top
            self.title.leadingAnchor.constraint(equalTo: self.photo.trailingAnchor, constant: 16.0),
            self.title.trailingAnchor.constraint(equalTo: self.price.leadingAnchor, constant: -16.0),
            self.title.topAnchor.constraint(equalTo: self.photo.topAnchor, constant: 4.0)
        ]

        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.title.text = nil
        self.photo.image = Self.noImage
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
       
        self.price.text = self.localePriceString
        self.title.text = self.item?.title ?? "<no title>"
        self.categoryBadge.text = self.item?.category?.name
        self.categoryBadge.isHidden = self.categoryBadge.text == nil
        self.proBadge.isHidden = !(self.item?.isPro ?? false)
        
        if let thumbUrl = self.item?.image.thumb {
        self.photoFetchRequest = AppNetwork.shared.fetchImage(imageUrlString: thumbUrl, { (data, error) in
            if let data = data {
                self.photo.image = UIImage(data: data)
            }
            else {
                // load default missing image
                self.photo.image = Self.noImage
            }
            
            self.imageLoader.stopAnimating()
            self.photoFetchRequest = nil
        })
            self.imageLoader.startAnimating()
        }
    }
    
    
}
