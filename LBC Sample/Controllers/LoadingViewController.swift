//
//  LoadingViewController.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 20/01/2021.
//

import Foundation
import UIKit

class LoadingViewController: AppBaseViewController {
    let message: UILabel = {
        let lbl = UILabel(text: NSLocalizedString("Loading.message", comment: ""))
        lbl.font = UI.loadingFont
        lbl.numberOfLines = 1
        lbl.textColor = .text
        return lbl
    }()
    
    let loader: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: .gray)
        aiView.translatesAutoresizingMaskIntoConstraints = false
        aiView.hidesWhenStopped = true
        aiView.stopAnimating() // start stopped and hidden
        return aiView
    }()
    
    override init() {
        super.init()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "leBonCoinNavBarTitle"))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.addSubview(self.loader)
        self.view.addSubview(self.message)
        
        self.layoutContent()
        
        self.requestData()
    }
    
    func layoutContent() {
        self.view.translatesAutoresizingMaskIntoConstraints = true
        
        let constraints = [
            self.loader.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.loader.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.message.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.message.topAnchor.constraint(equalTo: self.loader.bottomAnchor, constant: 32.0),
        ]

        NSLayoutConstraint.activate(constraints)
    }
    
    private func requestData() {
        self.loader.startAnimating()
        AppData.shared.fetchData { (success, error) in
            self.loader.stopAnimating()
            guard success else {
                let action = UIAlertAction(title: NSLocalizedString("Loading.network.error.button.retry", comment: ""), style: .default) { (action) in
                    self.requestData()
                }
                (self.navigationController as? AppNavigationController)?.displayAlert(title: NSLocalizedString("Loading.network.error.title", comment: ""),
                                                                                      message: NSLocalizedString("Loading.network.error.message", comment: ""), actions: [action])
                return
            }
            self.navigationController?.setViewControllers([ItemsViewController()], animated: true)
        }
    }
}
