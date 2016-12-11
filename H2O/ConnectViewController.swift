//
//  ConnectViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 11/17/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class ConnectViewController: UIViewController, BoardingProtocol {
    var titleLabel: UILabel!
    var connectTableView :UITableView!
    fileprivate var servicesModel :ServiceIntergrationModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        var navigationItem = self.navigationItem
        configureNavigationItem(navigationItem: &navigationItem, title: "", rightBarButtonItemTitle: "Done")
        
        titleLabel = generateTitleLabel()
        titleLabel.text = "Connect"
        
        connectTableView = generateConnectTableView()
        
        layout()
    }
    
    private func layout() {
        //---Title Label---
        view.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 80))
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        
        //---Connect Table View---
        view.addSubview(connectTableView)
        
        connectTableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: connectTableView, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1, constant: 10))
        view.addConstraint(NSLayoutConstraint(item: connectTableView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: connectTableView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: connectTableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
    }
    
    func animateIn(completion: @escaping (Bool) -> Void) {
        delay(delay: 0.5, closure: {
            completion(true)
        })
    }
    
    func animateOut(completion: @escaping (Bool) -> Void) {
        
    }
    
    func onRightBarButton() {
        
    }
}

extension ConnectViewController :UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SupportedServices.allSupportedServices().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = UITableViewCell(style: .default, reuseIdentifier: "CONNECT_CELL_IDENTIFIER") as? ConnectTableViewCell else {
            fatalError("Cell is not correct type.")
        }
        
        
        return cell
    }
}

// MARK: - Private Generators
private extension ConnectViewController {
    func generateConnectTableView() -> UITableView {
        let tableView = UITableView()
        
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.register(ConnectTableViewCell.self, forCellReuseIdentifier: "CONNECT_CELL_IDENTIFIER")
        
        return tableView
    }
}
