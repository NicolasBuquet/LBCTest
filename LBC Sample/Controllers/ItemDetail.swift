//
//  ItemDetail.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 20/01/2021.
//

import Foundation
import UIKit

class ItemDetail: AppBaseViewController {
    let message: UILabel = {
        let lbl = UILabel(text: "Item Detail…")
        lbl.font = UI.loadingFont
        lbl.numberOfLines = 1
        lbl.textColor = .text
        return lbl
    }()
    
    let item: Item
    
    init(item: Item) {
        self.item = item
        
        super.init()
                
        self.navigationItem.title = item.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.addSubview(self.message)
        
        self.layoutContent()
    }
    
    func layoutContent() {
        self.view.translatesAutoresizingMaskIntoConstraints = true
        
        let constraints = [
            self.message.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.message.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
    }
    
}
