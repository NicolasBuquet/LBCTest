//
//  AppNetwork.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 18/01/2021.
//

import Foundation

class AppNetwork {
    static private let FETCH_ITEMS_URL = "https://raw.githubusercontent.com/leboncoin/paperclip/master/listing.json"
    
    static let shared = AppNetwork()
    
    public typealias FetchItemsCompletion = (_ items: [Item]?, _ error: Error?) -> Void
   
    private let network = NBNetwork()
    
    func fetchItemList(_ completion: @escaping FetchItemsCompletion) {
        let req = self.network.get(urlString: Self.FETCH_ITEMS_URL)!
        self.network.start(req) { (request, response, error) in
            
            guard let responseIsOk = response?.statusCodeIsOk,
                  responseIsOk,
                let jsonData = request.dataReceived,
                let items = try? Item.decoder.decode([Item].self, from: jsonData)
            else {
                completion(nil, nil)
                return
            }
            completion(items, nil)
        }
    }
}
