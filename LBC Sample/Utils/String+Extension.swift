//
//  String+Extension.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 21/01/2021.
//

import Foundation
import UIKit

extension String {
    public func boundingRect(font: UIFont, constrainedToWidth constrainedWidth: CGFloat) -> CGRect {
        let attributedString = NSAttributedString(string: self, attributes: [NSAttributedString.Key.font: font])
        let rect = attributedString.boundingRect(with: CGSize(width: constrainedWidth, height: CGFloat.greatestFiniteMagnitude),
                                                 options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                 context: nil)
        return rect.integral
    }
}
