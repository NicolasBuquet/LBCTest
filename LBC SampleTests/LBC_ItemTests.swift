//
//  LBC_ItemTests.swift
//  LBC SampleTests
//
//  Created by Nicolas Buquet on 18/01/2021.
//

import XCTest
@testable import LBC_Sample

class LBC_ItemTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testDecode() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        print("Unit test: Item DECODE started")
        
        //--------------------------------------------------------------------------------
        // Test decode of fully structured json item.
        //--------------------------------------------------------------------------------
        
        let itemFullJsonString = """
{
      "id":1664493117,
      "category_id":9,
      "title":"Professeur natif d'espagnol à domicile",
      "description":"Doctorant espagnol, ayant fait des études de linguistique comparée français - espagnol et de traduction (thème/version) 0 la Sorbonne, je vous propose des cours d'espagnol à domicile à Paris intramuros. Actuellement j'enseigne l'espagnol dans un lycée et j'ai plus de cinq ans d'expérience comme professeur particulier, à Paris et à Madrid. Tous les niveaux, tous les âges. Je m'adapte à vos besoins et vous propose une méthode personnalisée et dynamique, selon vos point forts et vos points faibles, pour mieux travailler votre :  - Expression orale - Compréhension orale - Grammaire - Vocabulaire - Production écrite - Compréhension écrite Tarif : 25 euros/heure",
      "price":25.00,
      "images_url":{
         "small":"https://raw.githubusercontent.com/leboncoin/paperclip/master/ad-small/af9c43ff5a3b3692f9f1aa3c17d7b46d8b740311.jpg",
         "thumb":"https://raw.githubusercontent.com/leboncoin/paperclip/master/ad-thumb/af9c43ff5a3b3692f9f1aa3c17d7b46d8b740311.jpg"
      },
      "creation_date":"2019-11-05T15:56:55+0000",
      "is_urgent":false,
      "siret":"123 323 002"
   }
"""
        var jsonData = itemFullJsonString.data(using: .utf8)!
        var item = try? Item.decoder.decode(Item.self, from: jsonData)
        XCTAssert(item != nil, "ItemDecode: failure for full Json")
        
        //--------------------------------------------------------------------------------
        // Test decode of missing SIRET json item.
        //--------------------------------------------------------------------------------

        let itemNoSiretJsonString = """
{
      "id":1461267313,
      "category_id":4,
      "title":"Statue homme noir assis en plâtre polychrome",
      "description":"Magnifique Statuette homme noir assis fumant le cigare en terre cuite et plâtre polychrome réalisée à la main.  Poids  1,900 kg en très bon état, aucun éclat  !  Hauteur 18 cm  Largeur : 16 cm Profondeur : 18cm  Création Jacky SAMSON  OPTIMUM  PARIS  Possibilité de remise sur place en gare de Fontainebleau ou Paris gare de Lyon, en espèces (heure et jour du rendez-vous au choix). Envoi possible ! Si cet article est toujours visible sur le site c'est qu'il est encore disponible",
      "price":140.00,
      "images_url":{
         "small":"https://raw.githubusercontent.com/leboncoin/paperclip/master/ad-small/2c9563bbe85f12a5dcaeb2c40989182463270404.jpg",
         "thumb":"https://raw.githubusercontent.com/leboncoin/paperclip/master/ad-thumb/2c9563bbe85f12a5dcaeb2c40989182463270404.jpg"
      },
      "creation_date":"2019-11-05T15:56:59+0000",
      "is_urgent":false
   }
"""

        jsonData = itemNoSiretJsonString.data(using: .utf8)!
        item = try? Item.decoder.decode(Item.self, from: jsonData)
        XCTAssert(item != nil, "ItemDecode: failure for missing SIRET Json")
        
        //--------------------------------------------------------------------------------
        // Test decode of missing IMAGES_URL content json item.
        //--------------------------------------------------------------------------------

        let itemNoImageJsonString = """
{
   "id":1702200362,
   "category_id":6,
   "title":"Fond de commerce rue saint honoré",
   "description":"Je vend une boucherie  très bien placé rue saint honoré  bonne clientèle . La boutique se compose d'un RDC de 140 m²  avec deux sous sol de 75 m² chacun et un ascenseur qui dessert les niveaux . Le prix de la session est à moins de 70% du CA",
   "price":600000.00,
   "images_url":{

   },
   "creation_date":"2019-11-06T11:19:13+0000",
   "is_urgent":false
}
"""

        jsonData = itemNoImageJsonString.data(using: .utf8)!
        item = try? Item.decoder.decode(Item.self, from: jsonData)
        XCTAssert(item != nil, "ItemDecode: failure for missing IMAGES Json")
        
        print("Unit test: Item DECODE ended")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
