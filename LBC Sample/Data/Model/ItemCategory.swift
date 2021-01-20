//
//  ItemCategory.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 19/01/2021.
//

import Foundation

struct ItemCategory: Decodable {
    let id: Int
    let name: String
    
    static func parse(from data: Data) -> [ItemCategory]? {
        return try? Item.decoder.decode([ItemCategory].self, from: data)
    }
}
