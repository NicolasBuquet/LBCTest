//
//  Badge.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 19/01/2021.
//

import Foundation
import UIKit

class Badge: UILabel {
    static private let contentInsetsSmall = UIEdgeInsets(top: 4.0, left: 8.0, bottom: 4.0, right: 8.0)
    static private let contentInsetsBig = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0)
    
    static func pro() -> Badge {
        let proBadge = Badge(.small)
        proBadge.baseColor = .main
        proBadge.text = NSLocalizedString("Badge.label.professional", comment: "")
        return proBadge
    }
    
    enum Size {
        case small, medium, big
    }
    
    private let contentInsets: UIEdgeInsets
    
    var isSelected = false {
        didSet {
            self.backgroundColor = self.isSelected ? .main : self.baseColor
        }
    }
    
    public var isActionEnabled = false {
        didSet {
            if self.isActionEnabled {
                self.addGestureRecognizer(self.tapGesture)
                self.isUserInteractionEnabled = true
            }
            else {
                self.removeGestureRecognizer(self.tapGesture)
                self.isUserInteractionEnabled = false
            }
        }
    }
    
    lazy var tapGesture: UITapGestureRecognizer = { [unowned self] in
        let gesture = UITapGestureRecognizer(target: self, action: #selector(select(gestureRecognizer:)))
        return gesture
    }()
    
    public var baseColor = UIColor.second {
        didSet {
            self.backgroundColor = self.baseColor
        }
    }
    
    required init(_ size: Size? = .small) {
        self.contentInsets = size == .big ? Self.contentInsetsBig : Self.contentInsetsSmall

        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.baseColor = .second
        self.backgroundColor = self.baseColor
        
        self.textColor = .white
        self.font = size == .big ? UI.badgeBigFont : size == .medium ? UI.badgeMediumFont : UI.badgeSmallFont
     }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.bounds.size.height * 0.5
    }
 
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: self.contentInsets))
    }
    
    override var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += self.contentInsets.top + self.contentInsets.bottom
        intrinsicSuperViewContentSize.width += self.contentInsets.left + self.contentInsets.right
        return intrinsicSuperViewContentSize
    }
    
    @objc func select(gestureRecognizer: UITapGestureRecognizer) {
        print(#function)
        self.isSelected = !self.isSelected
    }
    
}
