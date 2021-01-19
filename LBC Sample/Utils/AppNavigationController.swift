//
//  AppNavigationController.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 19/01/2021.
//

import Foundation
import UIKit

class AppNavigationController: UINavigationController {
    override var shouldAutorotate: Bool { return self.topViewController?.shouldAutorotate ?? true }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    override var prefersStatusBarHidden: Bool { return false }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        self.delegate = self
        self._customize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func _customize() {
        self.navigationBar.barTintColor = .main
        self.navigationBar.isTranslucent = false
        self.navigationBar.tintColor = .white
//        self.navigationBar.titleTextAttributes = NSAttributedString.attributedStyle(withName: "text/navigationBar/title")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .background

    }
    
    func displayAlert(title: String?, message: String?, actions: [UIAlertAction], preferredActionIndex: Int = -1) {
        DispatchQueue.main.async {
            let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .alert)
            for action in actions {
                alertCtrl.addAction(action)
            }
            if preferredActionIndex >= 0 && preferredActionIndex < alertCtrl.actions.count {
                alertCtrl.preferredAction = alertCtrl.actions[preferredActionIndex]
            }
            
            self.present(alertCtrl, animated: true, completion: nil)
        }
    }

}

extension AppNavigationController : UINavigationControllerDelegate {
//    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
////        viewController.view.frame = navigationController.view.bounds
//
//    }
    
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return navigationController.topViewController?.supportedInterfaceOrientations ?? .portrait
    }
}
