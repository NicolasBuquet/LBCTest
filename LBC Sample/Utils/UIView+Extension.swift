//
//  UIView+Extension.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 21/01/2021.
//

import UIKit

extension UIView {
    public func removeAllSubviews() {
        self.subviews.forEach { $0.removeFromSuperview() }
    }
}
