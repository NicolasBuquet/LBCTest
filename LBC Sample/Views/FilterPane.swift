//
//  SortPane.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 20/01/2021.
//

import Foundation
import UIKit

class FilterPane : UIView {
    
    required override init(frame: CGRect) {
        super.init(frame :frame)
        
        self.backgroundColor = .blue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 160.0, height: 380.0)
    }
}
