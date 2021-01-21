//
//  ItemDetailViewController.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 20/01/2021.
//

import Foundation
import UIKit

class ItemDetailViewController: AppBaseViewController {
    private static let CELL_REUSE_ID = #file + "_REUSE_ID"
    
    private static let noImage = UIImage(named: "noImage")
    private static let urgentImage = UIImage(named: "urgent")! // load resource image only once.

    private static let insets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0)
    private static let categoryInsets = UIEdgeInsets(top: 32.0, left: 16.0, bottom: 32.0, right: 16.0)
    private static let urgentTagInsets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
    private static let photoInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
    private static let titleInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
    private static let headerInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 4.0, right: 16.0)
    private static let labelInsets = UIEdgeInsets(top: 4.0, left: 16.0, bottom: 16.0, right: 16.0)
    
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        df.locale = Locale(identifier: "fr_FR")
        return df
    }()
    
    enum InfoPart: Int {
        case category = 0
        case photo = 1
        case title = 2
        case descriptionHeader = 3
        case description = 4
        case dateHeader = 5
        case date = 6
        case professionalHeader = 7
        case professional = 8
        
        static let count = 9
    }
    
    // Use collectionView to be able to easily display Cards on iPad (larger screen)
    lazy var collectionView: UICollectionView = { [unowned self] in
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = true
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Self.CELL_REUSE_ID)
        
        return collectionView
    }()
    
    lazy var categoryBadge: Badge = { [unowned self] in
        let badge = Badge(.big)
        badge.text = self.item.category?.name ?? NSLocalizedString("ItemDetail.noCategory", comment: "")
        return badge
    }()
    
    lazy var priceLabel: UILabel = { [unowned self] in
        let lbl = UILabel(text: self.item.price.localePriceString)
        lbl.font = UI.itemDetailPriceFont
        lbl.numberOfLines = 1
        lbl.textColor = .main
        return lbl
    }()
    
    lazy var photo: UIImageView = { [unowned self] in
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(self.imageLoader)
        
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = .zero
        imageView.layer.shadowRadius = 4.0
        imageView.layer.shadowOpacity = 0.25
        
        let constraints = [
            self.imageLoader.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            self.imageLoader.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
        
        return imageView
    }()
    
    let imageLoader: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: .gray)
        aiView.translatesAutoresizingMaskIntoConstraints = false
        aiView.hidesWhenStopped = true
        aiView.stopAnimating() // start stopped and hidden
        return aiView
    }()
    
    let urgentTag: UIImageView = {
        let imageView = UIImageView(image: ItemListCell.urgentImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var titleLabel: UILabel = { [unowned self] in
        let lbl = UILabel(text: self.item.title)
        lbl.font = UI.itemDetailTitleFont
        lbl.numberOfLines = 0
        lbl.textColor = .text
        return lbl
    }()
    
    let descriptionHeader: Badge = {
        let badge = Badge(.medium)
        badge.text = NSLocalizedString("ItemDetail.description.title", comment: "")
        return badge
    }()
    
    lazy var descriptionLabel: UILabel = { [unowned self] in
        let lbl = UILabel(text: self.item.description)
        lbl.font = UI.itemDetailDescriptionFont
        lbl.numberOfLines = 0
        lbl.textColor = .text
        lbl.textAlignment = .justified
        return lbl
    }()

    let dateHeader: Badge = {
        let badge = Badge(.medium)
        badge.text = NSLocalizedString("ItemDetail.date.title", comment: "")
        return badge
    }()
    
    lazy var dateLabel: UILabel = { [unowned self] in
        let lbl = UILabel(text: String(format: NSLocalizedString("ItemDetail.date.message", comment: ""), Self.dateFormatter.string(from: self.item.creationDate)))
        lbl.font = UI.itemDetailInformationFont
        lbl.numberOfLines = 0
        lbl.textColor = .text
        return lbl
    }()
    
    let professionalHeader: Badge = {
        let badge = Badge(.medium)
        badge.text = NSLocalizedString("ItemDetail.professional.title", comment: "")
        badge.baseColor = .main
        return badge
    }()
    
    lazy var professionalLabel: UILabel = { [unowned self] in
        let lbl = UILabel(text: String(format: NSLocalizedString("ItemDetail.professional.message", comment: ""), self.item.siret!))
        lbl.font = UI.itemDetailInformationFont
        lbl.numberOfLines = 0
        lbl.textColor = .text
        return lbl
    }()
    
    let item: Item
    
    init(item: Item) {
        self.item = item
        
        super.init()
                
        self.navigationItem.title = item.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.addSubview(self.collectionView)
        
        self.layoutContent()
    }
    
    func layoutContent() {
        self.view.translatesAutoresizingMaskIntoConstraints = true
        
        let constraints = [
            self.collectionView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            self.collectionView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            self.collectionView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.collectionView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
    }
    
    private func populateCellCategory(_ cell: UICollectionViewCell) {
        cell.contentView.addSubview(self.categoryBadge)
        cell.contentView.addSubview(self.priceLabel)
        
        var constraints = [
            self.categoryBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 0.0),
            self.categoryBadge.heightAnchor.constraint(greaterThanOrEqualToConstant: 0.0),
            self.categoryBadge.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: Self.categoryInsets.left),
            self.categoryBadge.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: Self.categoryInsets.top),
            self.categoryBadge.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -Self.categoryInsets.bottom),
            self.priceLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 0.0),
            self.priceLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 0.0),
            self.priceLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            self.priceLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -Self.categoryInsets.right),
       ]

        if self.item.isUrgent {
            cell.contentView.addSubview(self.urgentTag)
            constraints.append(contentsOf: [
                self.urgentTag.heightAnchor.constraint(equalTo: self.categoryBadge.heightAnchor, constant: -Self.urgentTagInsets.top - Self.urgentTagInsets.bottom),
                self.urgentTag.widthAnchor.constraint(equalTo: self.urgentTag.heightAnchor, multiplier: ItemListCell.urgentImage.size.width/ItemListCell.urgentImage.size.height),
                self.urgentTag.leadingAnchor.constraint(equalTo: self.categoryBadge.trailingAnchor, constant: Self.urgentTagInsets.left),
                self.urgentTag.centerYAnchor.constraint(equalTo: self.categoryBadge.centerYAnchor),
            ])
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func populateCellPhoto(_ cell: UICollectionViewCell) {
        // Verify if item has photo.
        guard let photoUrl = self.item.image.small else {
            return
        }
        
        // load photo from network
        _ = AppNetwork.shared.fetchImage(imageUrlString: photoUrl, { (data, error) in
            if let data = data {
                self.photo.image = UIImage(data: data)
            }
            else {
                // load default missing image
                self.photo.image = Self.noImage
            }
            
            self.imageLoader.stopAnimating()
        })
        
        self.imageLoader.startAnimating()
        
        cell.contentView.addSubview(self.photo)
        
        let constraints = [
            self.photo.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: Self.photoInsets.left),
            self.photo.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -Self.photoInsets.right),
            self.photo.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: Self.photoInsets.top),
            self.photo.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -Self.photoInsets.bottom)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func populateCellTitle(_ cell: UICollectionViewCell) {
        cell.contentView.addSubview(self.titleLabel)
        
        let constraints = [
            self.titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: Self.titleInsets.left),
            self.titleLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -Self.titleInsets.right),
            self.titleLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: Self.titleInsets.top),
            self.titleLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -Self.titleInsets.bottom)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func populateCellHeader(_ cell: UICollectionViewCell, headerView: UIView) {
        cell.contentView.addSubview(headerView)
        
        let constraints = [
            headerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 0.0),
            headerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0.0),
            headerView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: Self.headerInsets.left),
            headerView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: Self.headerInsets.top),
            headerView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -Self.headerInsets.bottom),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func populateCellLabel(_ cell: UICollectionViewCell, labelView: UILabel) {
        cell.contentView.addSubview(labelView)
        
        let constraints = [
            labelView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: Self.labelInsets.left),
            labelView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -Self.labelInsets.right),
            labelView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: Self.labelInsets.top),
            labelView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -Self.labelInsets.bottom)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }

    private func populateCellDescriptionHeader(_ cell: UICollectionViewCell) {
        self.populateCellHeader(cell, headerView: self.descriptionHeader)
    }
    
    private func populateCellDescription(_ cell: UICollectionViewCell) {
        self.populateCellLabel(cell, labelView: self.descriptionLabel)
    }

    private func populateCellDateHeader(_ cell: UICollectionViewCell) {
        self.populateCellHeader(cell, headerView: self.dateHeader)
    }

    private func populateCellDate(_ cell: UICollectionViewCell) {
        self.populateCellLabel(cell, labelView: self.dateLabel)
    }

    private func populateCellProfessionalHeader(_ cell: UICollectionViewCell) {
        self.populateCellHeader(cell, headerView: self.professionalHeader)
    }

    private func populateCellProfessional(_ cell: UICollectionViewCell) {
        self.populateCellLabel(cell, labelView: self.professionalLabel)
    }
}

