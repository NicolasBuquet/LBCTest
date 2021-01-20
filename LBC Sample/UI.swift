//
//  UI.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 19/01/2021.
//

import Foundation
import UIKit

class UI {
    static let navigationBarTitle = UIFont.systemFont(ofSize: 21.0)
    static let itemCellTitleFont = UIFont.systemFont(ofSize: 14.0)
    static let itemCellPriceFont = UIFont.boldSystemFont(ofSize: 18.0)
    static let itemCellBadgeSmallFont = UIFont.boldSystemFont(ofSize: 10.0)
    static let itemCellBadgeBigFont = UIFont.boldSystemFont(ofSize: 18.0)
    static let loadingFont = UIFont.systemFont(ofSize: 14.0)
}

extension UIColor {
    static let main = UIColor(named: "mainColor")
    static let second = UIColor(named: "secondColor")
    static let text = UIColor(named: "textColor")
    static let background = UIColor(named: "backgroundColor")
    static let navigationItem = UIColor.white
}
