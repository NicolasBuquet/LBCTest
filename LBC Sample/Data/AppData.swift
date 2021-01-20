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
    public typealias FetchCategoriesCompletion = (_ items: [ItemCategory]?, _ error: Error?) -> Void
    public typealias FetchDataCompletion = (_ success: Bool, _ error: Error?) -> Void
    
    public static let shared = AppData()
    
    private let network = AppNetwork.shared
    
    public var categories = [ItemCategory]()
    public var items = [Item]()
    
    
    init() {
        
    }
    
    func fetchData(completion: @escaping FetchDataCompletion) {
        self.fetchCategories { (categories, error) in
            if let error = error {
                completion(false, error)
            }
            else {
                self.fetchItems { (items, error) in
                    if let error = error {
                        completion(false, error)
                    }
                    else {
                        completion(true, nil)
                    }
                }
            }
        }
    }
    
    func fetchItems(_ completion: @escaping FetchItemsCompletion) {
        /// Fetch from network a a JSON list of items of type :
        /// {
        ///    "id":1690741140,
        ///    "category_id":8,
        ///    "title":"Pc Portable HP ProBook 655 G1 i5 / 4Go RAM / 256Go SSD",
        ///    "description":"Nous vous proposons cet ordinateur portable reconditionnée testé et vérifié sur plus de 30 points de tests par de véritables professionnels : Ordinateur portable HP ProBook 655 G1 Processeur : AMD A10-5750 2,5GHz Mémoire Vive : 4 Go (+39 € pour 4 Go supplémentaire) Disque dur : 256 Go SSD Carte graphique : Intel® HD Graphics Carte son : Intégrée Réseau : GigaBit Ethernet + WIFI Clavier : AZERTY français Ecran : 15.4  et Webcam. HDMI, Nombreux ports USB... Système d'exploitation installé : Microsoft Windows 10 Professionnel 64 bits. Logiciel installé : Antivirus Gratuit , VLC , Adobe Reader , Skype , Google Chrome , Mozilla FireFox , OpenOffice ( Traitement texte , tableur ... ) Cet ordinateur est prêt à l'emploi ! Tous nos ordinateurs sont vendus avec une facture et une GARANTIE 1 AN !! Pour toute information vous pouvez nous appeler. Boostez ce PC PORTABLE : Passez à la vitesse supérieure en augmentant la RAM : Pour passer de 4 Go à 8 Go de RAM = 39€ SEULEMENT ! (rajout rapide, doublez la vitesse en 5mn sur place !!!) Pour passer de 4 Go à 12 Go de RAM = 75€ SEULEMENT ! (rajout rapide, doublez la vitesse en 5mn sur place !!!) Stockez plus en augmenter votre disque dur : Passer en 500 Go SSD = 169€ !!!!! *Sous Réserve de disponibilité et de compatibilité des pièces avec l'appareil concerné",
        ///    "price":329.00,
        ///    "images_url":{
        ///       "small":"https://raw.githubusercontent.com/leboncoin/paperclip/master/ad-small/b810512aa2fa5fe3ae46281ad91b6bd112ba40c3.jpg",
        ///       "thumb":"https://raw.githubusercontent.com/leboncoin/paperclip/master/ad-thumb/b810512aa2fa5fe3ae46281ad91b6bd112ba40c3.jpg"
        ///    },
        ///    "creation_date":"2019-10-15T16:52:20+0000",
        ///    "is_urgent":false,
        ///    "siret":"343 430 542"
        /// }
        /// "siret" is optional
        /// "images_url" can be empty
        
        let _ = self.network.fetchItems { (data, error) in
            guard error == nil,
                  let data = data,
                  let items = Item.parse(from: data)
            else {
                completion(nil, error)
                return
            }
            self.items.removeAll()
            self.items.append(contentsOf: items)
            completion(items, nil)
        }
    }
    
    
    func fetchCategories(_ completion: @escaping FetchCategoriesCompletion) {
        let _ = self.network.fetchCategories { (data, error) in
            guard error == nil,
                  let data = data,
                  let categories = ItemCategory.parse(from: data)
                 
            else {
                completion(nil, error)
                return
            }
            self.categories.removeAll()
            self.categories.append(contentsOf: categories)
            completion(categories, nil)
        }
    }
    
    func category(id: Int) -> ItemCategory? {
        return self.categories.first(where: { $0.id == id})
    }
    
}


