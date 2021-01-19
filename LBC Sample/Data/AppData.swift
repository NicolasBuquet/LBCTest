//
//  AppData.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 19/01/2021.
//

import Foundation

/// AppData class is designed to be the unique access point to application's data (actually items ans item's category)
class AppData {
    public typealias FetchItemsCompletion = (_ items: [Item]?, _ error: Error?) -> Void
    public typealias FetchCategoriesCompletion = (_ items: [Category]?, _ error: Error?) -> Void
   
    public static let shared = AppData()
    
    private let network = AppNetwork.shared
    
    
    func fetchItems(_ completion: @escaping FetchItemsCompletion) {
        self.network.fetchItems { (data, error) in
            guard error == nil,
                  let data = data,
                  let items = try? Item.decoder.decode([Item].self, from: data)
                 
            else {
                completion(nil, error)
                return
            }
            completion(items, nil)
        }
    }
    
    func fetchCategories(_ completion: @escaping FetchCategoriesCompletion) {
        self.network.fetchCategories { (data, error) in
            guard error == nil,
                  let data = data,
                  let items = try? JSONDecoder().decode([Category].self, from: data)
                 
            else {
                completion(nil, error)
                return
            }
            completion(items, nil)
        }
    }
    
    
}


