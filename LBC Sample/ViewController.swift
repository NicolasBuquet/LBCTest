//
//  ViewController.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 18/01/2021.
//

import UIKit

class ViewController: AppBaseViewController {

    var label = UILabel(text: "Application launched")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.label)
        
        let constraints = [
            self.label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
        
        AppData.shared.fetchItems { (items, error) in
            print(items?.count)
            print(error)
        }
        AppData.shared.fetchCategories { (categories, error) in
            print(categories)
            print(error)
        }
    }

}

