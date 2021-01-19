//
//  Item.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 18/01/2021.
//

import Foundation

struct Item {
    // Item are fetched as JSON file containing the following variations:
    // - {"id":,"category_id":,"title":,"description":,"price":,"images_url":{},"creation_date":,"is_urgent":}
    // - {"id":,"category_id":,"title":,"description":,"price":,"images_url":{"small":,"thumb":,"creation_date":,"is_urgent":}
    // - {"id":,"category_id":,"title":,"description":,"price":,"images_url":{"small":,"thumb":,"creation_date":,"is_urgent":,"siret":}

    let id: Int
    let categoryId: Int
    let category: Category?
    let title: String
    let description: String
    let price: Float
    
    let image: (small: String?, thumb: String?)
    
    let creationDate: Date // migrate to native Date format
    let isUrgent: Bool
    
    let siret: String?
    
    var isImagePresent: Bool { self.image.small != nil && self.image.thumb != nil }
}

extension Item: Decodable {

    // Global Item decoder with awaited Date format.
    static public let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // set received Date expected format
        return decoder
    }()
    
    enum CodingKeys: String, CodingKey {
      case id, categoryId = "category_id", title, description, price, image = "images_url", creationDate = "creation_date", isUrgent = "is_urgent", siret
    }
    
    enum ImageKeys: CodingKey {
      case small, thumb
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.categoryId = try container.decode(Int.self, forKey: .categoryId)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.price = try container.decode(Float.self, forKey: .price)
      
        self.creationDate = try container.decode(Date.self, forKey: .creationDate)
        self.isUrgent = try container.decode(Bool.self, forKey: .isUrgent)
        self.siret = try? container.decode(String.self, forKey: .siret)
      
        if let imageContainer = try? container.nestedContainer(keyedBy: ImageKeys.self, forKey: .image) {
            self.image = (small: try? imageContainer.decode(String.self, forKey: .small), thumb: try? imageContainer.decode(String.self, forKey: .thumb))
        }
        else {
            self.image = (small: nil, thumb: nil)
        }
        
        self.category = AppData.shared.category(id: self.categoryId)
    }
}

