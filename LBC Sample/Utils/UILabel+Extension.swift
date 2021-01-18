//
//  View+Extension.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 18/01/2021.
//

import Foundation
import UIKit

extension UILabel {
    // Disable all auto-resing masks on UILabel
    convenience init(text: String?) {
        self.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.text = "Application launched"
        self.textColor = UIColor(named: "mainColor")
        self.sizeToFit()
    }
}
