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
        collectionView.showsVerticalScrollIndicator = true
        
        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: Self.CELL_REUSE_ID)
        
        // Add the refresh control to your UIScrollView object.
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action:#selector(pullToRefresh), for: .valueChanged)
        return collectionView
    }()
    
    var data = [Item]()
    
    var filteredData = [Item]()
    var filterCategory: ItemCategory? {
        didSet {
            self.filterData()
        }
    }
    
    lazy var filterBarButton: UIBarButtonItem = { [unowned self] in
        return UIBarButtonItem(image: #imageLiteral(resourceName: "sort"), style: .plain, target: self, action: #selector(toggleFilterPane))
    }()
    
    override init() {
        super.init()
        
        self.data = AppData.sortedItems(AppData.shared.items)
        self.filterData()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "leBonCoinNavBarTitle"))

        self.navigationItem.rightBarButtonItems = [self.filterBarButton]
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
    
    private func filterData() {
        if let filterCategory = self.filterCategory {
            self.filteredData = self.data.filter { $0.category == filterCategory }
        }
        else {
            self.filteredData = self.data
        }
        // Refresh UI (filterBarButton colored if filter active)
        self.filterBarButton.tintColor = self.filterCategory == nil ? nil : .second
        self.collectionView.reloadData()
    }
    
    private func reloadData() {
        AppData.shared.fetchItems { (items, errorr) in
            guard let items = items
            else {
                // TODO: Display alert
                return
            }
            self.data = AppData.sortedItems(items)
            self.filterData()
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
            self.collectionView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            self.collectionView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            self.collectionView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.collectionView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
    }
    
    var blockingView: UIView?
    var filterPane: FilterPane?
    var filterPaneTopConstraint: NSLayoutConstraint?
    
    @objc func toggleFilterPane() {
        self.filterBarButton.isEnabled = false
        
        if let filterPane = self.filterPane {
            UIView.animate(withDuration: 0.33) {
                self.filterPaneTopConstraint?.constant = 0.0
                self.blockingView?.alpha = 0.0
                self.view.layoutIfNeeded()
            } completion: { (finished) in
                filterPane.removeFromSuperview()
                self.blockingView?.removeFromSuperview()
                self.filterPane = nil
                self.blockingView = nil
                self.filterBarButton.isEnabled = true
            }
        }
        else {
            self.blockingView = UIView(frame: .zero)
            self.blockingView?.translatesAutoresizingMaskIntoConstraints = false
            self.blockingView?.backgroundColor = UIColor(white: 0.0, alpha: 0.25)
            self.blockingView?.alpha = 0.0
            
            let tapToClose = UITapGestureRecognizer(target: self, action: #selector(self.toggleFilterPane))
            self.blockingView?.addGestureRecognizer(tapToClose)
            
            self.view.addSubview(self.blockingView!)
            
            self.filterPane = FilterPane(currentCategory: self.filterCategory, completion: { (selectedCategory) in
                self.filterCategory = selectedCategory
                self.toggleFilterPane()
            })
            self.view.addSubview(self.filterPane!)
            
            self.filterPaneTopConstraint = self.filterPane!.bottomAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0)
            let constraints = [
                self.blockingView!.widthAnchor.constraint(equalTo: self.view.widthAnchor),
                self.blockingView!.heightAnchor.constraint(equalTo: self.view.heightAnchor),
                self.blockingView!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                self.blockingView!.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                self.filterPane!.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5),
                self.filterPane!.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.5),
                self.filterPane!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -4.0),
                filterPaneTopConstraint!,
            ]

            NSLayoutConstraint.activate(constraints)
            self.view.layoutIfNeeded()
           
            UIView.animate(withDuration: 0.33) {
                self.blockingView?.alpha = 1.0
                self.filterPaneTopConstraint?.constant = self.filterPane!.frame.size.height + 4.0
                self.view.layoutIfNeeded()
            } completion: { (finished) in
                self.filterBarButton.isEnabled = true
            }
        }
        
    }

}

extension ItemsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.CELL_REUSE_ID, for: indexPath) as! ItemCell
        // Populate cell
        cell.item = self.filteredData[indexPath.row]
        return cell
    }
}

extension ItemsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 80.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = self.filteredData[indexPath.row]
        self.navigationController?.pushViewController(ItemDetailViewController(item: selectedItem), animated: true)
    }
}
