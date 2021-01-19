//
//  AppBaseViewController.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 18/01/2021.
//

import UIKit

class AppBaseViewController: UIViewController {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    // Set Default background color for any ViewController through the whole application.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.backgroundColor = .background
    }
    
}