extension ItemDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.item.isProfessional ? InfoPart.count : (InfoPart.count - 2)
//        return InfoPart.count // Category + urgent, image, title + price, description, date, pro?
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.CELL_REUSE_ID, for: indexPath)

        // Remove previous content from recycling cell
        cell.contentView.removeAllSubviews()
        
        switch InfoPart(rawValue: indexPath.row) {
        case .category: self.populateCellCategory(cell)
        case .photo: self.populateCellPhoto(cell)
        case .title: self.populateCellTitle(cell)
        case .descriptionHeader: self.populateCellDescriptionHeader(cell)
        case .description: self.populateCellDescription(cell)
        case .dateHeader: self.populateCellDateHeader(cell)
        case .date: self.populateCellDate(cell)
        case .professionalHeader: self.populateCellProfessionalHeader(cell)
        case .professional: self.populateCellProfessional(cell)

        default:
            return cell
        }
        
        return cell
    }
    
}

extension ItemDetailViewController: UICollectionViewDelegateFlowLayout {
    private func labelHeightFor(collectionView: UICollectionView, labelView: UILabel, insets: UIEdgeInsets) -> CGFloat {
        return (labelView.text ?? "").boundingRect(font: labelView.font, constrainedToWidth: collectionView.frame.size.width - insets.left - insets.right).size.height + insets.top + insets.bottom
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height = CGFloat(64.0) // Default height

        switch InfoPart(rawValue: indexPath.row) {
        case .category: height = self.categoryBadge.intrinsicContentSize.height + Self.categoryInsets.top + Self.categoryInsets.bottom
        case .photo: height = 140.0 // Default image size returned by API
        case .title: height = self.labelHeightFor(collectionView: collectionView, labelView: self.titleLabel, insets: Self.titleInsets)
        case .descriptionHeader: height = self.descriptionHeader.intrinsicContentSize.height + Self.headerInsets.top + Self.headerInsets.bottom
        case .description: height = self.labelHeightFor(collectionView: collectionView, labelView: self.descriptionLabel, insets: Self.labelInsets)
        case .dateHeader: height = self.dateHeader.intrinsicContentSize.height + Self.headerInsets.top + Self.headerInsets.bottom
        case .date: height = self.labelHeightFor(collectionView: collectionView, labelView: self.dateLabel, insets: Self.labelInsets)
        case .professionalHeader: height = self.professionalHeader.intrinsicContentSize.height + Self.headerInsets.top + Self.headerInsets.bottom
        case .professional: height = self.labelHeightFor(collectionView: collectionView, labelView: self.professionalLabel, insets: Self.labelInsets)
        
        default: height = 64.0
        }
        return CGSize(width: collectionView.bounds.size.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
