//
//  Float+Extension.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 21/01/2021.
//

import Foundation

extension Float {
    
    public var localePriceString: String? {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale(identifier: "fr_FR")
        return currencyFormatter.string(from: NSNumber(value: self))
    }
}
