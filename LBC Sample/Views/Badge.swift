//
//  Badge.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 19/01/2021.
//

import Foundation
import UIKit

class Badge: UILabel {
    static private let contentInsets = UIEdgeInsets(top: 4.0, left: 8.0, bottom: 4.0, right: 8.0)
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundColor = .second
        self.textColor = .white
        self.font = UI.itemCellBadgeFont
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
        super.drawText(in: rect.inset(by: Self.contentInsets))
        }
    
    override var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += Self.contentInsets.top + Self.contentInsets.bottom
        intrinsicSuperViewContentSize.width += Self.contentInsets.left + Self.contentInsets.right
        return intrinsicSuperViewContentSize
    }
}
