//
//  ItemsViewController.swift
//  LBC Sample
//
//  Created by Nicolas Buquet on 19/01/2021.
//

import Foundation
import UIKit

class ItemsViewController: AppBaseViewController {
    private static let CELL_REUSE_ID = #file + "_REUSE_ID"
    
    // Use collectionView to be able to easily display Cards on iPad (larger screen)
    lazy var collectionView: UICollectionView = { [unowned self] in
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .background
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: Self.CELL_REUSE_ID)
        
        // Add the refresh control to your UIScrollView object.
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action:#selector(pullToRefresh), for: .valueChanged)
        return collectionView
    }()
    
    var data = [Item]()
    
    override init() {
        super.init()
        self.reloadData()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "leBonCoinNavBarTitle"))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func pullToRefresh() {
        self.reloadData()
        
        // Dismiss the refresh control.
           DispatchQueue.main.async {
              self.collectionView.refreshControl?.endRefreshing()
           }
    }
    
    private func reloadData() {
        AppData.shared.fetchItems { (items, errorr) in
            guard let items = items
            else {
                // TODO: Display alert
                return
            }
            self.data.removeAll()
            self.data.append(contentsOf: items)
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.addSubview(self.collectionView)
        
        self.layoutContent()
    }
    
    func layoutContent() {
        self.view.translatesAutoresizingMaskIntoConstraints = true
        
        let constraints = [
            self.collectionView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0),
            self.collectionView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1.0),
            self.collectionView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.collectionView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
    }
}

extension ItemsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.CELL_REUSE_ID, for: indexPath) as! ItemCell
        // Populate cell
        cell.item = self.data[indexPath.row]
        return cell
    }
    
    
    
    
}

extension ItemsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 64.0)
    }
}
