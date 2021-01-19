//
//  AppNetwork.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 18/01/2021.
//

import Foundation

enum AppNetworkError: String, Error {
    case fetchCategoriesError = "Error fetching categories list"
    case fetchItemsError = "Error fetching item list"
    case fetchImageError = "Error fetching image"
}


/// AppNetwork class is responsible of all network in/out.
/// It can be enhanced using a cache layer (NSCache?) to optimize costly resources access like images.
class AppNetwork {

    static private let FETCH_ITEMS_URL = "https://raw.githubusercontent.com/leboncoin/paperclip/master/listing.json"
    static private let FETCH_CATEGORIES_URL = "https://raw.githubusercontent.com/leboncoin/paperclip/master/categories.json"
  
    static let shared = AppNetwork()
    
    private let network = NBNetwork()
    
    public typealias FetchCompletion = (_ data: Data?, _ error: Error?) -> Void
        
    func fetchItems(_ completion: @escaping FetchCompletion) -> NBNetwork.Request {
        return self.get(Self.FETCH_ITEMS_URL, globalError: AppNetworkError.fetchItemsError, completion: completion)
    }
    
    func fetchCategories(_ completion: @escaping FetchCompletion) -> NBNetwork.Request {
        return self.get(Self.FETCH_CATEGORIES_URL, globalError: AppNetworkError.fetchItemsError, completion: completion)
    }

    func fetchImage(imageUrlString: String, _ completion: @escaping FetchCompletion) -> NBNetwork.Request {
        // TODO: look in cache and call completion if found.
        
        return self.get(imageUrlString, globalError: AppNetworkError.fetchImageError) { data, error in
            guard let data = data
            else {
                completion(nil, error ?? AppNetworkError.fetchImageError)
                return
            }
            
            // TODO: store recieved value in cache
            completion(data, nil)
        }
    }

    private func get(_ urlString: String, globalError: AppNetworkError, completion: @escaping FetchCompletion) -> NBNetwork.Request {
        let req = self.network.get(urlString: urlString)!
        self.network.start(req) { (request, response, error) in
            
            guard let responseIsOk = response?.statusCodeIsOk,
                  responseIsOk,
                let data = request.dataReceived
            else {
                DispatchQueue.main.async {
                    completion(nil, error ?? globalError)
                }
                return
            }
            DispatchQueue.main.async {
                completion(data, nil)
            }
        }
        return req
    }

}
